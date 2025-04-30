// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'tencent_cos_sdk_platform_interface.dart';
import 'src/models/models.dart';

/// A web implementation of the TencentCosSdkPlatform of the TencentCosSdk plugin.
class TencentCosSdkWeb extends TencentCosSdkPlatform {
  /// Constructs a TencentCosSdkWeb
  TencentCosSdkWeb();

  static void registerWith(Registrar registrar) {
    TencentCosSdkPlatform.instance = TencentCosSdkWeb();
  }

  // Configuration properties
  String? _secretId;
  String? _secretKey;
  String? _sessionToken;
  String? _region;
  String? _appId;
  bool _isTemporaryKey = false;
  
  // Service configuration
  bool _isHttps = true;
  bool _accelerate = false;
  String? _userAgent;
  
  // Active tasks
  final Map<String, _WebTransferTask> _activeTasks = {};

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
  
  @override
  Future<void> initWithPermanentKey({
    required String secretId,
    required String secretKey,
    required String region,
    required String appId,
  }) async {
    _secretId = secretId;
    _secretKey = secretKey;
    _region = region;
    _appId = appId;
    _isTemporaryKey = false;
  }

  @override
  Future<void> initWithTemporaryKey({
    required String secretId,
    required String secretKey,
    required String sessionToken,
    required String region,
    required String appId,
  }) async {
    _secretId = secretId;
    _secretKey = secretKey;
    _sessionToken = sessionToken;
    _region = region;
    _appId = appId;
    _isTemporaryKey = true;
  }

