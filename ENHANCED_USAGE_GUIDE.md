# 增强版 Tencent COS SDK 使用指南

## 概述

增强版 `tencent_cos_sdk` 新增了基于临时凭证的完整存储桶操作能力，提供更安全、灵活的云存储访问方案。

## 新特性

1. **STS (Security Token Service) 集成** - 安全的临时凭证获取
2. **自动凭证管理** - 智能的凭证刷新机制  
3. **权限精细控制** - 按需申请最小权限
4. **增强版操作工具** - 基于临时凭证的完整存储桶操作

## 安装依赖

在您的 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  tencent_cos_sdk:
    path: /path/to/enhanced/tencent_cos_sdk
  http: ^1.1.0  # STS 服务需要
  crypto: ^3.0.3  # 签名算法需要
```

## 快速开始

### 1. 基础配置

```dart
import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';

// 配置您的腾讯云信息
const String secretId = 'your_secret_id';
const String secretKey = 'your_secret_key';
const String region = 'ap-guangzhou';
const String appId = 'your_app_id';
const String stsEndpoint = 'https://sts.tencentcloudapi.com';
```

### 2. 创建 STS 服务

```dart
// 创建 STS 服务实例
final stsService = STSService(
  secretId: secretId,
  secretKey: secretKey,
  region: region,
  endpoint: stsEndpoint,
);
```

### 3. 创建临时凭证管理器

```dart
// 创建自动管理临时凭证的管理器
final credentialManager = TempCredentialManager(
  stsService,
  refreshThreshold: Duration(minutes: 5), // 提前5分钟刷新
);
```

### 4. 创建增强版操作工具

```dart
// 创建增强版存储桶操作工具
final bucketOperator = EnhancedBucketOperator(
  credentialManager: credentialManager,
  region: region,
  appId: appId,
);
```

## 使用示例

### 存储桶操作

```dart
// 创建存储桶
try {
  final success = await bucketOperator.createBucket('my-test-bucket');
  if (success) {
    print('存储桶创建成功');
  }
} catch (e) {
  print('创建失败: $e');
}

// 检查存储桶是否存在
final exists = await bucketOperator.doesBucketExist('my-test-bucket');
print('存储桶存在: $exists');

// 列出存储桶中的对象
final objects = await bucketOperator.listObjects(
  'my-test-bucket',
  prefix: 'images/',  // 可选：只列出特定前缀的对象
  maxKeys: 100,       // 可选：最大返回数量
);
print('找到 ${objects.length} 个对象');
```

### 对象操作

```dart
// 上传文本数据
final uploadSuccess = await bucketOperator.putObject(
  'my-test-bucket',
  'test.txt',
  'Hello, World!',
  metadata: {'Content-Type': 'text/plain'},
);

// 上传文件
final file = File('/path/to/local/file.jpg');
final fileUploadSuccess = await bucketOperator.putObjectFromFile(
  'my-test-bucket',
  'images/photo.jpg',
  file,
  metadata: {'Content-Type': 'image/jpeg'},
);

// 下载对象
final data = await bucketOperator.getObject('my-test-bucket', 'test.txt');
if (data != null) {
  final content = String.fromCharCodes(data);
  print('文件内容: $content');
}

// 下载到本地文件
final downloadSuccess = await bucketOperator.downloadObject(
  'my-test-bucket',
  'images/photo.jpg',
  '/path/to/save/photo.jpg',
);

// 删除对象
final deleteSuccess = await bucketOperator.deleteObject(
  'my-test-bucket',
  'test.txt',
);
```

### 高级操作

```dart
// 复制对象
final copySuccess = await bucketOperator.copyObject(
  'source-bucket',
  'source/file.txt',
  'destination-bucket',
  'dest/file.txt',
);

// 批量删除
final deletedObjects = await bucketOperator.deleteObjects(
  'my-test-bucket',
  ['file1.txt', 'file2.txt', 'file3.txt'],
);
print('删除了 ${deletedObjects.length} 个对象');

// 获取预签名URL（用于直接访问）
final presignedUrl = await bucketOperator.getPresignedUrl(
  'my-test-bucket',
  'images/photo.jpg',
  validDuration: Duration(hours: 2),
  httpMethod: 'GET',
);
print('预签名URL: $presignedUrl');

// 检查对象是否存在
final objectExists = await bucketOperator.doesObjectExist(
  'my-test-bucket',
  'test.txt',
);

// 获取对象元数据
final metadata = await bucketOperator.getObjectMetadata(
  'my-test-bucket',
  'test.txt',
);
```

## 权限控制

### 精细化权限申请

```dart
// 只申请读取权限
final readOnlyCredentials = await credentialManager.getObjectCredentials(
  'my-bucket',
  'my-file.txt',
  operations: [ObjectOperation.getObject],
  validDuration: Duration(minutes: 30),
);

// 只申请存储桶管理权限
final bucketManageCredentials = await credentialManager.getBucketCredentials(
  'my-bucket',
  operations: [
    BucketOperation.createBucket,
    BucketOperation.deleteBucket,
    BucketOperation.getBucketLocation,
  ],
  validDuration: Duration(hours: 1),
);

