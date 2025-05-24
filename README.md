# tencent_cos_sdk

腾讯云对象存储（COS）Flutter SDK，提供完整的对象存储功能支持。

## 特性

- ✅ 支持所有主要平台：Android、iOS、macOS、Linux、Windows、Web
- ✅ 完整的COS API支持：上传、下载、删除、列表等
- ✅ 高级功能：预签名URL、ACL、标签、CORS、防盗链等
- ✅ 断点续传和任务管理
- ✅ 进度回调支持
- ✅ 永久和临时密钥认证
- ✅ 原生SDK集成（Android/iOS）+ 纯Dart实现（Web/桌面）

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  tencent_cos_sdk: ^0.0.1
```

## 快速开始

### 1. 初始化SDK

```dart
import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';

// 使用永久密钥初始化
await TencentCosSdk.initWithPermanentKey(
  secretId: 'your-secret-id',
  secretKey: 'your-secret-key',
  region: 'ap-guangzhou',
  appId: 'your-app-id',
);

// 或使用临时密钥初始化
await TencentCosSdk.initWithTemporaryKey(
  secretId: 'temp-secret-id',
  secretKey: 'temp-secret-key',
  sessionToken: 'session-token',
  region: 'ap-guangzhou',
  appId: 'your-app-id',
);
```

### 2. 基础对象操作

```dart
// 上传文件
final uploadResult = await TencentCosSdk.uploadFile(
  bucketName: 'my-bucket',
  cosPath: 'path/to/file.jpg',
  filePath: '/local/path/to/file.jpg',
  onProgress: (completed, total) {
    print('上传进度: ${(completed / total * 100).toStringAsFixed(1)}%');
  },
);

// 下载文件
final downloadResult = await TencentCosSdk.downloadFile(
  bucketName: 'my-bucket',
  cosPath: 'path/to/file.jpg',
  savePath: '/local/save/path/file.jpg',
  onProgress: (completed, total) {
    print('下载进度: ${(completed / total * 100).toStringAsFixed(1)}%');
  },
);

// 删除对象
await TencentCosSdk.deleteObject(
  bucketName: 'my-bucket',
  cosPath: 'path/to/file.jpg',
);

// 列出对象
final listResult = await TencentCosSdk.listObjects(
  bucketName: 'my-bucket',
  prefix: 'photos/',
  maxKeys: 100,
);
```

### 3. 存储桶操作

```dart
// 创建存储桶
await TencentCosSdk.createBucket(bucketName: 'my-new-bucket');

// 列出存储桶
final buckets = await TencentCosSdk.listBuckets();

// 删除存储桶
await TencentCosSdk.deleteBucket(bucketName: 'my-bucket');
```

### 4. 高级功能

```dart
// 生成预签名URL
final preSignedUrl = await TencentCosSdk.getPreSignedUrl(
  bucketName: 'my-bucket',
  cosPath: 'path/to/file.jpg',
  httpMethod: 'GET',
  expiredTime: DateTime.now().add(Duration(hours: 1)),
);

// 检查对象是否存在
final exists = await TencentCosSdk.doesObjectExist(
  bucketName: 'my-bucket',
  cosPath: 'path/to/file.jpg',
);

// 复制对象
await TencentCosSdk.copyObject(
  sourceBucketName: 'source-bucket',
  sourceCosPath: 'source/path/file.jpg',
  destinationBucketName: 'dest-bucket',
  destinationCosPath: 'dest/path/file.jpg',
);
```

### 5. 断点续传

```dart
// 高级上传（支持断点续传）
final taskId = await TencentCosSdk.uploadFileAdvanced(
  bucketName: 'my-bucket',
  cosPath: 'large-file.zip',
  filePath: '/path/to/large-file.zip',
);

// 暂停任务
await TencentCosSdk.pauseTask(taskId);

// 恢复任务
await TencentCosSdk.resumeTask(taskId);

// 取消任务
await TencentCosSdk.cancelTask(taskId);
```

## API 文档

### 认证相关

- `initWithPermanentKey()` - 永久密钥初始化
- `initWithTemporaryKey()` - 临时密钥初始化

### 基础对象操作

- `uploadFile()` - 上传文件
- `uploadData()` - 上传数据
- `downloadFile()` - 下载文件
- `deleteObject()` - 删除对象
- `listObjects()` - 列出对象

### 存储桶操作

- `createBucket()` - 创建存储桶
- `deleteBucket()` - 删除存储桶
- `listBuckets()` - 列出存储桶

### 高级功能

- `getPreSignedUrl()` - 生成预签名URL
- `doesObjectExist()` - 检查对象是否存在
- `copyObject()` - 复制对象
- `putObjectACL()` / `getObjectACL()` - 对象ACL管理
- `putObjectTagging()` / `getObjectTagging()` - 对象标签管理

### 断点续传

- `uploadFileAdvanced()` - 高级上传
- `downloadFileAdvanced()` - 高级下载
- `pauseTask()` / `resumeTask()` / `cancelTask()` - 任务控制

### 网络配置

- `setCustomDNS()` - 自定义DNS
- `preBuildConnection()` - 预建立连接
- `configureService()` - 服务配置
- `configureTransfer()` - 传输配置

## 平台支持

| 平台 | 实现方式 | 支持状态 |
|------|----------|----------|
| Android | 原生SDK | ✅ 完全支持 |
| iOS | 原生SDK | ✅ 完全支持 |
| macOS | 原生SDK | ✅ 完全支持 |
| Web | 纯Dart | ✅ 完全支持 |
| Linux | 纯Dart | ✅ 完全支持 |
| Windows | 纯Dart | ✅ 完全支持 |

## 注意事项

1. **安全性**：请勿在客户端代码中硬编码永久密钥，建议使用临时密钥
2. **网络环境**：Web平台受浏览器同源策略限制，需要配置CORS
3. **文件大小**：大文件建议使用高级上传接口，支持断点续传
4. **错误处理**：所有API调用都应该包含适当的错误处理

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

