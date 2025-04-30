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
  
  // ===================== 传输任务管理 =====================
  
  /// Upload file with advanced options
  Future<String> uploadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String filePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) {
    throw UnimplementedError('uploadFileAdvanced() has not been implemented.');
  }
  
  /// Download file with advanced options
  Future<String> downloadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String savePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) {
    throw UnimplementedError('downloadFileAdvanced() has not been implemented.');
  }
  
  /// Pause a transfer task
  Future<void> pauseTask(String taskId) {
    throw UnimplementedError('pauseTask() has not been implemented.');
  }
  
  /// Resume a paused transfer task
  Future<void> resumeTask(String taskId) {
    throw UnimplementedError('resumeTask() has not been implemented.');
  }
  
  /// Cancel a transfer task
  Future<void> cancelTask(String taskId) {
    throw UnimplementedError('cancelTask() has not been implemented.');
  }
  
  /// Get the status of a transfer task
  Future<Map<String, dynamic>> getTaskStatus(String taskId) {
    throw UnimplementedError('getTaskStatus() has not been implemented.');
  }
  
  /// List all active transfer tasks
  Future<List<Map<String, dynamic>>> listTasks() {
    throw UnimplementedError('listTasks() has not been implemented.');
  }
  
  // ===================== 高级存储桶操作 =====================
  
  /// Set access control list for a bucket
  Future<Map<String, dynamic>> putBucketACL({
    required String bucketName,
    required String acl,
    List<String>? grantRead,
    List<String>? grantWrite,
    List<String>? grantFullControl,
  }) {
    throw UnimplementedError('putBucketACL() has not been implemented.');
  }
  
  /// Get access control list for a bucket
  Future<Map<String, dynamic>> getBucketACL({
    required String bucketName,
  }) {
    throw UnimplementedError('getBucketACL() has not been implemented.');
  }
  
  /// Configure cross-origin resource sharing for a bucket
  Future<Map<String, dynamic>> putBucketCORS({
    required String bucketName,
    required List<Map<String, dynamic>> corsRules,
  }) {
    throw UnimplementedError('putBucketCORS() has not been implemented.');
  }
  
  /// Get cross-origin resource sharing configuration for a bucket
  Future<Map<String, dynamic>> getBucketCORS({
    required String bucketName,
  }) {
    throw UnimplementedError('getBucketCORS() has not been implemented.');
  }
  
  /// Delete cross-origin resource sharing configuration for a bucket
  Future<Map<String, dynamic>> deleteBucketCORS({
    required String bucketName,
  }) {
    throw UnimplementedError('deleteBucketCORS() has not been implemented.');
  }
  
  /// Configure referer whitelist/blacklist for a bucket
  Future<Map<String, dynamic>> putBucketReferer({
    required String bucketName,
    required String refererType,
    required List<String> domains,
    required bool emptyReferer,
  }) {
    throw UnimplementedError('putBucketReferer() has not been implemented.');
  }
  
  /// Get referer configuration for a bucket
  Future<Map<String, dynamic>> getBucketReferer({
    required String bucketName,
  }) {
    throw UnimplementedError('getBucketReferer() has not been implemented.');
  }
  
  /// Enable or disable global acceleration for a bucket
  Future<Map<String, dynamic>> putBucketAccelerate({
    required String bucketName,
    required bool enabled,
  }) {
    throw UnimplementedError('putBucketAccelerate() has not been implemented.');
  }
  
  /// Get global acceleration configuration for a bucket
  Future<Map<String, dynamic>> getBucketAccelerate({
    required String bucketName,
  }) {
    throw UnimplementedError('getBucketAccelerate() has not been implemented.');
  }
  
  /// Set tags for a bucket
  Future<Map<String, dynamic>> putBucketTagging({
    required String bucketName,
    required Map<String, String> tags,
  }) {
    throw UnimplementedError('putBucketTagging() has not been implemented.');
  }
  
  /// Get tags for a bucket
  Future<Map<String, dynamic>> getBucketTagging({
    required String bucketName,
  }) {
    throw UnimplementedError('getBucketTagging() has not been implemented.');
  }
  
  /// Delete tags for a bucket
  Future<Map<String, dynamic>> deleteBucketTagging({
    required String bucketName,
  }) {
    throw UnimplementedError('deleteBucketTagging() has not been implemented.');
  }
  
  // ===================== 高级对象操作 =====================
  
  /// Set access control list for an object
  Future<Map<String, dynamic>> putObjectACL({
    required String bucketName,
    required String cosPath,
    required String acl,
    List<String>? grantRead,
    List<String>? grantFullControl,
  }) {
    throw UnimplementedError('putObjectACL() has not been implemented.');
  }
  
  /// Get access control list for an object
  Future<Map<String, dynamic>> getObjectACL({
    required String bucketName,
    required String cosPath,
  }) {
    throw UnimplementedError('getObjectACL() has not been implemented.');
  }
  
  /// Set tags for an object
  Future<Map<String, dynamic>> putObjectTagging({
    required String bucketName,
    required String cosPath,
    required Map<String, String> tags,
    String? versionId,
  }) {
    throw UnimplementedError('putObjectTagging() has not been implemented.');
  }
  
  /// Get tags for an object
  Future<Map<String, dynamic>> getObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) {
    throw UnimplementedError('getObjectTagging() has not been implemented.');
  }
  
  /// Delete tags for an object
  Future<Map<String, dynamic>> deleteObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) {
    throw UnimplementedError('deleteObjectTagging() has not been implemented.');
  }
  
  /// Delete multiple objects in a single request
  Future<Map<String, dynamic>> deleteMultipleObjects({
    required String bucketName,
    required List<String> cosPaths,
    bool quiet = false,
  }) {
    throw UnimplementedError('deleteMultipleObjects() has not been implemented.');
  }
  
  /// Upload a directory to COS
  Future<Map<String, dynamic>> uploadDirectory({
    required String bucketName,
    required String localDirPath,
    required String cosPrefix,
    bool recursive = true,
    void Function(int completed, int total)? onProgress,
    void Function(String filePath, bool success)? onFileComplete,
  }) {
    throw UnimplementedError('uploadDirectory() has not been implemented.');
  }
  
  /// Delete a directory in COS
  Future<Map<String, dynamic>> deleteDirectory({
    required String bucketName,
    required String cosPath,
    bool recursive = true,
  }) {
    throw UnimplementedError('deleteDirectory() has not been implemented.');
  }
  
  /// Restore an archived object
  Future<Map<String, dynamic>> restoreObject({
    required String bucketName,
    required String cosPath,
    required int days,
    String tier = 'Standard',
  }) {
    throw UnimplementedError('restoreObject() has not been implemented.');
  }
  
  // ===================== 网络配置 =====================
  
  /// Configure custom DNS resolution
  Future<void> setCustomDNS(Map<String, List<String>> dnsMap) {
    throw UnimplementedError('setCustomDNS() has not been implemented.');
  }
  
  /// Pre-build connection to a bucket
  Future<void> preBuildConnection(String bucketName) {
    throw UnimplementedError('preBuildConnection() has not been implemented.');
  }
  
  /// Configure advanced service options
  Future<void> configureService({
    String? region,
    int? connectionTimeout,
    int? socketTimeout,
    bool? isHttps,
    bool? accelerate,
    String? hostFormat,
    String? userAgent,
  }) {
    throw UnimplementedError('configureService() has not been implemented.');
  }
  
  /// Configure transfer options
  Future<void> configureTransfer({
    int? divisionForUpload,
    int? sliceSizeForUpload,
    bool? verifyContent,
  }) {
    throw UnimplementedError('configureTransfer() has not been implemented.');
  }
}
