import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'tencent_cos_sdk_platform_interface.dart';
export 'src/models/models.dart';
export 'src/services/services.dart';

/// Main class for the Tencent COS SDK plugin.
/// This class provides a comprehensive API for interacting with Tencent Cloud Object Storage,
/// combining both native SDK integration and pure Dart implementation for full platform support.
class TencentCosSdk {
  /// Get the platform version
  Future<String?> getPlatformVersion() {
    return TencentCosSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the COS SDK with permanent credentials
  /// 
  /// [secretId] - Your Tencent Cloud API Secret ID
  /// [secretKey] - Your Tencent Cloud API Secret Key
  /// [region] - The COS region (e.g., ap-guangzhou)
  /// [appId] - Your Tencent Cloud AppID
  static Future<void> initWithPermanentKey({
    required String secretId,
    required String secretKey,
    required String region,
    required String appId,
  }) {
    return TencentCosSdkPlatform.instance.initWithPermanentKey(
      secretId: secretId,
      secretKey: secretKey,
      region: region,
      appId: appId,
    );
  }

  /// Initialize the COS SDK with temporary credentials
  ///
  /// [secretId] - Temporary Secret ID
  /// [secretKey] - Temporary Secret Key
  /// [sessionToken] - Temporary Session Token
  /// [region] - The COS region (e.g., ap-guangzhou)
  /// [appId] - Your Tencent Cloud AppID
  static Future<void> initWithTemporaryKey({
    required String secretId,
    required String secretKey,
    required String sessionToken,
    required String region,
    required String appId,
  }) {
    return TencentCosSdkPlatform.instance.initWithTemporaryKey(
      secretId: secretId,
      secretKey: secretKey,
      sessionToken: sessionToken,
      region: region,
      appId: appId,
    );
  }

  /// Upload a file to COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The destination path in COS
  /// [filePath] - The local file path to upload
  /// [onProgress] - Optional callback for upload progress
  static Future<Map<String, dynamic>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) {
    return TencentCosSdkPlatform.instance.uploadFile(
      bucketName: bucketName,
      cosPath: cosPath,
      filePath: filePath,
      onProgress: onProgress,
    );
  }

