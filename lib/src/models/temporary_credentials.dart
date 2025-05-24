import 'cos_config.dart';

/// Temporary credentials returned by STS service
class TemporaryCredentials {
  /// Temporary secret ID
  final String tmpSecretId;
  
  /// Temporary secret key
  final String tmpSecretKey;
  
  /// Session token
  final String sessionToken;
  
  /// Expiration time
  final DateTime expiredTime;

  TemporaryCredentials({
    required this.tmpSecretId,
    required this.tmpSecretKey,
    required this.sessionToken,
    required this.expiredTime,
  });

  /// Alternative constructor for compatibility
  TemporaryCredentials.fromMap({
    required String secretId,
    required String secretKey,
    required this.sessionToken,
    required DateTime expiration,
  }) : tmpSecretId = secretId,
       tmpSecretKey = secretKey,
       expiredTime = expiration;

  /// Check if credentials are expired or will expire within the next minute
  bool get isExpired => DateTime.now().isAfter(expiredTime.subtract(Duration(minutes: 1)));

  /// Get remaining time until expiration
  Duration get remainingTime => expiredTime.difference(DateTime.now());

  /// Create CosConfig from temporary credentials
  CosConfig toCosConfig({
    required String region,
    required String appId,
  }) {
    return CosConfig.temporary(
      secretId: tmpSecretId,
      secretKey: tmpSecretKey,
      sessionToken: sessionToken,
      region: region,
      appId: appId,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'tmpSecretId': tmpSecretId,
      'tmpSecretKey': tmpSecretKey,
      'sessionToken': sessionToken,
      'expiredTime': expiredTime.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory TemporaryCredentials.fromJson(Map<String, dynamic> json) {
    return TemporaryCredentials(
      tmpSecretId: json['tmpSecretId'] ?? json['secretId'],
      tmpSecretKey: json['tmpSecretKey'] ?? json['secretKey'],
      sessionToken: json['sessionToken'],
      expiredTime: DateTime.parse(json['expiredTime'] ?? json['expiration']),
    );
  }
}
