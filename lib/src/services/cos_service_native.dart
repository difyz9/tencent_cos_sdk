import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../models/models.dart';
import 'cos_service.dart';

/// Implementation of CosService that uses the native SDK via method channels.
/// This implementation is used on platforms where native COS SDKs are available (iOS, Android).
class CosServiceNative implements CosService {
  /// The method channel used to interact with native code
  final MethodChannel _methodChannel;
  
  /// The event channel for progress updates
  final EventChannel _eventChannel;
  
  /// Stores the configuration for reuse
  CosConfig? _config;
  
  /// Constructor that takes method and event channels
  CosServiceNative({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel = methodChannel ?? const MethodChannel('tencent_cos_sdk'),
       _eventChannel = eventChannel ?? const EventChannel('tencent_cos_sdk_progress');
  
  @override
  Future<void> initialize(CosConfig config) async {
    _config = config;
    
    try {
      if (config.isTemporary) {
        await _methodChannel.invokeMethod<void>('initWithTemporaryKey', {
          'secretId': config.secretId,
          'secretKey': config.secretKey,
          'sessionToken': config.sessionToken,
          'region': config.region,
          'appId': config.appId,
        });
      } else {
        await _methodChannel.invokeMethod<void>('initWithPermanentKey', {
          'secretId': config.secretId,
          'secretKey': config.secretKey,
          'region': config.region,
          'appId': config.appId,
        });
      }
    } catch (e) {
      throw CosError(
        code: 'initialization_failed',
        message: 'Failed to initialize COS SDK: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    _ensureInitialized();
    
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('uploadFile', {
        'bucketName': bucketName,
        'cosPath': cosPath,
        'filePath': filePath,
        'taskId': taskId,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'upload_failed',
          message: 'Failed to upload file: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  }) async {
    _ensureInitialized();
    
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('uploadData', {
        'bucketName': bucketName,
        'cosPath': cosPath,
        'data': data,
        'taskId': taskId,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'upload_failed',
          message: 'Failed to upload data: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    _ensureInitialized();
    
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('downloadFile', {
        'bucketName': bucketName,
        'cosPath': cosPath,
        'savePath': savePath,
        'taskId': taskId,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'download_failed',
          message: 'Failed to download file: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('deleteObject', {
        'bucketName': bucketName,
        'cosPath': cosPath,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'delete_failed',
          message: 'Failed to delete object: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<List<CosObject>>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('listObjects', {
        'bucketName': bucketName,
        'prefix': prefix,
        'delimiter': delimiter,
        'maxKeys': maxKeys,
      });
      
      if (result != null && result['objects'] is List) {
        final List<dynamic> objects = result['objects'] as List<dynamic>;
        final List<CosObject> cosObjects = objects
            .map((obj) => CosObject.fromMap(obj as Map<String, dynamic>))
            .toList();
        
        return CosResponse.success(cosObjects);
      }
      
      return CosResponse.success([]);
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'list_objects_failed',
          message: 'Failed to list objects: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> createBucket({
    required String bucketName,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('createBucket', {
        'bucketName': bucketName,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'create_bucket_failed',
          message: 'Failed to create bucket: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> deleteBucket({
    required String bucketName,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('deleteBucket', {
        'bucketName': bucketName,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'delete_bucket_failed',
          message: 'Failed to delete bucket: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<CosResponse<List<Bucket>>> listBuckets() async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('listBuckets');
      
      if (result != null && result['buckets'] is List) {
        final List<dynamic> buckets = result['buckets'] as List<dynamic>;
        final List<Bucket> cosBuckets = buckets
            .map((bucket) => Bucket.fromMap(bucket as Map<String, dynamic>))
            .toList();
        
        return CosResponse.success(cosBuckets);
      }
      
      return CosResponse.success([]);
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'list_buckets_failed',
          message: 'Failed to list buckets: ${e.toString()}',
        ),
      );
    }
  }
  
  @override
  Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMethod<String>('getPreSignedUrl', {
        'bucketName': bucketName,
        'cosPath': cosPath,
        'expirationInSeconds': expirationInSeconds,
        'httpMethod': httpMethod,
      });
      
      return result ?? '';
    } catch (e) {
      throw CosError(
        code: 'presigned_url_failed',
        message: 'Failed to generate pre-signed URL: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMethod<bool>('doesObjectExist', {
        'bucketName': bucketName,
        'cosPath': cosPath,
      });
      
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  }) async {
    _ensureInitialized();
    
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('copyObject', {
        'sourceBucketName': sourceBucketName,
        'sourceCosPath': sourceCosPath,
        'destinationBucketName': destinationBucketName,
        'destinationCosPath': destinationCosPath,
      });
      
      return CosResponse.success(result ?? {});
    } catch (e) {
      return CosResponse.error(
        CosError(
          code: 'copy_object_failed',
          message: 'Failed to copy object: ${e.toString()}',
        ),
      );
    }
  }
  
  /// Helper method to ensure the SDK is initialized
  void _ensureInitialized() {
    if (_config == null) {
      throw CosError(
        code: 'not_initialized',
        message: 'COS SDK is not initialized. Call initialize() first.',
      );
    }
  }
  
  /// Helper method to set up progress listeners
  void _setupProgressListener(String taskId, void Function(int completed, int total) onProgress) {
    _eventChannel.receiveBroadcastStream({'taskId': taskId}).listen((event) {
      if (event is Map) {
        final completed = event['completed'] as int? ?? 0;
        final total = event['total'] as int? ?? 0;
        onProgress(completed, total);
      }
    });
  }
}