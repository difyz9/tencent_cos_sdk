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
  
  // ===================== 传输任务管理 =====================
  
  @override
  Future<String> uploadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String filePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    await methodChannel.invokeMethod<void>('uploadFileAdvanced', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'filePath': filePath,
      'options': options,
      'taskId': taskId,
    });
    
    return taskId;
  }
  
  @override
  Future<String> downloadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String savePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    await methodChannel.invokeMethod<void>('downloadFileAdvanced', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'savePath': savePath,
      'options': options,
      'taskId': taskId,
    });
    
    return taskId;
  }
  
  @override
  Future<void> pauseTask(String taskId) async {
    await methodChannel.invokeMethod<void>('pauseTask', {
      'taskId': taskId,
    });
  }
  
  @override
  Future<void> resumeTask(String taskId) async {
    await methodChannel.invokeMethod<void>('resumeTask', {
      'taskId': taskId,
    });
  }
  
  @override
  Future<void> cancelTask(String taskId) async {
    await methodChannel.invokeMethod<void>('cancelTask', {
      'taskId': taskId,
    });
  }
  
  @override
  Future<Map<String, dynamic>> getTaskStatus(String taskId) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getTaskStatus', {
      'taskId': taskId,
    });
    
    return result ?? {};
  }
  
  @override
  Future<List<Map<String, dynamic>>> listTasks() async {
    final result = await methodChannel.invokeListMethod<Map<String, dynamic>>('listTasks');
    
    return result ?? [];
  }
  
  // ===================== 高级存储桶操作 =====================
  
  @override
  Future<Map<String, dynamic>> putBucketACL({
    required String bucketName,
    required String acl,
    List<String>? grantRead,
    List<String>? grantWrite,
    List<String>? grantFullControl,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putBucketACL', {
      'bucketName': bucketName,
      'acl': acl,
      'grantRead': grantRead,
      'grantWrite': grantWrite,
      'grantFullControl': grantFullControl,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getBucketACL({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getBucketACL', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> putBucketCORS({
    required String bucketName,
    required List<Map<String, dynamic>> corsRules,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putBucketCORS', {
      'bucketName': bucketName,
      'corsRules': corsRules,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getBucketCORS({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getBucketCORS', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> deleteBucketCORS({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteBucketCORS', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> putBucketReferer({
    required String bucketName,
    required String refererType,
    required List<String> domains,
    required bool emptyReferer,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putBucketReferer', {
      'bucketName': bucketName,
      'refererType': refererType,
      'domains': domains,
      'emptyReferer': emptyReferer,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getBucketReferer({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getBucketReferer', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> putBucketAccelerate({
    required String bucketName,
    required bool enabled,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putBucketAccelerate', {
      'bucketName': bucketName,
      'enabled': enabled,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getBucketAccelerate({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getBucketAccelerate', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> putBucketTagging({
    required String bucketName,
    required Map<String, String> tags,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putBucketTagging', {
      'bucketName': bucketName,
      'tags': tags,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getBucketTagging({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getBucketTagging', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> deleteBucketTagging({
    required String bucketName,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteBucketTagging', {
      'bucketName': bucketName,
    });
    
    return result ?? {};
  }
  
  // ===================== 高级对象操作 =====================
  
  @override
  Future<Map<String, dynamic>> putObjectACL({
    required String bucketName,
    required String cosPath,
    required String acl,
    List<String>? grantRead,
    List<String>? grantFullControl,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putObjectACL', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'acl': acl,
      'grantRead': grantRead,
      'grantFullControl': grantFullControl,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getObjectACL({
    required String bucketName,
    required String cosPath,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getObjectACL', {
      'bucketName': bucketName,
      'cosPath': cosPath,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> putObjectTagging({
    required String bucketName,
    required String cosPath,
    required Map<String, String> tags,
    String? versionId,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('putObjectTagging', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'tags': tags,
      'versionId': versionId,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> getObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('getObjectTagging', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'versionId': versionId,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> deleteObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteObjectTagging', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'versionId': versionId,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> deleteMultipleObjects({
    required String bucketName,
    required List<String> cosPaths,
    bool quiet = false,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteMultipleObjects', {
      'bucketName': bucketName,
      'cosPaths': cosPaths,
      'quiet': quiet,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> uploadDirectory({
    required String bucketName,
    required String localDirPath,
    required String cosPrefix,
    bool recursive = true,
    void Function(int completed, int total)? onProgress,
    void Function(String filePath, bool success)? onFileComplete,
  }) async {
    // Generate a unique task ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Set up progress listener if needed
    if (onProgress != null) {
      _setupProgressListener(taskId, onProgress);
    }
    
    // Set up file completion listener if needed
    if (onFileComplete != null) {
      _setupFileCompletionListener(taskId, onFileComplete);
    }
    
    final result = await methodChannel.invokeMapMethod<String, dynamic>('uploadDirectory', {
      'bucketName': bucketName,
      'localDirPath': localDirPath,
      'cosPrefix': cosPrefix,
      'recursive': recursive,
      'taskId': taskId,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> deleteDirectory({
    required String bucketName,
    required String cosPath,
    bool recursive = true,
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('deleteDirectory', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'recursive': recursive,
    });
    
    return result ?? {};
  }
  
  @override
  Future<Map<String, dynamic>> restoreObject({
    required String bucketName,
    required String cosPath,
    required int days,
    String tier = 'Standard',
  }) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>('restoreObject', {
      'bucketName': bucketName,
      'cosPath': cosPath,
      'days': days,
      'tier': tier,
    });
    
    return result ?? {};
  }
  
  // ===================== 网络配置 =====================
  
  @override
  Future<void> setCustomDNS(Map<String, List<String>> dnsMap) async {
    await methodChannel.invokeMethod<void>('setCustomDNS', {
      'dnsMap': dnsMap,
    });
  }
  
  @override
  Future<void> preBuildConnection(String bucketName) async {
    await methodChannel.invokeMethod<void>('preBuildConnection', {
      'bucketName': bucketName,
    });
  }
  
  @override
  Future<void> configureService({
    String? region,
    int? connectionTimeout,
    int? socketTimeout,
    bool? isHttps,
    bool? accelerate,
    String? hostFormat,
    String? userAgent,
  }) async {
    await methodChannel.invokeMethod<void>('configureService', {
      'region': region,
      'connectionTimeout': connectionTimeout,
      'socketTimeout': socketTimeout,
      'isHttps': isHttps,
      'accelerate': accelerate,
      'hostFormat': hostFormat,
      'userAgent': userAgent,
    });
  }
  
  @override
  Future<void> configureTransfer({
    int? divisionForUpload,
    int? sliceSizeForUpload,
    bool? verifyContent,
  }) async {
    await methodChannel.invokeMethod<void>('configureTransfer', {
      'divisionForUpload': divisionForUpload,
      'sliceSizeForUpload': sliceSizeForUpload,
      'verifyContent': verifyContent,
    });
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
  
  /// Helper method to set up file completion listeners for directory uploads
  void _setupFileCompletionListener(String taskId, void Function(String filePath, bool success) onFileComplete) {
    final fileCompletionChannel = EventChannel('tencent_cos_sdk_file_completion');
    
    fileCompletionChannel.receiveBroadcastStream({'taskId': taskId}).listen((event) {
      if (event is Map) {
        final filePath = event['filePath'] as String? ?? '';
        final success = event['success'] as bool? ?? false;
        onFileComplete(filePath, success);
      }
    });
  }
}
