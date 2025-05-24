import 'dart:typed_data';
import '../models/models.dart';
import '../exceptions/exceptions.dart';
import '../services/services.dart';

/// COS API Factory - 提供简化的工厂模式接口
/// 类似于 tencent_cos_plus 的设计风格
class COSApiFactory {
  static BucketApi? _bucketApi;
  static ObjectApi? _objectApi;

  /// 初始化 COSApiFactory
  /// 
  /// [secretId] - STS服务的SecretId
  /// [secretKey] - STS服务的SecretKey  
  /// [region] - COS区域
  /// [appId] - 腾讯云AppID
  static Future<void> initialize({
    required String secretId,
    required String secretKey,
    required String region,
    required String appId,
  }) async {
    // 创建STS服务
    final stsService = STSService(
      secretId: secretId,
      secretKey: secretKey,
      region: region,
    );
    
    // 创建临时凭证管理器
    final credentialManager = TempCredentialManager(
      stsService,
      appId,
    );
    
    // 创建增强版存储桶操作工具
    final enhancedOperator = EnhancedBucketOperator(
      credentialManager: credentialManager,
      region: region,
      appId: appId,
    );
    
    // 创建API实例
    _bucketApi = BucketApi._(enhancedOperator);
    _objectApi = ObjectApi._(enhancedOperator);
  }

  /// 获取存储桶API实例
  static BucketApi get bucketApi {
    if (_bucketApi == null) {
      throw STSException(
        code: 'FACTORY_NOT_INITIALIZED',
        message: 'COSApiFactory not initialized. Call initialize() first.',
      );
    }
    return _bucketApi!;
  }

  /// 获取对象API实例
  static ObjectApi get objectApi {
    if (_objectApi == null) {
      throw STSException(
        code: 'FACTORY_NOT_INITIALIZED', 
        message: 'COSApiFactory not initialized. Call initialize() first.',
      );
    }
    return _objectApi!;
  }

  /// 销毁工厂实例
  static void dispose() {
    _bucketApi?._operator.dispose();
    _bucketApi = null;
    _objectApi = null;
  }
}

/// 存储桶操作API
class BucketApi {
  final EnhancedBucketOperator _operator;
  
  BucketApi._(this._operator);

  /// 创建存储桶
  Future<bool> create(String bucketName) async {
    return await _operator.createBucket(bucketName);
  }

  /// 删除存储桶
  Future<bool> delete(String bucketName) async {
    return await _operator.deleteBucket(bucketName);
  }

  /// 列出对象
  Future<List<CosObject>> listObjects(
    String bucketName, {
    String? prefix,
    int? maxKeys,
  }) async {
    return await _operator.listObjects(
      bucketName,
      prefix: prefix,
      maxKeys: maxKeys,
    );
  }
}

/// 对象操作API
class ObjectApi {
  final EnhancedBucketOperator _operator;
  
  ObjectApi._(this._operator);

  /// 上传文件
  Future<bool> uploadFile(
    String bucketName,
    String cosPath,
    String filePath, {
    void Function(int completed, int total)? onProgress,
  }) async {
    return await _operator.uploadFile(
      bucketName,
      cosPath,
      filePath,
      onProgress: onProgress,
    );
  }

  /// 上传数据
  Future<bool> uploadData(
    String bucketName,
    String cosPath,
    List<int> data, {
    void Function(int completed, int total)? onProgress,
  }) async {
    return await _operator.uploadData(
      bucketName,
      cosPath,
      Uint8List.fromList(data),
      onProgress: onProgress,
    );
  }

  /// 下载文件
  Future<bool> downloadFile(
    String bucketName,
    String cosPath,
    String savePath, {
    void Function(int completed, int total)? onProgress,
  }) async {
    return await _operator.downloadFile(
      bucketName,
      cosPath,
      savePath,
      onProgress: onProgress,
    );
  }

  /// 删除对象
  Future<bool> delete(String bucketName, String cosPath) async {
    return await _operator.deleteObject(bucketName, cosPath);
  }

  /// 复制对象
  Future<bool> copy(
    String sourceBucketName,
    String sourceCosPath,
    String destinationBucketName,
    String destinationCosPath,
  ) async {
    return await _operator.copyObject(
      sourceBucketName,
      sourceCosPath,
      destinationBucketName,
      destinationCosPath,
    );
  }

  /// 检查对象是否存在
  Future<bool> exists(String bucketName, String cosPath) async {
    return await _operator.doesObjectExist(bucketName, cosPath);
  }

  /// 生成预签名URL
  Future<String> generatePresignedUrl(
    String bucketName,
    String cosPath, {
    int expirationInSeconds = 3600,
    String httpMethod = 'GET',
  }) async {
    return await _operator.getPresignedUrl(
      bucketName,
      cosPath,
      expirationInSeconds: expirationInSeconds,
      httpMethod: httpMethod,
    );
  }
}
