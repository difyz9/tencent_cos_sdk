# Tencent COS SDK - 临时密钥增强版

基于参考项目 `tencent_cos_plus` 的设计思路，为 `tencent_cos_sdk` 项目新增了临时密钥操作能力，提供简单易用的工厂模式 API。

## 🚀 主要特性

- **临时密钥管理**: 自动获取和刷新临时凭证，确保安全性
- **简化的 API**: 类似 `tencent_cos_plus` 的工厂模式设计，使用更简单
- **权限控制**: 基于操作类型自动申请最小权限的临时凭证
- **自动重试**: 凭证过期时自动刷新并重试操作
- **完整功能**: 支持存储桶和对象的所有基本操作

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  tencent_cos_sdk: ^latest_version
```

## 🔧 快速开始

### 1. 初始化

```dart
import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';

await COSApiFactory.initialize(
  secretId: 'YOUR_SECRET_ID',     // 腾讯云 SecretId
  secretKey: 'YOUR_SECRET_KEY',   // 腾讯云 SecretKey
  region: 'ap-guangzhou',         // COS 区域
  appId: 'YOUR_APP_ID',           // 腾讯云 AppId
);
```

### 2. 存储桶操作

```dart
// 创建存储桶
await COSApiFactory.bucketApi.create('my-bucket-name');

// 列出对象
final objects = await COSApiFactory.bucketApi.listObjects(
  'my-bucket-name',
  prefix: 'uploads/',
  maxKeys: 100,
);

// 删除存储桶
await COSApiFactory.bucketApi.delete('my-bucket-name');
```

### 3. 对象操作

```dart
// 上传文件
await COSApiFactory.objectApi.uploadFile(
  'my-bucket-name',
  'path/in/cos.txt',
  '/local/file/path.txt',
  onProgress: (completed, total) {
    print('进度: ${(completed / total * 100).toStringAsFixed(1)}%');
  },
);

// 上传数据
await COSApiFactory.objectApi.uploadData(
  'my-bucket-name',
  'data.txt',
  'Hello World'.codeUnits,
);

// 下载文件
await COSApiFactory.objectApi.downloadFile(
  'my-bucket-name',
  'path/in/cos.txt',
  '/local/save/path.txt',
);

// 检查对象是否存在
final exists = await COSApiFactory.objectApi.exists(
  'my-bucket-name',
  'path/in/cos.txt',
);

// 生成预签名URL
final url = await COSApiFactory.objectApi.generatePresignedUrl(
  'my-bucket-name',
  'path/in/cos.txt',
  expirationInSeconds: 3600,
);

// 复制对象
await COSApiFactory.objectApi.copy(
  'source-bucket',
  'source/path.txt',
  'dest-bucket',
  'dest/path.txt',
);

// 删除对象
await COSApiFactory.objectApi.delete(
  'my-bucket-name',
  'path/in/cos.txt',
);
```

### 4. 清理资源

```dart
// 记得在应用结束时清理资源
COSApiFactory.dispose();
```

## 🔐 安全特性

### 临时密钥自动管理

该 SDK 使用腾讯云 STS (Security Token Service) 自动管理临时凭证：

- **自动申请**: 根据操作类型自动申请相应权限的临时凭证
- **自动刷新**: 凭证即将过期时自动刷新，无需手动处理
- **最小权限**: 为每个操作申请最小必要权限，提高安全性
- **权限隔离**: 不同操作使用不同的临时凭证，降低安全风险

### 权限类型

#### 存储桶权限
- `createBucket`: 创建存储桶
- `deleteBucket`: 删除存储桶
- `listObjects`: 列出对象

#### 对象权限
- `putObject`: 上传对象
- `getObject`: 下载/读取对象
- `deleteObject`: 删除对象

## 🏗️ 架构设计

```
COSApiFactory (工厂类)
├── BucketApi (存储桶操作)
│   ├── create()
│   ├── delete()
│   └── listObjects()
└── ObjectApi (对象操作)
    ├── uploadFile()
    ├── uploadData()
    ├── downloadFile()
    ├── exists()
    ├── generatePresignedUrl()
    ├── copy()
    └── delete()

底层组件:
├── EnhancedBucketOperator (增强操作器)
├── TempCredentialManager (临时凭证管理)
├── STSService (STS服务集成)
└── TencentCosSdk (原生SDK封装)
```

## 📝 完整示例

查看 [example/example.dart](example/example.dart) 文件获取完整的使用示例，包括：

- 基本操作示例
- 批量操作示例
- 错误处理示例

## 🔄 与 tencent_cos_plus 的对比

| 特性 | tencent_cos_plus | 本项目 |
|------|------------------|---------|
| API 设计 | 工厂模式 | ✅ 工厂模式 |
| 临时密钥 | ❌ | ✅ 自动管理 |
| 权限控制 | ❌ | ✅ 细粒度控制 |
| 安全性 | 永久密钥 | ✅ 临时密钥 |
| 使用复杂度 | 简单 | ✅ 同样简单 |

## 🛠️ 高级用法

### 直接使用底层组件

如果需要更细粒度的控制，可以直接使用底层组件：

```dart
// 创建 STS 服务
final stsService = STSService(
  secretId: 'YOUR_SECRET_ID',
  secretKey: 'YOUR_SECRET_KEY',
  region: 'ap-guangzhou',
);

// 创建临时凭证管理器
final credentialManager = TempCredentialManager(
  stsService,
  'YOUR_APP_ID',
);

// 获取特定操作的临时凭证
final credentials = await credentialManager.getBucketCredentials(
  'my-bucket',
  operations: [BucketOperation.listObjects],
);

// 手动初始化 SDK
await TencentCosSdk.initWithTemporaryKey(
  secretId: credentials.tmpSecretId,
  secretKey: credentials.tmpSecretKey,
  sessionToken: credentials.sessionToken,
  region: 'ap-guangzhou',
  appId: 'YOUR_APP_ID',
);
```

### 自定义凭证有效期

```dart
final credentials = await credentialManager.getBucketCredentials(
  'my-bucket',
  operations: [BucketOperation.listObjects],
  validDuration: Duration(hours: 2), // 自定义有效期
);
```

## ⚠️ 注意事项

1. **SecretId/SecretKey**: 这里的 SecretId 和 SecretKey 是用于 STS 服务的，需要有调用 STS 的权限
2. **存储桶命名**: 存储桶名称必须全局唯一，建议加上随机后缀
3. **权限配置**: 确保用于 STS 的账号有足够的权限来为 COS 操作申请临时凭证
4. **资源清理**: 应用结束时记得调用 `COSApiFactory.dispose()` 清理资源

## 🐛 故障排除

### 常见错误

1. **STS 权限不足**
   ```
   错误: STS 服务错误: Access denied
   解决: 检查 SecretId/SecretKey 是否有 STS 相关权限
   ```

2. **存储桶不存在**
   ```
   错误: The specified bucket does not exist
   解决: 确保存储桶名称正确且已创建
   ```

3. **临时凭证过期**
   ```
   错误: Request has expired
   解决: SDK 会自动处理，如持续出现请检查系统时间
   ```

## 📜 许可证

本项目遵循原项目的许可证条款。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进项目！
