/// Represents an error that occurred during a Tencent COS operation.
class CosError {
  /// Error code
  final String code;
  
  /// Error message
  final String message;
  
  /// Optional HTTP status code
  final int? statusCode;
  
  /// Optional request ID for tracing issues
  final String? requestId;
  
  /// Creates a new CosError instance
  CosError({
    required this.code,
    required this.message,
    this.statusCode,
    this.requestId,
  });
  
  /// Create a CosError from a map (typically from API response)
  factory CosError.fromMap(Map<String, dynamic> map) {
    return CosError(
      code: map['code'] ?? 'unknown',
      message: map['message'] ?? 'Unknown error occurred',
      statusCode: map['statusCode'] is int ? map['statusCode'] : int.tryParse(map['statusCode']?.toString() ?? ''),
      requestId: map['requestId'],
    );
  }
  
  /// Convert CosError to a map
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'statusCode': statusCode,
      'requestId': requestId,
    };
  }
  
  @override
  String toString() {
    return 'CosError: [$code] $message' + 
      (statusCode != null ? ' (Status: $statusCode)' : '') +
      (requestId != null ? ' (RequestId: $requestId)' : '');
  }
}