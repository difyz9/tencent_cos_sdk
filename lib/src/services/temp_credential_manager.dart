import 'dart:async';
import 'dart:developer' as developer;
import '../enums/enums.dart';
import '../models/models.dart';
import 'sts_service.dart';

/// 临时密钥管理器
/// 自动管理临时凭证的获取和刷新
class TempCredentialManager {
  final STSService _stsService;
  final String _appId;
  TemporaryCredentials? _currentCredentials;
  Timer? _refreshTimer;
  final Duration _refreshThreshold;
  
  /// 创建临时密钥管理器
  /// 
  /// [stsService] STS服务实例
  /// [appId] 腾讯云AppID
  /// [refreshThreshold] 提前刷新时间（默认5分钟前刷新）
  TempCredentialManager(
    this._stsService,
    this._appId, {
    Duration refreshThreshold = const Duration(minutes: 5),
  }) : _refreshThreshold = refreshThreshold;

  /// 获取当前有效的临时凭证
  /// 如果凭证不存在或即将过期，会自动刷新
  Future<TemporaryCredentials> getCurrentCredentials({
    List<BucketOperation>? bucketOperations,
    List<ObjectOperation>? objectOperations,
    String? bucketName,
    String? objectKey,
    Duration validDuration = const Duration(hours: 1),
  }) async {
    // 检查当前凭证是否有效
    if (_isCredentialsValid()) {
      return _currentCredentials!;
    }

    // 根据操作类型获取新的临时凭证
    if (bucketOperations != null && bucketOperations.isNotEmpty) {
      _currentCredentials = await _stsService.getBucketOperationCredentials(
        appId: _appId,
        bucketName: bucketName,
        operations: bucketOperations,
        durationSeconds: validDuration.inSeconds,
      );
    } else if (objectOperations != null && objectOperations.isNotEmpty) {
      _currentCredentials = await _stsService.getObjectOperationCredentials(
        appId: _appId,
        bucketName: bucketName ?? '',
        objectPrefix: objectKey,
        operations: objectOperations,
        durationSeconds: validDuration.inSeconds,
      );
    } else {
      // 默认获取基本的临时凭证
      final actions = ['cos:GetObject', 'cos:PutObject', 'cos:DeleteObject'];
      _currentCredentials = await _stsService.getTemporaryCredentials(
        durationSeconds: validDuration.inSeconds,
        allowedActions: actions,
        appId: _appId,
        bucketName: bucketName,
        resourcePath: objectKey,
      );
    }

    // 设置自动刷新定时器
    _scheduleRefresh();

    return _currentCredentials!;
  }

  /// 强制刷新凭证
  Future<TemporaryCredentials> refreshCredentials({
    List<BucketOperation>? bucketOperations,
    List<ObjectOperation>? objectOperations,
    String? bucketName,
    String? objectKey,
    Duration validDuration = const Duration(hours: 1),
  }) async {
    _cancelRefreshTimer();
    
    // 根据操作类型获取新的临时凭证
    if (bucketOperations != null && bucketOperations.isNotEmpty) {
      _currentCredentials = await _stsService.getBucketOperationCredentials(
        appId: _appId,
        bucketName: bucketName,
        operations: bucketOperations,
        durationSeconds: validDuration.inSeconds,
      );
    } else if (objectOperations != null && objectOperations.isNotEmpty) {
      _currentCredentials = await _stsService.getObjectOperationCredentials(
        appId: _appId,
        bucketName: bucketName ?? '',
        objectPrefix: objectKey,
        operations: objectOperations,
        durationSeconds: validDuration.inSeconds,
      );
    } else {
      // 默认获取基本的临时凭证
      final actions = ['cos:GetObject', 'cos:PutObject', 'cos:DeleteObject'];
      _currentCredentials = await _stsService.getTemporaryCredentials(
        durationSeconds: validDuration.inSeconds,
        allowedActions: actions,
        appId: _appId,
        bucketName: bucketName,
        resourcePath: objectKey,
      );
    }

    _scheduleRefresh();
    return _currentCredentials!;
  }

  /// 获取存储桶操作凭证
  Future<TemporaryCredentials> getBucketCredentials(
    String bucketName, {
    List<BucketOperation>? operations,
    Duration validDuration = const Duration(hours: 1),
  }) async {
    return getCurrentCredentials(
      bucketOperations: operations ?? [
        BucketOperation.createBucket,
        BucketOperation.deleteBucket,
        BucketOperation.listObjects,
        BucketOperation.getBucketACL,
        BucketOperation.putBucketACL,
      ],
      bucketName: bucketName,
      validDuration: validDuration,
    );
  }

  /// 获取对象操作凭证
  Future<TemporaryCredentials> getObjectCredentials(
    String bucketName,
    String objectKey, {
    List<ObjectOperation>? operations,
    Duration validDuration = const Duration(hours: 1),
  }) async {
    return getCurrentCredentials(
      objectOperations: operations ?? [
        ObjectOperation.getObject,
        ObjectOperation.putObject,
        ObjectOperation.deleteObject,
        ObjectOperation.copyObject,
      ],
      bucketName: bucketName,
      objectKey: objectKey,
      validDuration: validDuration,
    );
  }

  /// 检查当前凭证是否有效
  bool _isCredentialsValid() {
    if (_currentCredentials == null) return false;
    
    final now = DateTime.now();
    final expiry = _currentCredentials!.expiredTime;
    
    // 如果距离过期时间小于刷新阈值，认为需要刷新
    return expiry.difference(now) > _refreshThreshold;
  }

  /// 安排自动刷新
  void _scheduleRefresh() {
    _cancelRefreshTimer();
    
    if (_currentCredentials == null) return;
    
    final now = DateTime.now();
    final expiry = _currentCredentials!.expiredTime;
    final refreshTime = expiry.subtract(_refreshThreshold);
    
    if (refreshTime.isAfter(now)) {
      final delay = refreshTime.difference(now);
      _refreshTimer = Timer(delay, () {
        developer.log('Auto refreshing temporary credentials');
        refreshCredentials().catchError((error) {
          developer.log('Failed to auto refresh credentials: $error');
          // Return expired credentials to trigger manual refresh on next use
          return _currentCredentials!;
        });
      });
    }
  }

  /// 取消刷新定时器
  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 销毁管理器，清理资源
  void dispose() {
    _cancelRefreshTimer();
    _currentCredentials = null;
  }

  /// 获取当前凭证状态
  CredentialStatus get status {
    if (_currentCredentials == null) {
      return CredentialStatus.notInitialized;
    }
    
    final now = DateTime.now();
    final expiry = _currentCredentials!.expiredTime;
    
    if (expiry.isBefore(now)) {
      return CredentialStatus.expired;
    } else if (expiry.difference(now) <= _refreshThreshold) {
      return CredentialStatus.nearExpiry;
    } else {
      return CredentialStatus.valid;
    }
  }
}

/// 凭证状态枚举
enum CredentialStatus {
  /// 未初始化
  notInitialized,
  /// 有效
  valid,
  /// 即将过期
  nearExpiry,
  /// 已过期
  expired,
}
