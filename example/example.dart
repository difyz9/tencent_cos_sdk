import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';

/// 示例：如何使用新的临时密钥API
/// 
/// 这个例子展示了如何使用类似 tencent_cos_plus 的简化 API 接口
/// 来操作腾讯云 COS，并使用临时密钥来确保安全性
void main() async {
  try {
    // 1. 初始化 COSApiFactory
    // 使用您的腾讯云账号信息初始化
    await COSApiFactory.initialize(
      secretId: 'YOUR_SECRET_ID',     // 您的腾讯云 SecretId
      secretKey: 'YOUR_SECRET_KEY',   // 您的腾讯云 SecretKey
      region: 'ap-guangzhou',         // COS 区域
      appId: 'YOUR_APP_ID',           // 您的腾讯云 AppId
    );

    // 2. 存储桶操作示例
    print('=== 存储桶操作示例 ===');
    
    // 创建存储桶
    final bucketName = 'my-test-bucket-1234567890'; // 存储桶名称需要全局唯一
    print('创建存储桶: $bucketName');
    final created = await COSApiFactory.bucketApi.create(bucketName);
    print('创建结果: $created');
    
    // 列出存储桶中的对象
    print('\\n列出存储桶中的对象:');
    final objects = await COSApiFactory.bucketApi.listObjects(
      bucketName,
      prefix: 'uploads/',  // 可选：只列出特定前缀的对象
      maxKeys: 100,        // 可选：限制返回的对象数量
    );
    print('找到 ${objects.length} 个对象');
    for (final obj in objects) {
      print('  - ${obj.key} (${obj.size} bytes)');
    }

    // 3. 对象操作示例
    print('\\n=== 对象操作示例 ===');
    
    // 上传文件
    final localFilePath = '/path/to/your/local/file.txt';
    final cosPath = 'uploads/example.txt';
    print('上传文件: $localFilePath -> $cosPath');
    
    final uploaded = await COSApiFactory.objectApi.uploadFile(
      bucketName,
      cosPath,
      localFilePath,
      onProgress: (completed, total) {
        final percentage = (completed / total * 100).toStringAsFixed(1);
        print('上传进度: $percentage% ($completed/$total)');
      },
    );
    print('上传结果: $uploaded');

    // 上传数据（而不是文件）
    final textData = 'Hello, Tencent COS with temporary credentials!';
    final dataPath = 'uploads/data.txt';
    print('\\n上传数据到: $dataPath');
    
    final dataUploaded = await COSApiFactory.objectApi.uploadData(
      bucketName,
      dataPath,
      textData.codeUnits, // 转换字符串为字节数组
    );
    print('数据上传结果: $dataUploaded');

    // 检查对象是否存在
    print('\\n检查对象是否存在: $cosPath');
    final exists = await COSApiFactory.objectApi.exists(bucketName, cosPath);
    print('对象存在: $exists');

    // 生成预签名URL（用于直接访问）
    print('\\n生成预签名URL:');
    final presignedUrl = await COSApiFactory.objectApi.generatePresignedUrl(
      bucketName,
      cosPath,
      expirationInSeconds: 3600, // 1小时后过期
      httpMethod: 'GET',
    );
    print('预签名URL: $presignedUrl');

    // 下载文件
    final downloadPath = '/path/to/save/downloaded_file.txt';
    print('\\n下载文件: $cosPath -> $downloadPath');
    
    final downloaded = await COSApiFactory.objectApi.downloadFile(
      bucketName,
      cosPath,
      downloadPath,
      onProgress: (completed, total) {
        final percentage = (completed / total * 100).toStringAsFixed(1);
        print('下载进度: $percentage% ($completed/$total)');
      },
    );
    print('下载结果: $downloaded');

    // 复制对象
    final copyPath = 'uploads/example_copy.txt';
    print('\\n复制对象: $cosPath -> $copyPath');
    
    final copied = await COSApiFactory.objectApi.copy(
      bucketName,  // 源存储桶
      cosPath,     // 源路径
      bucketName,  // 目标存储桶（可以是不同的存储桶）
      copyPath,    // 目标路径
    );
    print('复制结果: $copied');

    // 删除对象
    print('\\n删除对象: $copyPath');
    final deleted = await COSApiFactory.objectApi.delete(bucketName, copyPath);
    print('删除结果: $deleted');

    // 删除存储桶（注意：存储桶必须为空才能删除）
    print('\\n删除存储桶: $bucketName');
    final bucketDeleted = await COSApiFactory.bucketApi.delete(bucketName);
    print('删除存储桶结果: $bucketDeleted');

  } catch (e) {
    print('操作失败: $e');
  } finally {
    // 4. 清理资源
    COSApiFactory.dispose();
    print('\\n资源已清理');
  }
}

/// 高级使用示例：批量操作
void advancedExample() async {
  await COSApiFactory.initialize(
    secretId: 'YOUR_SECRET_ID',
    secretKey: 'YOUR_SECRET_KEY',
    region: 'ap-guangzhou',
    appId: 'YOUR_APP_ID',
  );

  final bucketName = 'my-advanced-bucket-1234567890';
  
  try {
    // 批量上传文件
    final filesToUpload = [
      '/path/to/file1.txt',
      '/path/to/file2.txt',
      '/path/to/file3.txt',
    ];

    print('批量上传文件...');
    for (int i = 0; i < filesToUpload.length; i++) {
      final localPath = filesToUpload[i];
      final cosPath = 'batch/file_${i + 1}.txt';
      
      final result = await COSApiFactory.objectApi.uploadFile(
        bucketName,
        cosPath,
        localPath,
        onProgress: (completed, total) {
          print('文件 ${i + 1}: ${(completed / total * 100).toStringAsFixed(1)}%');
        },
      );
      
      print('文件 ${i + 1} 上传结果: $result');
    }

    // 列出所有批量上传的文件
    print('\\n列出批量上传的文件:');
    final batchObjects = await COSApiFactory.bucketApi.listObjects(
      bucketName,
      prefix: 'batch/',
    );
    
    for (final obj in batchObjects) {
      print('  - ${obj.key} (${obj.size} bytes, 最后修改: ${obj.lastModified})');
    }

  } catch (e) {
    print('高级操作失败: $e');
  } finally {
    COSApiFactory.dispose();
  }
}

/// 错误处理示例
void errorHandlingExample() async {
  try {
    await COSApiFactory.initialize(
      secretId: 'YOUR_SECRET_ID',
      secretKey: 'YOUR_SECRET_KEY', 
      region: 'ap-guangzhou',
      appId: 'YOUR_APP_ID',
    );

    // 尝试操作不存在的存储桶
    final result = await COSApiFactory.objectApi.exists(
      'non-existent-bucket-name',
      'some/path.txt',
    );
    print('结果: $result');

  } on STSException catch (e) {
    print('STS 服务错误: ${e.message} (代码: ${e.code})');
  } catch (e) {
    print('其他错误: $e');
  } finally {
    COSApiFactory.dispose();
  }
}
