/// Represents an object in Tencent Cloud COS.
class CosObject {
  /// The key (path) of the object
  final String key;
  
  /// The last modified date of the object
  final DateTime lastModified;
  
  /// The ETag of the object
  final String eTag;
  
  /// The size of the object in bytes
  final int size;
  
  /// The owner of the object
  final String? owner;
  
  /// The storage class of the object
  final String? storageClass;
  
  /// Creates a new CosObject instance
  CosObject({
    required this.key,
    required this.lastModified,
    required this.eTag,
    required this.size,
    this.owner,
    this.storageClass,
  });
  
  /// Create a CosObject from a map (typically from API response)
  factory CosObject.fromMap(Map<String, dynamic> map) {
    return CosObject(
      key: map['key'] ?? '',
      lastModified: DateTime.tryParse(map['lastModified'] ?? '') ?? DateTime.now(),
      eTag: map['eTag'] ?? '',
      size: map['size'] is int ? map['size'] : int.tryParse(map['size']?.toString() ?? '0') ?? 0,
      owner: map['owner'],
      storageClass: map['storageClass'],
    );
  }
  
  /// Convert CosObject to a map
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'lastModified': lastModified.toIso8601String(),
      'eTag': eTag,
      'size': size,
      'owner': owner,
      'storageClass': storageClass,
    };
  }
}