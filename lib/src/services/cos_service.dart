import 'dart:typed_data';

import '../models/models.dart';

/// Abstract class defining the interface for COS operations.
/// This serves as the common interface for both native and Dart implementations.
abstract class CosService {
  /// Initialize the service with configuration
  Future<void> initialize(CosConfig config);

  /// Upload a file to COS
  Future<CosResponse<Map<String, dynamic>>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  });

  /// Upload data to COS
  Future<CosResponse<Map<String, dynamic>>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  });

  /// Download a file from COS
  Future<CosResponse<Map<String, dynamic>>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  });

  /// Delete an object from COS
  Future<CosResponse<Map<String, dynamic>>> deleteObject({
    required String bucketName,
    required String cosPath,
  });

  /// List objects in a bucket
  Future<CosResponse<List<CosObject>>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  });

  /// Create a bucket
  Future<CosResponse<Map<String, dynamic>>> createBucket({
    required String bucketName,
  });

  /// Delete a bucket
  Future<CosResponse<Map<String, dynamic>>> deleteBucket({
    required String bucketName,
  });

  /// List all buckets
  Future<CosResponse<List<Bucket>>> listBuckets();

  /// Generate a pre-signed URL for a COS object
  Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  });

  /// Check if an object exists in COS
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  });

  /// Copy an object within COS or between buckets
  Future<CosResponse<Map<String, dynamic>>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  });
}