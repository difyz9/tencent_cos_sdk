import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tencent_cos_sdk_platform_interface.dart';

/// An implementation of [TencentCosSdkPlatform] that uses method channels.
class MethodChannelTencentCosSdk extends TencentCosSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tencent_cos_sdk');

  /// Progress event channel
  final eventChannel = const EventChannel('tencent_cos_sdk_progress');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initWithPermanentKey({
    required String secretId,
    required String secretKey,
    required String region,
    required String appId,
  }) async {
    await methodChannel.invokeMethod<void>('initWithPermanentKey', {
      'secretId': secretId,
      'secretKey': secretKey,
      'region': region,
      'appId': appId,
    });
  }

  @override
  Future<void> initWithTemporaryKey({
    required String secretId,
    required String secretKey,
    required String sessionToken,
    required String region,
    required String appId,
  }) async {
    await methodChannel.invokeMethod<void>('initWithTemporaryKey', {
      'secretId': secretId,
      'secretKey': secretKey,
      'sessionToken': sessionToken,
      'region': region,
      'appId': appId,
    });
  }

  @override
  Future<Map<String, dynamic>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    final result = await methodChannel.invokeMapMethod<String, dynamic>('uploadFile', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'filePath': filePath,
      'taskId': taskId,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    final result = await methodChannel.invokeMapMethod<String, dynamic>('uploadData', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'data': data,
      'taskId': taskId,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    final result = await methodChannel.invokeMapMethod<String, dynamic>('downloadFile', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'savePath': savePath,
      'taskId': taskId,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteObject', {
      'bucketName': bucketName,
      'cosPath': cosPath,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('listObjects', {
      'bucketName': bucketName,
      'prefix': prefix,
      'delimiter': delimiter,
      'maxKeys': maxKeys,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> createBucket({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('createBucket', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> deleteBucket({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteBucket', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> listBuckets() async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('listBuckets');
    
    return result ?? {};
  }

  @override
  Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  }) async {
    final result = await methodChannel.invokeMethod<String>('getPreSignedUrl', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'expirationInSeconds': expirationInSeconds,
      'httpMethod': httpMethod,
    });
    
    return result ?? '';
  }

  @override
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('doesObjectExist', {
      'bucketName': bucketName,
      'cosPath': cosPath,
    });
    
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('copyObject', {
      'sourceBucketName': sourceBucketName,
      'sourceCosPath': sourceCosPath,
      'destinationBucketName': destinationBucketName,
      'destinationCosPath': destinationCosPath,
    });
    
    return result ?? {};
  }

  /// Helper method to set up progress listeners
  void _setupProgressListener(String taskId, void Function(int completed, int total) onProgress) {
    eventChannel.receiveBroadcastStream({'taskId': taskId}).listen((event) {
      if (event is Map) {
        final completed = event['completed'] as int? ?? 0;
        final total = event['total'] as int? ?? 0;
        onProgress(completed, total);
      }
    });
  }
}
