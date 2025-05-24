/// Exception thrown by STS service operations
class STSException implements Exception {
  /// Error code
  final String code;
  
  /// Error message
  final String message;
  
  /// Optional details
  final dynamic details;
  
  STSException({
    required this.code,
    required this.message,
    this.details,
  });
  
  @override
  String toString() {
    return 'STSException($code): $message${details != null ? ' - Details: $details' : ''}';
  }
}
