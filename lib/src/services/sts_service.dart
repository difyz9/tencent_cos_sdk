import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import '../models/models.dart';
import '../enums/enums.dart';
import '../exceptions/exceptions.dart';

/// STS (Security Token Service) integration for temporary credentials
class STSService {
  static const String _stsEndpoint = 'https://sts.tencentcloudapi.com/';
  
  final String _secretId;
  final String _secretKey;
  final String _region;
  
  STSService({
    required String secretId,
    required String secretKey,
    required String region,
  }) : _secretId = secretId,
       _secretKey = secretKey,
       _region = region;

  /// Get temporary credentials for COS operations
  /// 
  /// [durationSeconds] - Duration for which the credentials are valid (900-7200 seconds)
  /// [allowedActions] - List of allowed COS actions (e.g., ['cos:GetObject', 'cos:PutObject'])
  /// [bucketName] - Optional bucket name to restrict access to specific bucket
  /// [appId] - Tencent Cloud AppID
  Future<TemporaryCredentials> getTemporaryCredentials({
    required int durationSeconds,
    required List<String> allowedActions,
    required String appId,
    String? bucketName,
    String? resourcePath,
  }) async {
    if (durationSeconds < 900 || durationSeconds > 7200) {
      throw ArgumentError('Duration must be between 900 and 7200 seconds');
    }

    final policy = _buildPolicy(
      allowedActions: allowedActions, 
      bucketName: bucketName,
      appId: appId,
      resourcePath: resourcePath,
    );
    
    final params = {
      'Action': 'GetFederationToken',
      'Version': '2018-08-13',
      'Region': _region,
      'Name': 'cos-flutter-sdk-${DateTime.now().millisecondsSinceEpoch}',
      'Policy': Uri.encodeComponent(jsonEncode(policy)),
      'DurationSeconds': durationSeconds.toString(),
    };

    final response = await _makeSTSRequest(params);
    
    if (response['Response']?['Error'] != null) {
      final error = response['Response']['Error'];
      throw STSException(
        code: error['Code'] ?? 'UnknownError',
        message: error['Message'] ?? 'Unknown STS error occurred',
      );
    }

    final credentials = response['Response']['Credentials'];
    final expiration = DateTime.parse(credentials['Expiration']);
    
    return TemporaryCredentials(
      tmpSecretId: credentials['TmpSecretId'],
      tmpSecretKey: credentials['TmpSecretKey'],
      sessionToken: credentials['Token'],
      expiredTime: expiration,
    );
  }

  /// Get temporary credentials specifically for bucket operations
  Future<TemporaryCredentials> getBucketOperationCredentials({
    required String appId,
    String? bucketName,
    required List<BucketOperation> operations,
    int durationSeconds = 3600,
  }) async {
    final actions = operations.map((op) => op.action).toList();
    
    return getTemporaryCredentials(
      durationSeconds: durationSeconds,
      allowedActions: actions,
      appId: appId,
      bucketName: bucketName,
    );
  }

  /// Get temporary credentials for object operations with bucket access
  Future<TemporaryCredentials> getObjectOperationCredentials({
    required String appId,
    required String bucketName,
    String? objectPrefix,
    required List<ObjectOperation> operations,
    int durationSeconds = 3600,
  }) async {
    final actions = operations.map((op) => op.action).toList();
    
    return getTemporaryCredentials(
      durationSeconds: durationSeconds,
      allowedActions: actions,
      appId: appId,
      bucketName: bucketName,
      resourcePath: objectPrefix,
    );
  }

  /// Build policy document for STS
  Map<String, dynamic> _buildPolicy({
    required List<String> allowedActions,
    required String appId,
    String? bucketName,
    String? resourcePath,
  }) {
    String resource;
    
    if (bucketName != null) {
      if (resourcePath != null) {
        // Specific object or prefix
        resource = 'qcs::cos:*:uid/$appId:prefix//$appId/$bucketName/$resourcePath';
      } else {
        // Entire bucket
        resource = 'qcs::cos:*:uid/$appId:prefix//$appId/$bucketName/*';
      }
    } else {
      // All buckets (use with caution)
      resource = 'qcs::cos:*:uid/$appId:prefix//$appId/*';
    }

    return {
      'version': '2.0',
      'statement': [
        {
          'effect': 'allow',
          'action': allowedActions,
          'resource': resource,
        }
      ],
    };
  }

  /// Make authenticated request to STS API
  Future<Map<String, dynamic>> _makeSTSRequest(Map<String, String> params) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Host': 'sts.tencentcloudapi.com',
      'X-TC-Action': params['Action']!,
      'X-TC-Version': params['Version']!,
      'X-TC-Region': params['Region']!,
      'X-TC-Timestamp': timestamp.toString(),
    };

    // Generate authorization
    final authorization = _generateSTSAuthorization(
      params: params,
      headers: headers,
      timestamp: timestamp,
    );
    headers['Authorization'] = authorization;

    final body = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await http.post(
      Uri.parse(_stsEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw STSException(
        code: 'HTTP_ERROR',
        message: 'STS request failed with status code: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body);
  }

  /// Generate authorization header for STS API
  String _generateSTSAuthorization({
    required Map<String, String> params,
    required Map<String, String> headers,
    required int timestamp,
  }) {
    // This is a simplified implementation
    // In production, you should implement the full Tencent Cloud API signature algorithm
    const algorithm = 'TC3-HMAC-SHA256';
    const service = 'sts';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toUtc();
    final dateString = date.toIso8601String().substring(0, 10);

    // Create credential scope
    final credentialScope = '$dateString/$service/tc3_request';

    // Create string to sign (simplified)
    final stringToSign = '$algorithm\n$timestamp\n$credentialScope\nHASH_PLACEHOLDER';

    // Generate signing key (simplified)
    final signingKey = _hmacSha256(_secretKey, dateString);

    // Generate signature (simplified)
    final signature = _hmacSha256(signingKey, stringToSign);

    return '$algorithm Credential=$_secretId/$credentialScope, SignedHeaders=content-type;host, Signature=$signature';
  }

  /// HMAC-SHA256 helper
  String _hmacSha256(String key, String data) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }
}
