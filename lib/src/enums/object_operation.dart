/// Enumeration of object operations for STS permission control
enum ObjectOperation {
  /// Get object
  getObject('cos:GetObject'),
  
  /// Put object
  putObject('cos:PutObject'),
  
  /// Delete object
  deleteObject('cos:DeleteObject'),
  
  /// Get object ACL
  getObjectACL('cos:GetObjectACL'),
  
  /// Set object ACL
  putObjectACL('cos:PutObjectACL'),
  
  /// Copy object
  copyObject('cos:PutObject'),
  
  /// Get object tagging
  getObjectTagging('cos:GetObjectTagging'),
  
  /// Set object tagging
  putObjectTagging('cos:PutObjectTagging'),
  
  /// Delete object tagging
  deleteObjectTagging('cos:DeleteObjectTagging'),
  
  /// Restore archived object
  restoreObject('cos:RestoreObject'),
  
  /// Multipart upload init
  initiateMultipartUpload('cos:InitiateMultipartUpload'),
  
  /// Multipart upload part
  uploadPart('cos:UploadPart'),
  
  /// Complete multipart upload
  completeMultipartUpload('cos:CompleteMultipartUpload'),
  
  /// Abort multipart upload
  abortMultipartUpload('cos:AbortMultipartUpload'),
  
  /// List multipart uploads
  listMultipartUploads('cos:ListMultipartUploads'),
  
  /// List parts
  listParts('cos:ListParts'),
  
  /// All object operations (use with caution)
  all('cos:*');

  const ObjectOperation(this.action);
  
  /// The COS action string for this operation
  final String action;
}
