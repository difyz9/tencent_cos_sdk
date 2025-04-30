import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'cos_service.dart';
import 'cos_auth_service.dart';

/// Implementation of COS service using pure Dart HTTP requests.
/// 
/// This implementation is used as a fallback when native SDK implementations
/// are not available for the current platform, or for platforms that don't
/// have official Tencent COS SDKs.
class CosServiceDart implements CosService {
  late CosConfig _config;
  late CosAuthService _authService;
  final String _apiEndpoint = 'cos.{region}.myqcloud.com';
  
  @override
  Future<void> initialize(CosConfig config) async {
    _config = config;
    _authService = CosAuthService(config);
  }
  
  String _getEndpoint(String bucketName) {
    final endpoint = _apiEndpoint.replaceAll('{region}', _config.region);
    return 'https://$bucketName-${_config.appId}.$endpoint';
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> uploadFile({
    required String bucketName,
    required String cosPath,
    required String filePath,
    void Function(int completed, int total)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return CosResponse.error(
          CosError(code: 'FileNotFound', message: 'The file $filePath does not exist')
        );
      }
      
      final data = await file.readAsBytes();
      return uploadData(
        bucketName: bucketName,
        cosPath: cosPath,
        data: data,
        onProgress: onProgress,
      );
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'UploadError', message: e.toString())
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
    try {
      final url = Uri.parse('${_getEndpoint(bucketName)}/${_sanitizePath(cosPath)}');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'PUT',
        bucketName: bucketName,
        cosPath: cosPath,
      );
      
      // For large files, we might implement a chunked upload with progress reporting
      int totalBytes = data.length;
      int sentBytes = 0;
      
      // Simple upload for now - in a real implementation we would use a
      // multipart request with progress tracking
      final response = await http.put(
        url,
        headers: headers,
        body: data,
      );
      
      if (onProgress != null) {
        onProgress(totalBytes, totalBytes);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CosResponse.success({
          'eTag': response.headers['etag']?.replaceAll('"', '') ?? '',
          'statusCode': response.statusCode,
        });
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'UploadError', message: e.toString())
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
    try {
      final url = Uri.parse('${_getEndpoint(bucketName)}/${_sanitizePath(cosPath)}');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'GET',
        bucketName: bucketName,
        cosPath: cosPath,
      );
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        
        if (onProgress != null) {
          onProgress(response.bodyBytes.length, response.bodyBytes.length);
        }
        
        return CosResponse.success({
          'filePath': savePath,
          'size': response.bodyBytes.length,
        });
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'DownloadError', message: e.toString())
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> deleteObject({
    required String bucketName,
    required String cosPath,
  }) async {
    try {
      final url = Uri.parse('${_getEndpoint(bucketName)}/${_sanitizePath(cosPath)}');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'DELETE',
        bucketName: bucketName,
        cosPath: cosPath,
      );
      
      final response = await http.delete(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CosResponse.success({'deleted': true});
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'DeleteError', message: e.toString())
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
    try {
      final queryParams = <String, String>{};
      if (prefix != null) queryParams['prefix'] = prefix;
      if (delimiter != null) queryParams['delimiter'] = delimiter;
      if (maxKeys != null) queryParams['max-keys'] = maxKeys.toString();
      
      final uri = Uri.https(
        '$bucketName-${_config.appId}.cos.${_config.region}.myqcloud.com',
        '/',
        queryParams,
      );
      
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'GET',
        bucketName: bucketName,
        cosPath: '/',
        queryParams: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final xmlContent = response.body;
        // In a real implementation, we would parse the XML response
        // For simplicity, we're returning an empty list
        return CosResponse.success([]);
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'ListObjectsError', message: e.toString())
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> createBucket({
    required String bucketName,
  }) async {
    try {
      final url = Uri.parse('https://$bucketName-${_config.appId}.cos.${_config.region}.myqcloud.com/');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'PUT',
        bucketName: bucketName,
        cosPath: '/',
      );
      
      final response = await http.put(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CosResponse.success({'created': true});
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'CreateBucketError', message: e.toString())
      );
    }
  }
  
  @override
  Future<CosResponse<Map<String, dynamic>>> deleteBucket({
    required String bucketName,
  }) async {
    try {
      final url = Uri.parse('https://$bucketName-${_config.appId}.cos.${_config.region}.myqcloud.com/');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'DELETE',
        bucketName: bucketName,
        cosPath: '/',
      );
      
      final response = await http.delete(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CosResponse.success({'deleted': true});
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'DeleteBucketError', message: e.toString())
      );
    }
  }
  
  @override
  Future<CosResponse<List<Bucket>>> listBuckets() async {
    try {
      final url = Uri.parse('https://service.cos.myqcloud.com/');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'GET',
        bucketName: '',
        cosPath: '/',
        service: 'service.cos.myqcloud.com',
      );
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final xmlContent = response.body;
        // In a real implementation, we would parse the XML response
        // For simplicity, we're returning an empty list
        return CosResponse.success([]);
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'ListBucketsError', message: e.toString())
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
    final url = '${_getEndpoint(bucketName)}/${_sanitizePath(cosPath)}';
    final signature = await _authService.generatePresignedUrl(
      httpMethod: httpMethod,
      bucketName: bucketName,
      cosPath: cosPath,
      expirationInSeconds: expirationInSeconds,
    );
    
    return '$url?$signature';
  }
  
  @override
  Future<bool> doesObjectExist({
    required String bucketName,
    required String cosPath,
  }) async {
    try {
      final url = Uri.parse('${_getEndpoint(bucketName)}/${_sanitizePath(cosPath)}');
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'HEAD',
        bucketName: bucketName,
        cosPath: cosPath,
      );
      
      final response = await http.head(
        url,
        headers: headers,
      );
      
      return response.statusCode >= 200 && response.statusCode < 300;
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
    try {
      final url = Uri.parse('${_getEndpoint(destinationBucketName)}/${_sanitizePath(destinationCosPath)}');
      final sourceUrl = '/$sourceBucketName-${_config.appId}/${_sanitizePath(sourceCosPath)}';
      
      final headers = await _authService.getAuthorizationHeaders(
        httpMethod: 'PUT',
        bucketName: destinationBucketName,
        cosPath: destinationCosPath,
      );
      
      // Add the source header
      headers['x-cos-copy-source'] = sourceUrl;
      
      final response = await http.put(
        url,
        headers: headers,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CosResponse.success({'copied': true});
      } else {
        final error = _parseErrorResponse(response);
        return CosResponse.error(error);
      }
    } catch (e) {
      return CosResponse.error(
        CosError(code: 'CopyObjectError', message: e.toString())
      );
    }
  }
  
  /// Sanitize a path by removing leading slashes
  String _sanitizePath(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }
  
  /// Parse error response from COS API
  CosError _parseErrorResponse(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        // Attempt to parse XML error response
        // In a real implementation, we would use an XML parser
        // For simplicity, we're just extracting basic info
        return CosError(
          code: 'HttpError',
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
          requestId: response.headers['x-cos-request-id'],
        );
      }
    } catch (_) {
      // Fallback if parsing fails
    }
    
    return CosError(
      code: 'HttpError',
      message: 'Request failed with status: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
}