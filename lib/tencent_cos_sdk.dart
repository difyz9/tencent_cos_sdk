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
}
