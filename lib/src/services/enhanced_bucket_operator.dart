import 'dart:typed_data';
import '../models/models.dart';
import 'temp_credential_manager.dart';
import '../../tencent_cos_sdk.dart';

/// 增强版的存储桶操作工具
/// 基于临时凭证提供完整的存储桶和对象操作功能
class EnhancedBucketOperator {
  final TempCredentialManager _credentialManager;
  final String _region;
  final String _appId;

  /// 创建增强版存储桶操作工具
  /// 
  /// [credentialManager] 临时密钥管理器
  /// [region] COS 区域
  /// [appId] 腾讯云 AppID
  EnhancedBucketOperator({
    required TempCredentialManager credentialManager,
    required String region,
    required String appId,
  })  : _credentialManager = credentialManager,
        _region = region,
        _appId = appId;

  /// 创建存储桶
  Future<bool> createBucket(String bucketName) async {
    final credentials = await _credentialManager.getBucketCredentials(
      bucketName,
      operations: [BucketOperation.createBucket],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.createBucket(bucketName: bucketName);
    return result['success'] == true;
  }

  /// 删除存储桶
  Future<bool> deleteBucket(String bucketName) async {
    final credentials = await _credentialManager.getBucketCredentials(
      bucketName,
      operations: [BucketOperation.deleteBucket],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.deleteBucket(bucketName: bucketName);
    return result['success'] == true;
  }

  /// 列出存储桶中的对象
  Future<List<CosObject>> listObjects(
    String bucketName, {
    String? prefix,
    int? maxKeys,
  }) async {
    final credentials = await _credentialManager.getBucketCredentials(
      bucketName,
      operations: [BucketOperation.listObjects],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.listObjects(
      bucketName: bucketName,
      prefix: prefix,
      maxKeys: maxKeys,
    );
    
    // 解析结果为CosObject列表
    final List<CosObject> objects = [];
    if (result['contents'] is List) {
      for (var item in result['contents']) {
        if (item is Map<String, dynamic>) {
          objects.add(CosObject.fromMap(item));
        }
      }
    }
    return objects;
  }

  /// 上传文件
  Future<bool> uploadFile(
    String bucketName,
    String cosPath,
    String filePath, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: [ObjectOperation.putObject],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.uploadFile(
      bucketName: bucketName,
      cosPath: cosPath,
      filePath: filePath,
      onProgress: onProgress,
    );
    return result['success'] == true;
  }

  /// 上传数据
  Future<bool> uploadData(
    String bucketName,
    String cosPath,
    Uint8List data, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: [ObjectOperation.putObject],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.uploadData(
      bucketName: bucketName,
      cosPath: cosPath,
      data: data,
      onProgress: onProgress,
    );
    return result['success'] == true;
  }

  /// 下载文件
  Future<bool> downloadFile(
    String bucketName,
    String cosPath,
    String savePath, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: [ObjectOperation.getObject],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.downloadFile(
      bucketName: bucketName,
      cosPath: cosPath,
      savePath: savePath,
      onProgress: onProgress,
    );
    return result['success'] == true;
  }

  /// 删除对象
  Future<bool> deleteObject(String bucketName, String cosPath) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: [ObjectOperation.deleteObject],
    );

    await _initSdkWithCredentials(credentials);
    final result = await TencentCosSdk.deleteObject(
      bucketName: bucketName,
      cosPath: cosPath,
    );
    return result['success'] == true;
  }

  /// 复制对象
  Future<bool> copyObject(
    String sourceBucketName,
    String sourceCosPath,
    String destinationBucketName,
    String destinationCosPath,
  ) async {
    // 需要源和目标的权限
    final sourceCredentials = await _credentialManager.getObjectCredentials(
      sourceBucketName,
      sourceCosPath,
      operations: [ObjectOperation.getObject],
    );
    
    await _initSdkWithCredentials(sourceCredentials);
    
    // 对于跨桶复制，可能需要重新获取目标桶的权限
    if (sourceBucketName != destinationBucketName) {
      final destCredentials = await _credentialManager.getObjectCredentials(
        destinationBucketName,
        destinationCosPath,
        operations: [ObjectOperation.putObject],
      );
      await _initSdkWithCredentials(destCredentials);
    }

    final result = await TencentCosSdk.copyObject(
      sourceBucketName: sourceBucketName,
      sourceCosPath: sourceCosPath,
      destinationBucketName: destinationBucketName,
      destinationCosPath: destinationCosPath,
    );
    return result['success'] == true;
  }

  /// 检查对象是否存在
  Future<bool> doesObjectExist(String bucketName, String cosPath) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: [ObjectOperation.getObject],
    );

    await _initSdkWithCredentials(credentials);
    return await TencentCosSdk.doesObjectExist(
      bucketName: bucketName,
      cosPath: cosPath,
    );
  }

  /// 获取预签名URL（用于直接访问）
  Future<String> getPresignedUrl(
    String bucketName,
    String cosPath, {
    int expirationInSeconds = 3600,
    String httpMethod = 'GET',
  }) async {
    final operations = httpMethod.toUpperCase() == 'PUT' 
        ? [ObjectOperation.putObject]
        : [ObjectOperation.getObject];
        
    final credentials = await _credentialManager.getObjectCredentials(
      bucketName,
      cosPath,
      operations: operations,
    );

    await _initSdkWithCredentials(credentials);
    return await TencentCosSdk.getPreSignedUrl(
      bucketName: bucketName,
      cosPath: cosPath,
      expirationInSeconds: expirationInSeconds,
      httpMethod: httpMethod,
    );
  }

  /// 使用临时凭证初始化SDK
  Future<void> _initSdkWithCredentials(TemporaryCredentials credentials) async {
    await TencentCosSdk.initWithTemporaryKey(
      secretId: credentials.tmpSecretId,
      secretKey: credentials.tmpSecretKey,
      sessionToken: credentials.sessionToken,
      region: _region,
      appId: _appId,
    );
  }

  /// 销毁资源
  void dispose() {
    _credentialManager.dispose();
  }
}
