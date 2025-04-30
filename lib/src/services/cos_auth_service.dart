import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/models.dart';

/// Service for handling authentication with Tencent Cloud COS.
/// This class provides methods for generating authorization headers
/// and pre-signed URLs for COS API requests.
class CosAuthService {
  final CosConfig _config;
  
  /// Creates a new CosAuthService instance
  CosAuthService(this._config);
  
  /// Generate authorization headers for COS API requests
  Future<Map<String, String>> getAuthorizationHeaders({
    required String httpMethod,
    required String bucketName,
    required String cosPath,
    Map<String, String>? queryParams,
    String? service,
  }) async {
    final headers = <String, String>{
      'Host': service ?? '$bucketName-${_config.appId}.cos.${_config.region}.myqcloud.com',
      'x-cos-meta-uuid': _generateUuid(),
      'x-cos-security-token': _config.sessionToken ?? '',
    };
    
    // Add date header
    final now = DateTime.now().toUtc();
    final dateString = _formatDate(now);
    headers['Date'] = dateString;
    
    // Generate signature
    final signature = _generateSignature(
      httpMethod: httpMethod,
      cosPath: cosPath,
      headers: headers,
      params: queryParams,
      date: now,
    );
    
    // Add Authorization header
    headers['Authorization'] = signature;
    
    return headers;
  }
  
  /// Generate a pre-signed URL for COS object
  Future<String> generatePresignedUrl({
    required String httpMethod,
    required String bucketName,
    required String cosPath,
    required int expirationInSeconds,
  }) async {
    final expiration = DateTime.now().add(Duration(seconds: expirationInSeconds));
    final params = <String, String>{
      'q-sign-algorithm': 'sha1',
      'q-ak': _config.secretId,
      'q-key-time': '${DateTime.now().millisecondsSinceEpoch ~/ 1000};${expiration.millisecondsSinceEpoch ~/ 1000}',
    };
    
    // Generate signing key
    final signKey = _generateSignKey(params['q-key-time']!);
    
    // Generate signature
    final stringToSign = _generateStringToSign(
      httpMethod: httpMethod,
      cosPath: cosPath,
      params: params,
    );
    
    final signature = _hmacSha1(signKey, stringToSign);
    params['q-signature'] = signature;
    
    // Convert params to query string
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    
    return queryString;
  }
  
  /// Format date to RFC 1123 format (required by COS API)
  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = days[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    
    return '$weekday, $day $month $year $hour:$minute:$second GMT';
  }
  
  /// Generate a UUID for request
  String _generateUuid() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random;
  }
  
  /// Generate the signing key for signature
  String _generateSignKey(String keyTime) {
    return _hmacSha1(_config.secretKey, keyTime);
  }
  
  /// Generate string to sign for signature
  String _generateStringToSign({
    required String httpMethod,
    required String cosPath,
    required Map<String, String> params,
  }) {
    final canonicalUri = cosPath.startsWith('/') ? cosPath : '/$cosPath';
    
    // Generate canonical query string
    final canonicalQueryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return [
      params['q-sign-algorithm'],
      params['q-key-time'],
      _sha1('$httpMethod\n$canonicalUri\n$canonicalQueryString\n\n'),
    ].join('\n');
  }
  
  /// Generate signature for COS API requests
  String _generateSignature({
    required String httpMethod,
    required String cosPath,
    required Map<String, String> headers,
    Map<String, String>? params,
    required DateTime date,
  }) {
    final canonicalUri = cosPath.startsWith('/') ? cosPath : '/$cosPath';
    final canonicalQueryString = params?.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&') ?? '';
    
    // Generate canonical headers
    final canonicalHeaders = headers.entries
        .map((e) => '${e.key.toLowerCase()}:${e.value.trim()}')
        .join('\n');
    
    // Generate signed headers
    final signedHeaders = headers.keys
        .map((e) => e.toLowerCase())
        .join(';');
    
    // Generate canonical request
    final canonicalRequest = [
      httpMethod,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      '',
      signedHeaders,
      '', // Empty payload hash
    ].join('\n');
    
    // Generate start and end time
    final startTime = date.millisecondsSinceEpoch ~/ 1000;
    final endTime = startTime + 3600; // Valid for 1 hour
    
    // Generate key time
    final keyTime = '$startTime;$endTime';
    
    // Generate signing key
    final signKey = _hmacSha1(_config.secretKey, keyTime);
    
    // Generate string to sign
    final stringToSign = [
      'sha1',
      keyTime,
      _sha1(canonicalRequest),
      '',
    ].join('\n');
    
    // Generate signature
    final signature = _hmacSha1(signKey, stringToSign);
    
    // Generate authorization
    return 'q-sign-algorithm=sha1&q-ak=${_config.secretId}&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=$signedHeaders&q-url-param-list=&q-signature=$signature';
  }
  
  /// Generate SHA1 hash of a string
  String _sha1(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
  
  /// Generate HMAC-SHA1 signature
  String _hmacSha1(String key, String input) {
    final keyBytes = utf8.encode(key);
    final inputBytes = utf8.encode(input);
    final hmacSha1 = Hmac(sha1, keyBytes);
    final digest = hmacSha1.convert(inputBytes);
    return digest.toString();
  }
}