// 申请特定对象的完整权限
final fullObjectCredentials = await credentialManager.getObjectCredentials(
  'my-bucket',
  'important-file.pdf',
  operations: [
    ObjectOperation.getObject,
    ObjectOperation.putObject,
    ObjectOperation.deleteObject,
    ObjectOperation.copyObject,
  ],
);
```

### 手动凭证管理

```dart
// 检查凭证状态
switch (credentialManager.status) {
  case CredentialStatus.valid:
    print('凭证有效');
    break;
  case CredentialStatus.nearExpiry:
    print('凭证即将过期');
    break;
  case CredentialStatus.expired:
    print('凭证已过期');
    break;
  case CredentialStatus.notInitialized:
    print('凭证未初始化');
    break;
}

// 强制刷新凭证
final newCredentials = await credentialManager.refreshCredentials(
  bucketOperations: [BucketOperation.listObjects],
  validDuration: Duration(hours: 2),
);
```

## 错误处理

```dart
try {
  await bucketOperator.createBucket('my-bucket');
} on STSException catch (stsError) {
  // STS 相关错误
  print('STS错误: ${stsError.message}');
  print('错误代码: ${stsError.code}');
} on COSError catch (cosError) {
  // COS 操作错误
  print('COS错误: ${cosError.message}');
  print('状态码: ${cosError.statusCode}');
} catch (e) {
  // 其他错误
  print('未知错误: $e');
}
```

## 最佳实践

### 1. 资源管理

```dart
class MyStorageService {
  late final EnhancedBucketOperator _bucketOperator;
  
  Future<void> initialize() async {
    final stsService = STSService(
      secretId: secretId,
      secretKey: secretKey,
      region: region,
      endpoint: stsEndpoint,
    );
    
    final credentialManager = TempCredentialManager(stsService);
    
    _bucketOperator = EnhancedBucketOperator(
      credentialManager: credentialManager,
      region: region,
      appId: appId,
    );
  }
  
  // 在应用退出时清理资源
  void dispose() {
    _bucketOperator.dispose();
  }
}
```

### 2. 批量操作优化

```dart
// 对于大量操作，复用凭证可以提高性能
Future<void> batchUpload(List<File> files, String bucketName) async {
  // 一次性获取批量上传权限
  final credentials = await credentialManager.getBucketCredentials(
    bucketName,
    operations: [BucketOperation.listObjects],
    validDuration: Duration(hours: 2), // 较长的有效期
  );
  
  for (final file in files) {
    await bucketOperator.putObjectFromFile(
      bucketName,
      'uploads/${file.name}',
      file,
    );
  }
}
```

### 3. 安全考虑

```dart
// 为不同操作申请最小权限
class SecureStorageManager {
  final TempCredentialManager _credentialManager;
  
  SecureStorageManager(this._credentialManager);
  
  // 只读访问
  Future<Uint8List?> secureRead(String bucket, String key) async {
    final credentials = await _credentialManager.getObjectCredentials(
      bucket,
      key,
      operations: [ObjectOperation.getObject], // 只申请读权限
      validDuration: Duration(minutes: 10),    // 短期有效
    );
    
    final operator = EnhancedBucketOperator(
      credentialManager: _credentialManager,
      region: region,
      appId: appId,
    );
    
    return await operator.getObject(bucket, key);
  }
}
```

## 配置参考

### STS 服务配置

```dart
final stsService = STSService(
  secretId: 'your_secret_id',
  secretKey: 'your_secret_key',
  region: 'ap-guangzhou',          // 根据您的区域调整
  endpoint: 'https://sts.tencentcloudapi.com',
  defaultValidDuration: Duration(hours: 1),  // 默认凭证有效期
);
```

### 凭证管理器配置

```dart
final credentialManager = TempCredentialManager(
  stsService,
  refreshThreshold: Duration(minutes: 5), // 提前刷新时间
);
```

## 支持的操作

### 存储桶操作 (BucketOperation)
- `createBucket` - 创建存储桶
- `deleteBucket` - 删除存储桶  
- `getBucketLocation` - 获取存储桶位置
- `getBucketVersioning` - 获取版本控制信息
- `listObjects` - 列出对象

### 对象操作 (ObjectOperation)
- `getObject` - 获取对象
- `putObject` - 上传对象
- `deleteObject` - 删除对象
- `copyObject` - 复制对象

## 故障排除

### 常见错误

1. **STS 权限不足**
   ```dart
   // 确保您的主账号有 STS 相关权限
   // 在腾讯云控制台检查 CAM 策略配置
   ```

2. **凭证过期**
   ```dart
   // 检查系统时间是否正确
   // 调整 refreshThreshold 参数
   final credentialManager = TempCredentialManager(
     stsService,
     refreshThreshold: Duration(minutes: 10), // 更早刷新
   );
   ```

3. **权限策略错误**
   ```dart
   // 确保申请的操作权限与实际操作匹配
   final credentials = await credentialManager.getObjectCredentials(
     'bucket',
     'key',
     operations: [ObjectOperation.putObject], // 确保包含所需权限
   );
   ```

## 完整示例

查看 `example/` 目录中的完整示例项目，包含：
- 基础使用示例
- 高级功能演示
- 错误处理示例
- 性能优化技巧

---

有问题或建议，请提交 Issue 或 Pull Request。
