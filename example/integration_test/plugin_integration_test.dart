// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 测试配置 - 实际使用时请替换为有效的值
  const String secretId = 'YOUR_SECRET_ID';  // 请替换为实际的值
  const String secretKey = 'YOUR_SECRET_KEY';  // 请替换为实际的值
  const String sessionToken = '';  // 临时密钥时使用
  const String region = 'ap-guangzhou';
  const String appId = 'YOUR_APP_ID';  // 请替换为实际的值
  const String bucketName = 'test-bucket';  // 请替换为实际的测试桶名
  
  setUpAll(() async {
    // 初始化 SDK
    try {
      // 使用永久密钥初始化，测试时替换为实际有效的密钥
      await TencentCosSdk.initWithPermanentKey(
        secretId: secretId,
        secretKey: secretKey,
        region: region,
        appId: appId,
      );
      print('SDK初始化成功');
    } catch (e) {
      print('SDK初始化失败: $e');
      // 在实际测试中，我们可能希望在此处失败，但为了允许CI测试无需真实密钥，我们继续执行
    }
  });

  group('基本功能测试', () {
    testWidgets('getPlatformVersion test', (WidgetTester tester) async {
      final TencentCosSdk plugin = TencentCosSdk();
      final String? version = await plugin.getPlatformVersion();
      // The version string depends on the host platform running the test, so
      // just assert that some non-empty string is returned.
      expect(version?.isNotEmpty, true);
    });
    
    testWidgets('简单上传下载测试', (WidgetTester tester) async {
      // 跳过实际 API 调用的测试，除非提供了有效的密钥
      if (secretId == 'YOUR_SECRET_ID' || secretKey == 'YOUR_SECRET_KEY') {
        print('跳过实际API测试，因为没有提供有效的密钥');
        return;
      }
      
      try {
        // 创建测试文件
        final tempDir = await getTemporaryDirectory();
        final testFile = File('${tempDir.path}/test_upload.txt');
        await testFile.writeAsString('This is a test file for Tencent COS SDK integration test.');
        
        // 测试文件上传
        final uploadResult = await TencentCosSdk.uploadFile(
          bucketName: bucketName,
          cosPath: 'test_upload.txt',
          filePath: testFile.path,
        );
        
        print('上传结果: $uploadResult');
        expect(uploadResult['statusCode'], anyOf(equals(200), equals(201)));
        
        // 测试文件下载
        final downloadFile = File('${tempDir.path}/test_download.txt');
        if (downloadFile.existsSync()) {
          await downloadFile.delete();
        }
        
        final downloadResult = await TencentCosSdk.downloadFile(
          bucketName: bucketName,
          cosPath: 'test_upload.txt',
          savePath: downloadFile.path,
        );
        
        print('下载结果: $downloadResult');
        expect(downloadResult['statusCode'], equals(200));
        expect(downloadFile.existsSync(), isTrue);
        
        // 验证下载的文件内容
        final downloadedContent = await downloadFile.readAsString();
        expect(downloadedContent, 'This is a test file for Tencent COS SDK integration test.');
        
        // 测试删除对象
        final deleteResult = await TencentCosSdk.deleteObject(
          bucketName: bucketName,
          cosPath: 'test_upload.txt',
        );
        
        print('删除结果: $deleteResult');
        expect(deleteResult['statusCode'], anyOf(equals(204), equals(200)));
        
        // 清理测试文件
        if (testFile.existsSync()) {
          await testFile.delete();
        }
        if (downloadFile.existsSync()) {
          await downloadFile.delete();
        }
      } catch (e) {
        print('测试出错: $e');
        fail('测试失败: $e');
      }
    });
  });
  
  group('高级功能测试', () {
    testWidgets('预签名URL测试', (WidgetTester tester) async {
      // 跳过实际 API 调用的测试，除非提供了有效的密钥
      if (secretId == 'YOUR_SECRET_ID' || secretKey == 'YOUR_SECRET_KEY') {
        print('跳过实际API测试，因为没有提供有效的密钥');
        return;
      }
      
      try {
        // 测试获取预签名URL
        final url = await TencentCosSdk.getPreSignedUrl(
          bucketName: bucketName,
          cosPath: 'test_preSignedUrl.txt',
          expirationInSeconds: 3600,
        );
        
        print('预签名URL: $url');
        expect(url, isNotEmpty);
        expect(url, contains('https://'));
        expect(url, contains(bucketName));
        expect(url, contains('test_preSignedUrl.txt'));
      } catch (e) {
        print('测试出错: $e');
        fail('测试失败: $e');
      }
    });
    
    testWidgets('断点续传测试', (WidgetTester tester) async {
      // 跳过实际 API 调用的测试，除非提供了有效的密钥
      if (secretId == 'YOUR_SECRET_ID' || secretKey == 'YOUR_SECRET_KEY') {
        print('跳过实际API测试，因为没有提供有效的密钥');
        return;
      }
      
      try {
        // 创建大一点的测试文件
        final tempDir = await getTemporaryDirectory();
        final testFile = File('${tempDir.path}/test_large_file.dat');
        
        // 生成1MB的随机数据
        final data = List<int>.generate(1024 * 1024, (i) => i % 256);
        await testFile.writeAsBytes(data);
        
        // 测试高级上传 - 启用断点续传
        final taskId = await TencentCosSdk.uploadFileAdvanced(
          bucketName: bucketName,
          cosPath: 'test_large_file.dat',
          filePath: testFile.path,
          options: {
            'enableCheckpoint': true,
          },
          onProgress: (completed, total) {
            print('上传进度: $completed / $total');
          },
        );
        
        print('上传任务ID: $taskId');
        expect(taskId, isNotEmpty);
        
        // 获取任务状态
        final status = await TencentCosSdk.getTaskStatus(taskId);
        print('任务状态: $status');
        expect(status, isNotNull);
        
        // 等待上传完成
        bool isCompleted = false;
        int retryCount = 0;
        while (!isCompleted && retryCount < 10) {
          final currentStatus = await TencentCosSdk.getTaskStatus(taskId);
          if (currentStatus['status'] == 'completed') {
            isCompleted = true;
          } else {
            retryCount++;
            await Future.delayed(Duration(seconds: 1));
          }
        }
        
        // 测试删除对象
        final deleteResult = await TencentCosSdk.deleteObject(
          bucketName: bucketName,
          cosPath: 'test_large_file.dat',
        );
        
        print('删除结果: $deleteResult');
        expect(deleteResult['statusCode'], anyOf(equals(204), equals(200)));
        
        // 清理测试文件
        if (testFile.existsSync()) {
          await testFile.delete();
        }
      } catch (e) {
        print('测试出错: $e');
        fail('测试失败: $e');
      }
    });
    
    testWidgets('存储桶操作测试', (WidgetTester tester) async {
      // 跳过实际 API 调用的测试，除非提供了有效的密钥
      if (secretId == 'YOUR_SECRET_ID' || secretKey == 'YOUR_SECRET_KEY') {
        print('跳过实际API测试，因为没有提供有效的密钥');
        return;
      }
      
      try {
        // 测试列出存储桶
        final buckets = await TencentCosSdk.listBuckets();
        print('存储桶列表: $buckets');
        expect(buckets, isNotNull);
        expect(buckets['buckets'], isA<List>());
        
        // 测试存储桶ACL - 获取ACL
        final aclResult = await TencentCosSdk.getBucketACL(
          bucketName: bucketName,
        );
        
        print('存储桶ACL: $aclResult');
        expect(aclResult, isNotNull);
        expect(aclResult['statusCode'], equals(200));
      } catch (e) {
        print('测试出错: $e');
        fail('测试失败: $e');
      }
    });
    
    testWidgets('对象高级操作测试', (WidgetTester tester) async {
      // 跳过实际 API 调用的测试，除非提供了有效的密钥
      if (secretId == 'YOUR_SECRET_ID' || secretKey == 'YOUR_SECRET_KEY') {
        print('跳过实际API测试，因为没有提供有效的密钥');
        return;
      }
      
      try {
        // 创建测试文件
        final tempDir = await getTemporaryDirectory();
        final testFile = File('${tempDir.path}/test_object_ops.txt');
        await testFile.writeAsString('This is a test file for object operations test.');
        
        // 上传测试文件
        await TencentCosSdk.uploadFile(
          bucketName: bucketName,
          cosPath: 'test_object_ops.txt',
          filePath: testFile.path,
        );
        
        // 测试复制对象
        final copyResult = await TencentCosSdk.copyObject(
          sourceBucketName: bucketName,
          sourceCosPath: 'test_object_ops.txt',
          destinationBucketName: bucketName,
          destinationCosPath: 'test_object_ops_copy.txt',
        );
        
        print('复制结果: $copyResult');
        expect(copyResult['statusCode'], anyOf(equals(200), equals(201)));
        
        // 检查对象是否存在
        final exists = await TencentCosSdk.doesObjectExist(
          bucketName: bucketName,
          cosPath: 'test_object_ops_copy.txt',
        );
        
        print('对象是否存在: $exists');
        expect(exists, isTrue);
        
        // 测试设置对象标签
        final tagResult = await TencentCosSdk.putObjectTagging(
          bucketName: bucketName,
          cosPath: 'test_object_ops.txt',
          tags: {'tag1': 'value1', 'tag2': 'value2'},
        );
        
        print('设置标签结果: $tagResult');
        expect(tagResult['statusCode'], equals(200));
        
        // 测试获取对象标签
        final getTags = await TencentCosSdk.getObjectTagging(
          bucketName: bucketName,
          cosPath: 'test_object_ops.txt',
        );
        
        print('获取标签结果: $getTags');
        expect(getTags['statusCode'], equals(200));
        
        // 清理 - 删除对象
        await TencentCosSdk.deleteObject(
          bucketName: bucketName,
          cosPath: 'test_object_ops.txt',
        );
        
        await TencentCosSdk.deleteObject(
          bucketName: bucketName,
          cosPath: 'test_object_ops_copy.txt',
        );
        
        // 清理测试文件
        if (testFile.existsSync()) {
          await testFile.delete();
        }
      } catch (e) {
        print('测试出错: $e');
        fail('测试失败: $e');
      }
    });
  });
}
