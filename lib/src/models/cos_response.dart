import 'cos_error.dart';

/// Represents a standardized response from Tencent COS operations.
class CosResponse<T> {
  /// Whether the operation was successful
  final bool success;
  
  /// The data returned from the operation (if successful)
  final T? data;
  
  /// Error information (if operation failed)
  final CosError? error;
  
  /// Creates a successful CosResponse
  CosResponse.success(this.data) 
    : success = true,
      error = null;
  
  /// Creates a failed CosResponse
  CosResponse.error(this.error) 
    : success = false,
      data = null;
  
  /// Create a CosResponse from a map (typically from method channel)
  factory CosResponse.fromMap(Map<String, dynamic> map, T Function(Map<String, dynamic>) fromMap) {
    final success = map['success'] == true;
    
    if (success) {
      final data = map['data'] != null ? fromMap(map['data']) : null;
      return CosResponse.success(data);
    } else {
      final error = map['error'] != null 
          ? CosError.fromMap(map['error'])
          : CosError(code: 'unknown', message: 'Unknown error');
      return CosResponse.error(error);
    }
  }
  
  /// Convert CosResponse to a map
  Map<String, dynamic> toMap([Map<String, dynamic> Function(T)? toMap]) {
    return {
      'success': success,
      'data': success && data != null && toMap != null ? toMap(data as T) : data,
      'error': !success && error != null ? error!.toMap() : null,
    };
  }
  
  @override
  String toString() {
    if (success) {
      return 'CosResponse: Success - Data: $data';
    } else {
      return 'CosResponse: Failed - Error: $error';
    }
  }
}