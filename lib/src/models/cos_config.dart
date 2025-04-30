/// Configuration for Tencent Cloud COS SDK.
class CosConfig {
  /// The secret ID from Tencent Cloud
  final String secretId;
  
  /// The secret key from Tencent Cloud
  final String secretKey;
  
  /// The session token for temporary credentials (optional)
  final String? sessionToken;
  
  /// The COS region (e.g., ap-guangzhou)
  final String region;
  
  /// The Tencent Cloud AppID
  final String appId;
  
  /// Whether this configuration uses temporary credentials
  bool get isTemporary => sessionToken != null;

  /// Create a COS configuration with permanent credentials
  CosConfig.permanent({
    required this.secretId,
    required this.secretKey,
    required this.region,
    required this.appId,
  }) : sessionToken = null;

  /// Create a COS configuration with temporary credentials
  CosConfig.temporary({
    required this.secretId,
    required this.secretKey,
    required this.sessionToken,
    required this.region,
    required this.appId,
  });

  /// Convert configuration to a map for method channel
  Map<String, dynamic> toMap() {
    final map = {
      'secretId': secretId,
      'secretKey': secretKey,
      'region': region,
      'appId': appId,
    };
    
    if (sessionToken != null) {
      map['sessionToken'] = sessionToken!;
    }
    
    return map;
  }
}