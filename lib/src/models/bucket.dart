/// Represents a Tencent Cloud COS Bucket.
class Bucket {
  /// The name of the bucket
  final String name;
  
  /// The location/region of the bucket
  final String location;
  
  /// The creation date of the bucket
  final DateTime creationDate;
  
  /// The owner of the bucket
  final String? owner;
  
  /// Creates a new Bucket instance
  Bucket({
    required this.name,
    required this.location,
    required this.creationDate,
    this.owner,
  });
  
  /// Create a Bucket from a map (typically from API response)
  factory Bucket.fromMap(Map<String, dynamic> map) {
    return Bucket(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      creationDate: DateTime.tryParse(map['creationDate'] ?? '') ?? DateTime.now(),
      owner: map['owner'],
    );
  }
  
  /// Convert Bucket to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'creationDate': creationDate.toIso8601String(),
      'owner': owner,
    };
  }
}