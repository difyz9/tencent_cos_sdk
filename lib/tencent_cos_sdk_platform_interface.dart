import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tencent_cos_sdk_method_channel.dart';

abstract class TencentCosSdkPlatform extends PlatformInterface {
  /// Constructs a TencentCosSdkPlatform.
  TencentCosSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TencentCosSdkPlatform _instance = MethodChannelTencentCosSdk();

  /// The default instance of [TencentCosSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelTencentCosSdk].
  static TencentCosSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TencentCosSdkPlatform] when
  /// they register themselves.
  static set instance(TencentCosSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  /// Initialize with permanent key
  Future<void> initWithPermanentKey({
    required String secretId,
    required String secretKey,
    required String region,
    required String appId,
  }) {
    throw UnimplementedError('initWithPermanentKey() has not been implemented.');
  }

  /// Initialize with temporary key
  Future<void> initWithTemporaryKey({
    required String secretId,
    required String secretKey,
    required String sessionToken,
    required String region,
    required String appId,
  }) {
    throw UnimplementedError('initWithTemporaryKey() has not been implemented.');
  }

  /// Upload file to COS
  Future<Map<String, dynamic>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) {
    throw UnimplementedError('uploadFile() has not been implemented.');
  }

  /// Upload data to COS
  Future<Map<String, dynamic>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  }) {
    throw UnimplementedError('uploadData() has not been implemented.');
  }

  /// Download file from COS
  Future<Map<String, dynamic>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  }) {
    throw UnimplementedError('downloadFile() has not been implemented.');
  }

  /// Delete object from COS
  Future<Map<String, dynamic>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) {
    throw UnimplementedError('deleteObject() has not been implemented.');
  }

  /// List objects in bucket
  Future<Map<String, dynamic>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) {
    throw UnimplementedError('listObjects() has not been implemented.');
  }

  /// Create bucket
  Future<Map<String, dynamic>> createBucket({
    required String bucketName,
  }) {
    throw UnimplementedError('createBucket() has not been implemented.');
  }

  /// Delete bucket
  Future<Map<String, dynamic>> deleteBucket({
    required String bucketName,
  }) {
    throw UnimplementedError('deleteBucket() has not been implemented.');
  }

  /// List buckets
  Future<Map<String, dynamic>> listBuckets() {
    throw UnimplementedError('listBuckets() has not been implemented.');
  }

  /// Get pre-signed URL
  Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  }) {
    throw UnimplementedError('getPreSignedUrl() has not been implemented.');
  }

  /// Check if object exists
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) {
    throw UnimplementedError('doesObjectExist() has not been implemented.');
  }

  /// Copy object
  Future<Map<String, dynamic>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  }) {
    throw UnimplementedError('copyObject() has not been implemented.');
  }
}