  /// Upload data to COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The destination path in COS
  /// [data] - The data to upload
  /// [onProgress] - Optional callback for upload progress
  static Future<Map<String, dynamic>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  }) {
    return TencentCosSdkPlatform.instance.uploadData(
      bucketName: bucketName,
      cosPath: cosPath,
      data: data,
      onProgress: onProgress,
    );
  }

  /// Download a file from COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The path in COS to download
  /// [savePath] - The local path to save the file
  /// [onProgress] - Optional callback for download progress
  static Future<Map<String, dynamic>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  }) {
    return TencentCosSdkPlatform.instance.downloadFile(
      bucketName: bucketName,
      cosPath: cosPath,
      savePath: savePath,
      onProgress: onProgress,
    );
  }

  /// Delete a file from COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The path in COS to delete
  static Future<Map<String, dynamic>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) {
    return TencentCosSdkPlatform.instance.deleteObject(
      bucketName: bucketName,
      cosPath: cosPath,
    );
  }

  /// Get list of objects in a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [prefix] - Optional prefix for filtering objects
  /// [delimiter] - Optional delimiter for grouping
  /// [maxKeys] - Optional maximum number of keys to return
  static Future<Map<String, dynamic>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) {
    return TencentCosSdkPlatform.instance.listObjects(
      bucketName: bucketName,
      prefix: prefix,
      delimiter: delimiter,
      maxKeys: maxKeys,
    );
  }

  /// Create a bucket
  ///
  /// [bucketName] - The name of the bucket to create
  static Future<Map<String, dynamic>> createBucket({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.createBucket(
      bucketName: bucketName,
    );
  }

  /// Delete a bucket
  ///
  /// [bucketName] - The name of the bucket to delete
  static Future<Map<String, dynamic>> deleteBucket({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.deleteBucket(
      bucketName: bucketName,
    );
  }

  /// List buckets
  static Future<Map<String, dynamic>> listBuckets() {
    return TencentCosSdkPlatform.instance.listBuckets();
  }

  /// Generate a pre-signed URL for a COS object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The path in COS
  /// [expirationInSeconds] - Expiration time in seconds
  /// [httpMethod] - HTTP method (default: 'GET')
  static Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  }) {
    return TencentCosSdkPlatform.instance.getPreSignedUrl(
      bucketName: bucketName,
      cosPath: cosPath,
      expirationInSeconds: expirationInSeconds,
      httpMethod: httpMethod,
    );
  }

  /// Check if an object exists in COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The path in COS to check
  static Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) {
    return TencentCosSdkPlatform.instance.doesObjectExist(
      bucketName: bucketName,
      cosPath: cosPath,
    );
  }

  /// Copy an object within COS or between buckets
  ///
  /// [sourceBucketName] - Source bucket name
  /// [sourceCosPath] - Source COS path
  /// [destinationBucketName] - Destination bucket name
  /// [destinationCosPath] - Destination COS path
  static Future<Map<String, dynamic>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  }) {
    return TencentCosSdkPlatform.instance.copyObject(
      sourceBucketName: sourceBucketName,
      sourceCosPath: sourceCosPath,
      destinationBucketName: destinationBucketName,
      destinationCosPath: destinationCosPath,
    );
  }

  // ===================== 传输任务管理 =====================

  /// Upload a file with advanced options and support for resumable uploads
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The destination path in COS
  /// [filePath] - The local file path to upload
  /// [options] - Advanced upload options like slice size, acceleration, etc.
  /// [onProgress] - Optional callback for upload progress
  /// Returns a task ID that can be used to pause, resume or cancel the upload
  static Future<String> uploadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String filePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) {
    return TencentCosSdkPlatform.instance.uploadFileAdvanced(
      bucketName: bucketName,
      cosPath: cosPath,
      filePath: filePath,
      options: options,
      onProgress: onProgress,
    );
  }

  /// Download a file with advanced options and support for resumable downloads
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The path in COS to download
  /// [savePath] - The local path to save the file
  /// [options] - Advanced download options
  /// [onProgress] - Optional callback for download progress
  /// Returns a task ID that can be used to pause, resume or cancel the download
  static Future<String> downloadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String savePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) {
    return TencentCosSdkPlatform.instance.downloadFileAdvanced(
      bucketName: bucketName,
      cosPath: cosPath,
      savePath: savePath,
      options: options,
      onProgress: onProgress,
    );
  }

  /// Pause a transfer task (upload or download)
  ///
  /// [taskId] - The ID of the task to pause
  static Future<void> pauseTask(String taskId) {
    return TencentCosSdkPlatform.instance.pauseTask(taskId);
  }

  /// Resume a paused transfer task (upload or download)
  ///
  /// [taskId] - The ID of the task to resume
  static Future<void> resumeTask(String taskId) {
    return TencentCosSdkPlatform.instance.resumeTask(taskId);
  }

  /// Cancel a transfer task (upload or download)
  ///
  /// [taskId] - The ID of the task to cancel
  static Future<void> cancelTask(String taskId) {
    return TencentCosSdkPlatform.instance.cancelTask(taskId);
  }

  /// Get the status of a transfer task
  ///
  /// [taskId] - The ID of the task to check
  /// Returns a map with task status information
  static Future<Map<String, dynamic>> getTaskStatus(String taskId) {
    return TencentCosSdkPlatform.instance.getTaskStatus(taskId);
  }

  /// List all active transfer tasks
  ///
  /// Returns a list of task IDs and their statuses
  static Future<List<Map<String, dynamic>>> listTasks() {
    return TencentCosSdkPlatform.instance.listTasks();
  }

  // ===================== 高级存储桶操作 =====================

  /// Set access control list (ACL) for a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [acl] - ACL string (e.g., 'private', 'public-read', 'public-read-write')
  /// [grantRead] - Optional grant read permission to specified accounts
  /// [grantWrite] - Optional grant write permission to specified accounts
  /// [grantFullControl] - Optional grant full control to specified accounts
  static Future<Map<String, dynamic>> putBucketACL({
    required String bucketName,
    required String acl,
    List<String>? grantRead,
    List<String>? grantWrite,
    List<String>? grantFullControl,
  }) {
    return TencentCosSdkPlatform.instance.putBucketACL(
      bucketName: bucketName,
      acl: acl,
      grantRead: grantRead,
      grantWrite: grantWrite,
      grantFullControl: grantFullControl,
    );
  }

  /// Get access control list (ACL) for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> getBucketACL({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.getBucketACL(
      bucketName: bucketName,
    );
  }

  /// Configure Cross-Origin Resource Sharing (CORS) for a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [corsRules] - List of CORS rules
  static Future<Map<String, dynamic>> putBucketCORS({
    required String bucketName,
    required List<Map<String, dynamic>> corsRules,
  }) {
    return TencentCosSdkPlatform.instance.putBucketCORS(
      bucketName: bucketName,
      corsRules: corsRules,
    );
  }

  /// Get Cross-Origin Resource Sharing (CORS) configuration for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> getBucketCORS({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.getBucketCORS(
      bucketName: bucketName,
    );
  }

  /// Delete Cross-Origin Resource Sharing (CORS) configuration for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> deleteBucketCORS({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.deleteBucketCORS(
      bucketName: bucketName,
    );
  }

  /// Configure referer whitelist/blacklist for a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [refererType] - 'White-List' or 'Black-List'
  /// [domains] - List of domain patterns
  /// [emptyReferer] - Whether to allow empty referer, true or false
  static Future<Map<String, dynamic>> putBucketReferer({
    required String bucketName,
    required String refererType,
    required List<String> domains,
    required bool emptyReferer,
  }) {
    return TencentCosSdkPlatform.instance.putBucketReferer(
      bucketName: bucketName,
      refererType: refererType,
      domains: domains,
      emptyReferer: emptyReferer,
    );
  }

  /// Get referer configuration for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> getBucketReferer({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.getBucketReferer(
      bucketName: bucketName,
    );
  }

  /// Enable or disable global acceleration for a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [enabled] - Whether to enable acceleration
  static Future<Map<String, dynamic>> putBucketAccelerate({
    required String bucketName,
    required bool enabled,
  }) {
    return TencentCosSdkPlatform.instance.putBucketAccelerate(
      bucketName: bucketName,
      enabled: enabled,
    );
  }

  /// Get global acceleration configuration for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> getBucketAccelerate({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.getBucketAccelerate(
      bucketName: bucketName,
    );
  }

  /// Set tags for a bucket
  ///
  /// [bucketName] - The name of the bucket
  /// [tags] - Map of tag keys and values
  static Future<Map<String, dynamic>> putBucketTagging({
    required String bucketName,
    required Map<String, String> tags,
  }) {
    return TencentCosSdkPlatform.instance.putBucketTagging(
      bucketName: bucketName,
      tags: tags,
    );
  }

  /// Get tags for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> getBucketTagging({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.getBucketTagging(
      bucketName: bucketName,
    );
  }

  /// Delete tags for a bucket
  ///
  /// [bucketName] - The name of the bucket
  static Future<Map<String, dynamic>> deleteBucketTagging({
    required String bucketName,
  }) {
    return TencentCosSdkPlatform.instance.deleteBucketTagging(
      bucketName: bucketName,
    );
  }

  // ===================== 高级对象操作 =====================

  /// Set access control list (ACL) for an object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  /// [acl] - ACL string (e.g., 'private', 'public-read')
  /// [grantRead] - Optional grant read permission to specified accounts
  /// [grantFullControl] - Optional grant full control to specified accounts
  static Future<Map<String, dynamic>> putObjectACL({
    required String bucketName,
    required String cosPath,
    required String acl,
    List<String>? grantRead,
    List<String>? grantFullControl,
  }) {
    return TencentCosSdkPlatform.instance.putObjectACL(
      bucketName: bucketName,
      cosPath: cosPath,
      acl: acl,
      grantRead: grantRead,
      grantFullControl: grantFullControl,
    );
  }

  /// Get access control list (ACL) for an object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  static Future<Map<String, dynamic>> getObjectACL({
    required String bucketName,
    required String cosPath,
  }) {
    return TencentCosSdkPlatform.instance.getObjectACL(
      bucketName: bucketName,
      cosPath: cosPath,
    );
  }

  /// Set tags for an object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  /// [tags] - Map of tag keys and values
  /// [versionId] - Optional specific version of the object
  static Future<Map<String, dynamic>> putObjectTagging({
    required String bucketName,
    required String cosPath,
    required Map<String, String> tags,
    String? versionId,
  }) {
    return TencentCosSdkPlatform.instance.putObjectTagging(
      bucketName: bucketName,
      cosPath: cosPath,
      tags: tags,
      versionId: versionId,
    );
  }

  /// Get tags for an object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  /// [versionId] - Optional specific version of the object
  static Future<Map<String, dynamic>> getObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) {
    return TencentCosSdkPlatform.instance.getObjectTagging(
      bucketName: bucketName,
      cosPath: cosPath,
      versionId: versionId,
    );
  }

  /// Delete tags for an object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  /// [versionId] - Optional specific version of the object
  static Future<Map<String, dynamic>> deleteObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) {
    return TencentCosSdkPlatform.instance.deleteObjectTagging(
      bucketName: bucketName,
      cosPath: cosPath,
      versionId: versionId,
    );
  }

  /// Delete multiple objects in a single request
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPaths] - List of object paths to delete
  /// [quiet] - If true, only errors are returned; if false, all results are returned
  static Future<Map<String, dynamic>> deleteMultipleObjects({
    required String bucketName,
    required List<String> cosPaths,
    bool quiet = false,
  }) {
    return TencentCosSdkPlatform.instance.deleteMultipleObjects(
      bucketName: bucketName,
      cosPaths: cosPaths,
      quiet: quiet,
    );
  }

  /// Upload a directory to COS
  ///
  /// [bucketName] - The name of the bucket
  /// [localDirPath] - The local directory path to upload
  /// [cosPrefix] - The prefix path in COS
  /// [recursive] - Whether to upload subdirectories
  /// [onProgress] - Optional callback for overall upload progress
  /// [onFileComplete] - Optional callback when each file is completed
  static Future<Map<String, dynamic>> uploadDirectory({
    required String bucketName,
    required String localDirPath,
    required String cosPrefix,
    bool recursive = true,
    void Function(int completed, int total)? onProgress,
    void Function(String filePath, bool success)? onFileComplete,
  }) {
    return TencentCosSdkPlatform.instance.uploadDirectory(
      bucketName: bucketName,
      localDirPath: localDirPath,
      cosPrefix: cosPrefix,
      recursive: recursive,
      onProgress: onProgress,
      onFileComplete: onFileComplete,
    );
  }

  /// Delete a directory in COS
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The directory path in COS to delete
  /// [recursive] - Whether to delete all contents
  static Future<Map<String, dynamic>> deleteDirectory({
    required String bucketName,
    required String cosPath,
    bool recursive = true,
  }) {
    return TencentCosSdkPlatform.instance.deleteDirectory(
      bucketName: bucketName,
      cosPath: cosPath,
      recursive: recursive,
    );
  }

  /// Restore an archived object
  ///
  /// [bucketName] - The name of the bucket
  /// [cosPath] - The object path in COS
  /// [days] - Number of days to keep the restored copy
  /// [tier] - Optional retrieval tier ('Expedited', 'Standard', 'Bulk')
  static Future<Map<String, dynamic>> restoreObject({
    required String bucketName,
    required String cosPath,
    required int days,
    String tier = 'Standard',
  }) {
    return TencentCosSdkPlatform.instance.restoreObject(
      bucketName: bucketName,
      cosPath: cosPath,
      days: days,
      tier: tier,
    );
  }

  // ===================== 网络配置 =====================

  /// Configure custom DNS resolution
  ///
  /// [dnsMap] - Map of domain names to IP addresses
  static Future<void> setCustomDNS(Map<String, List<String>> dnsMap) {
    return TencentCosSdkPlatform.instance.setCustomDNS(dnsMap);
  }

  /// Pre-build connection to a bucket to improve initial access speed
  ///
  /// [bucketName] - The name of the bucket
  static Future<void> preBuildConnection(String bucketName) {
    return TencentCosSdkPlatform.instance.preBuildConnection(bucketName);
  }

  /// Configure advanced service options
  ///
  /// [region] - Default region
  /// [connectionTimeout] - Connection timeout in milliseconds
  /// [socketTimeout] - Socket timeout in milliseconds
  /// [isHttps] - Whether to use HTTPS (true) or HTTP (false)
  /// [accelerate] - Whether to use global acceleration
  /// [hostFormat] - Custom host format
  /// [userAgent] - Custom User-Agent string
  static Future<void> configureService({
    String? region,
    int? connectionTimeout,
    int? socketTimeout,
    bool? isHttps,
    bool? accelerate,
    String? hostFormat,
    String? userAgent,
  }) {
    return TencentCosSdkPlatform.instance.configureService(
      region: region,
      connectionTimeout: connectionTimeout,
      socketTimeout: socketTimeout,
      isHttps: isHttps,
      accelerate: accelerate,
      hostFormat: hostFormat,
      userAgent: userAgent,
    );
  }

  /// Configure transfer options
  ///
  /// [divisionForUpload] - File size threshold for multipart upload
  /// [sliceSizeForUpload] - Size for each part in multipart upload
  /// [verifyContent] - Whether to verify content after transfer
  static Future<void> configureTransfer({
    int? divisionForUpload,
    int? sliceSizeForUpload,
    bool? verifyContent,
  }) {
    return TencentCosSdkPlatform.instance.configureTransfer(
      divisionForUpload: divisionForUpload,
      sliceSizeForUpload: sliceSizeForUpload,
      verifyContent: verifyContent,
    );
  }
}