  @override
  Future<Map<String, dynamic>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    throw UnimplementedError('uploadFile is not supported on web platform. Use uploadData instead.');
  }

  @override
  Future<Map<String, dynamic>> uploadData({
    required String bucketName,
    required String cosPath,
    required Uint8List data,
    void Function(int completed, int total)? onProgress,
  }) async {
    _checkInitialized();
    
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      final url = _buildObjectUrl(bucketName, cosPath);
      final headers = await _generateAuthHeaders('PUT', bucketName, cosPath);
      
      final request = http.Request('PUT', Uri.parse(url));
      request.headers.addAll(headers);
      request.bodyBytes = data;
      
      final response = await request.send();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = await response.stream.bytesToString();
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': responseBody,
        };
      } else {
        throw Exception('Upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> downloadFile({
    required String bucketName,
    required String cosPath,
    required String savePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    throw UnimplementedError('downloadFile with local path is not supported on web platform. Use getPreSignedUrl instead to get a URL for direct download.');
  }

  @override
  Future<Map<String, dynamic>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildObjectUrl(bucketName, cosPath);
      final headers = await _generateAuthHeaders('DELETE', bucketName, cosPath);
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Delete failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> listObjects({
    required String bucketName,
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) async {
    _checkInitialized();
    
    try {
      var url = _buildBucketUrl(bucketName);
      var queryParams = <String, String>{};
      
      if (prefix != null) queryParams['prefix'] = prefix;
      if (delimiter != null) queryParams['delimiter'] = delimiter;
      if (maxKeys != null) queryParams['max-keys'] = maxKeys.toString();
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
      }
      
      final headers = await _generateAuthHeaders('GET', bucketName, '/');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse XML response
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          // TODO: Parse XML to more structured data
        };
      } else {
        throw Exception('List objects failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> createBucket({
    required String bucketName,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildBucketUrl(bucketName);
      final headers = await _generateAuthHeaders('PUT', bucketName, '/');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Create bucket failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteBucket({
    required String bucketName,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildBucketUrl(bucketName);
      final headers = await _generateAuthHeaders('DELETE', bucketName, '/');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Delete bucket failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> listBuckets() async {
    _checkInitialized();
    
    try {
      final url = _buildServiceUrl();
      final headers = await _generateAuthHeaders('GET', '', '/');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          // TODO: Parse XML to more structured data
        };
      } else {
        throw Exception('List buckets failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<String> getPreSignedUrl({
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
    String httpMethod = 'GET',
  }) async {
    _checkInitialized();
    
    final url = _buildObjectUrl(bucketName, cosPath);
    final expiry = DateTime.now().millisecondsSinceEpoch ~/ 1000 + expirationInSeconds;
    final headers = await _generateAuthHeaders(httpMethod, bucketName, cosPath, expiry: expiry);
    
    // Create a signed URL
    var signedUrl = url;
    final queryParams = <String, String>{};
    
    if (_isTemporaryKey && _sessionToken != null) {
      queryParams['x-cos-security-token'] = _sessionToken!;
    }
    
    // Add signature and other auth params
    // This is a simplified approach, actual implementation would be more complex
    queryParams['sign'] = headers['Authorization'] ?? '';
    
    if (queryParams.isNotEmpty) {
      signedUrl += '?' + queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    }
    
    return signedUrl;
  }

  @override
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildObjectUrl(bucketName, cosPath);
      final headers = await _generateAuthHeaders('HEAD', bucketName, cosPath);
      
      final response = await http.head(
        Uri.parse(url),
        headers: headers,
      );
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> copyObject({
    required String sourceBucketName,
    required String sourceCosPath,
    required String destinationBucketName,
    required String destinationCosPath,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildObjectUrl(destinationBucketName, destinationCosPath);
      final headers = await _generateAuthHeaders('PUT', destinationBucketName, destinationCosPath);
      
      // Add copy source header
      headers['x-cos-copy-source'] = '/${sourceBucketName}-${_appId}/${sourceCosPath}';
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Copy object failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  // ===================== 传输任务管理 =====================
  // Web-specific implementations for transfer task management
  
  @override
  Future<String> uploadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String filePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) async {
    throw UnimplementedError('uploadFileAdvanced is not supported on web platform. Use uploadData instead.');
  }
  
  @override
  Future<String> downloadFileAdvanced({
    required String bucketName,
    required String cosPath,
    required String savePath,
    Map<String, dynamic>? options,
    void Function(int completed, int total)? onProgress,
  }) async {
    throw UnimplementedError('downloadFileAdvanced is not supported on web platform. Use getPreSignedUrl instead.');
  }
  
  @override
  Future<void> pauseTask(String taskId) async {
    if (_activeTasks.containsKey(taskId)) {
      await _activeTasks[taskId]?.pause();
    }
  }
  
  @override
  Future<void> resumeTask(String taskId) async {
    if (_activeTasks.containsKey(taskId)) {
      await _activeTasks[taskId]?.resume();
    }
  }
  
  @override
  Future<void> cancelTask(String taskId) async {
    if (_activeTasks.containsKey(taskId)) {
      await _activeTasks[taskId]?.cancel();
      _activeTasks.remove(taskId);
    }
  }
  
  @override
  Future<Map<String, dynamic>> getTaskStatus(String taskId) async {
    if (_activeTasks.containsKey(taskId)) {
      return _activeTasks[taskId]?.status ?? {'status': 'not_found'};
    }
    return {'status': 'not_found'};
  }
  
  @override
  Future<List<Map<String, dynamic>>> listTasks() async {
    return _activeTasks.entries.map((entry) => {
      'taskId': entry.key,
      ...entry.value.status,
    }).toList();
  }
  
  // ===================== 高级存储桶操作 =====================
  // Web implementations for bucket operations
  
  @override
  Future<Map<String, dynamic>> putBucketACL({
    required String bucketName,
    required String acl,
    List<String>? grantRead,
    List<String>? grantWrite,
    List<String>? grantFullControl,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildBucketUrl(bucketName) + '?acl';
      final headers = await _generateAuthHeaders('PUT', bucketName, '/?acl');
      
      // Add ACL headers
      headers['x-cos-acl'] = acl;
      if (grantRead != null && grantRead.isNotEmpty) {
        headers['x-cos-grant-read'] = grantRead.join(',');
      }
      if (grantWrite != null && grantWrite.isNotEmpty) {
        headers['x-cos-grant-write'] = grantWrite.join(',');
      }
      if (grantFullControl != null && grantFullControl.isNotEmpty) {
        headers['x-cos-grant-full-control'] = grantFullControl.join(',');
      }
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Put bucket ACL failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> getBucketACL({
    required String bucketName,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildBucketUrl(bucketName) + '?acl';
      final headers = await _generateAuthHeaders('GET', bucketName, '/?acl');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          // TODO: Parse XML to more structured data
        };
      } else {
        throw Exception('Get bucket ACL failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  // Implement other bucket operations with similar pattern
  // ...
  
  // ===================== 高级对象操作 =====================
  // Web implementations for object operations
  
  @override
  Future<Map<String, dynamic>> putObjectACL({
    required String bucketName,
    required String cosPath,
    required String acl,
    List<String>? grantRead,
    List<String>? grantFullControl,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildObjectUrl(bucketName, cosPath) + '?acl';
      final headers = await _generateAuthHeaders('PUT', bucketName, '/$cosPath?acl');
      
      // Add ACL headers
      headers['x-cos-acl'] = acl;
      if (grantRead != null && grantRead.isNotEmpty) {
        headers['x-cos-grant-read'] = grantRead.join(',');
      }
      if (grantFullControl != null && grantFullControl.isNotEmpty) {
        headers['x-cos-grant-full-control'] = grantFullControl.join(',');
      }
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
        };
      } else {
        throw Exception('Put object ACL failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> getObjectACL({
    required String bucketName,
    required String cosPath,
  }) async {
    _checkInitialized();
    
    try {
      final url = _buildObjectUrl(bucketName, cosPath) + '?acl';
      final headers = await _generateAuthHeaders('GET', bucketName, '/$cosPath?acl');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          // TODO: Parse XML to more structured data
        };
      } else {
        throw Exception('Get object ACL failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  // Implement other object operations with similar pattern
  // ...
  
  // ===================== 网络配置 =====================
  
  @override
  Future<void> setCustomDNS(Map<String, List<String>> dnsMap) async {
    // DNS customization not applicable for web platform
    throw UnimplementedError('Custom DNS is not supported on web platform');
  }
  
  @override
  Future<void> preBuildConnection(String bucketName) async {
    // Connection pre-building not applicable for web platform
    // No-op implementation
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
    if (region != null) _region = region;
    if (isHttps != null) _isHttps = isHttps;
    if (accelerate != null) _accelerate = accelerate;
    if (userAgent != null) _userAgent = userAgent;
    // Other parameters not applicable for web platform
  }
  
  @override
  Future<void> configureTransfer({
    int? divisionForUpload,
    int? sliceSizeForUpload,
    bool? verifyContent,
  }) async {
    // Transfer configuration not fully applicable for web platform
    // No-op implementation
  }
  
  // For web, unsupported or partially supported methods
  
  @override
  Future<Map<String, dynamic>> putBucketCORS({
    required String bucketName,
    required List<Map<String, dynamic>> corsRules,
  }) async {
    // Implementation similar to putBucketACL
    throw UnimplementedError('putBucketCORS not fully implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> getBucketCORS({
    required String bucketName,
  }) async {
    // Implementation similar to getBucketACL
    throw UnimplementedError('getBucketCORS not fully implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> deleteBucketCORS({
    required String bucketName,
  }) async {
    // Implementation similar to other DELETE operations
    throw UnimplementedError('deleteBucketCORS not fully implemented for web platform');
  }
  
  // Other unimplemented methods with appropriate error messages
  
  @override
  Future<Map<String, dynamic>> putBucketReferer({
    required String bucketName,
    required String refererType,
    required List<String> domains,
    required bool emptyReferer,
  }) async {
    throw UnimplementedError('putBucketReferer not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> getBucketReferer({
    required String bucketName,
  }) async {
    throw UnimplementedError('getBucketReferer not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> putBucketAccelerate({
    required String bucketName,
    required bool enabled,
  }) async {
    throw UnimplementedError('putBucketAccelerate not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> getBucketAccelerate({
    required String bucketName,
  }) async {
    throw UnimplementedError('getBucketAccelerate not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> putBucketTagging({
    required String bucketName,
    required Map<String, String> tags,
  }) async {
    throw UnimplementedError('putBucketTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> getBucketTagging({
    required String bucketName,
  }) async {
    throw UnimplementedError('getBucketTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> deleteBucketTagging({
    required String bucketName,
  }) async {
    throw UnimplementedError('deleteBucketTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> putObjectTagging({
    required String bucketName,
    required String cosPath,
    required Map<String, String> tags,
    String? versionId,
  }) async {
    throw UnimplementedError('putObjectTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> getObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) async {
    throw UnimplementedError('getObjectTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> deleteObjectTagging({
    required String bucketName,
    required String cosPath,
    String? versionId,
  }) async {
    throw UnimplementedError('deleteObjectTagging not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> deleteMultipleObjects({
    required String bucketName,
    required List<String> cosPaths,
    bool quiet = false,
  }) async {
    throw UnimplementedError('deleteMultipleObjects not implemented for web platform');
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
    throw UnimplementedError('uploadDirectory is not supported on web platform');
  }
  
  @override
  Future<Map<String, dynamic>> deleteDirectory({
    required String bucketName,
    required String cosPath,
    bool recursive = true,
  }) async {
    throw UnimplementedError('deleteDirectory not implemented for web platform');
  }
  
  @override
  Future<Map<String, dynamic>> restoreObject({
    required String bucketName,
    required String cosPath,
    required int days,
    String tier = 'Standard',
  }) async {
    throw UnimplementedError('restoreObject not implemented for web platform');
  }
  
  // ===================== Helper methods =====================
  
  /// Check if the SDK has been initialized
  void _checkInitialized() {
    if (_secretId == null || _secretKey == null || _region == null || _appId == null) {
      throw Exception('TencentCosSdk is not initialized. Call initWithPermanentKey or initWithTemporaryKey first.');
    }
  }
  
  /// Build the base URL for the service (list buckets)
  String _buildServiceUrl() {
    final scheme = _isHttps ? 'https' : 'http';
    final host = 'service.cos.myqcloud.com';
    return '$scheme://$host';
  }
  
  /// Build the base URL for a bucket
  String _buildBucketUrl(String bucketName) {
    final scheme = _isHttps ? 'https' : 'http';
    String host;
    
    if (_accelerate) {
      host = 'cos.accelerate.myqcloud.com';
    } else {
      host = '$bucketName-$_appId.cos.$_region.myqcloud.com';
    }
    
    return '$scheme://$host';
  }
  
  /// Build the URL for an object
  String _buildObjectUrl(String bucketName, String cosPath) {
    final bucketUrl = _buildBucketUrl(bucketName);
    return '$bucketUrl/${cosPath.startsWith('/') ? cosPath.substring(1) : cosPath}';
  }
  
  /// Generate authorization headers for a request
  Future<Map<String, String>> _generateAuthHeaders(String method, String bucketName, String resource, {int? expiry}) async {
    // This is a simplified implementation
    // A full implementation would require more complex signature calculation
    
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = expiry ?? (now + 3600); // Default 1 hour
    
    final keyTime = '$now;$expiryTime';
    final signKey = _hmacSha1(_secretKey ?? '', keyTime);
    
    // Build string to sign
    final stringToSign = method.toLowerCase() + '\n' + resource + '\n';
    
    // Create HMAC-SHA1 signature
    final signature = _hmacSha1(signKey, stringToSign);
    
    // Build auth header
    final authorization = 'q-sign-algorithm=sha1'
        '&q-ak=${_secretId}'
        '&q-sign-time=$keyTime'
        '&q-key-time=$keyTime'
        '&q-signature=$signature';
    
    final headers = <String, String>{
      'Authorization': authorization,
      'Host': bucketName.isEmpty 
          ? 'service.cos.myqcloud.com'
          : '$bucketName-$_appId.cos.$_region.myqcloud.com',
    };
    
    if (_isTemporaryKey && _sessionToken != null) {
      headers['x-cos-security-token'] = _sessionToken!;
    }
    
    if (_userAgent != null) {
      headers['User-Agent'] = _userAgent!;
    }
    
    return headers;
  }
  
  /// Create HMAC-SHA1 signature
  String _hmacSha1(String key, String data) {
    final hmac = Hmac(sha1, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }
}

/// Internal class to track web transfer tasks
class _WebTransferTask {
  final String taskId;
  final String bucketName;
  final String cosPath;
  StreamSubscription? _subscription;
  bool _isPaused = false;
  bool _isCancelled = false;
  
  _WebTransferTask({
    required this.taskId,
    required this.bucketName,
    required this.cosPath,
  });
  
  Map<String, dynamic> get status {
    return {
      'taskId': taskId,
      'bucketName': bucketName,
      'cosPath': cosPath,
      'isPaused': _isPaused,
      'isCancelled': _isCancelled,
    };
  }
  
  Future<void> pause() async {
    _isPaused = true;
    _subscription?.pause();
  }
  
  Future<void> resume() async {
    if (_isPaused && !_isCancelled) {
      _isPaused = false;
      _subscription?.resume();
    }
  }
  
  Future<void> cancel() async {
    _isCancelled = true;
    await _subscription?.cancel();
    _subscription = null;
  }
}
