/// Enumeration of bucket operations for STS permission control
enum BucketOperation {
  /// List objects in bucket
  listObjects('cos:GetBucket'),
  
  /// Create bucket
  createBucket('cos:PutBucket'),
  
  /// Delete bucket
  deleteBucket('cos:DeleteBucket'),
  
  /// Get bucket ACL
  getBucketACL('cos:GetBucketACL'),
  
  /// Set bucket ACL
  putBucketACL('cos:PutBucketACL'),
  
  /// Get bucket CORS
  getBucketCORS('cos:GetBucketCORS'),
  
  /// Set bucket CORS
  putBucketCORS('cos:PutBucketCORS'),
  
  /// Delete bucket CORS
  deleteBucketCORS('cos:DeleteBucketCORS'),
  
  /// Get bucket lifecycle
  getBucketLifecycle('cos:GetBucketLifecycle'),
  
  /// Set bucket lifecycle
  putBucketLifecycle('cos:PutBucketLifecycle'),
  
  /// Delete bucket lifecycle
  deleteBucketLifecycle('cos:DeleteBucketLifecycle'),
  
  /// Get bucket tagging
  getBucketTagging('cos:GetBucketTagging'),
  
  /// Set bucket tagging
  putBucketTagging('cos:PutBucketTagging'),
  
  /// Delete bucket tagging
  deleteBucketTagging('cos:DeleteBucketTagging'),
  
  /// All bucket operations (use with caution)
  all('cos:*');

  const BucketOperation(this.action);
  
  /// The COS action string for this operation
  final String action;
}
