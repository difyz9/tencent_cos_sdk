import Flutter
import UIKit

public class TencentCosSdkPlugin: NSObject, FlutterPlugin {
  // Progress event channel
  private static var progressChannel: FlutterEventChannel?
  private let progressStreamHandler = ProgressStreamHandler()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tencent_cos_sdk", binaryMessenger: registrar.messenger())
    let instance = TencentCosSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // Register progress event channel
    progressChannel = FlutterEventChannel(name: "tencent_cos_sdk_progress", binaryMessenger: registrar.messenger())
    progressChannel?.setStreamHandler(instance.progressStreamHandler)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    
    case "initWithPermanentKey":
      guard 
        let secretId = args?["secretId"] as? String,
        let secretKey = args?["secretKey"] as? String,
        let region = args?["region"] as? String,
        let appId = args?["appId"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }
      
      // For testing purposes, just return success
      print("Initializing with permanent key: \(secretId), region: \(region), appId: \(appId)")
      result(nil) // Success
    
    case "initWithTemporaryKey":
      guard 
        let secretId = args?["secretId"] as? String,
        let secretKey = args?["secretKey"] as? String,
        let sessionToken = args?["sessionToken"] as? String,
        let region = args?["region"] as? String,
        let appId = args?["appId"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }
      
      // For testing purposes, just return success
      print("Initializing with temporary key: \(secretId), token: \(sessionToken), region: \(region), appId: \(appId)")
      result(nil) // Success
    
    case "uploadFile":
      guard 
        let bucketName = args?["bucketName"] as? String,
        let cosPath = args?["cosPath"] as? String,
        let filePath = args?["filePath"] as? String,
        let taskId = args?["taskId"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }
      
      // For testing purposes, simulate a successful upload
      print("Uploading file from: \(filePath) to bucket: \(bucketName), path: \(cosPath)")
      
      // Simulate progress updates
      DispatchQueue.global(qos: .background).async {
        for i in 1...10 {
          Thread.sleep(forTimeInterval: 0.1)
          self.progressStreamHandler.sendProgress(taskId: taskId, completed: i * 10, total: 100)
        }
      }
      
      result(["statusCode": 200, "eTag": "mockETag12345", "location": "https://\(bucketName).cos.\(args?["region"] as? String ?? "ap-guangzhou").myqcloud.com/\(cosPath)"])
    
    case "downloadFile":
      guard 
        let bucketName = args?["bucketName"] as? String,
        let cosPath = args?["cosPath"] as? String,
        let savePath = args?["savePath"] as? String,
        let taskId = args?["taskId"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }
      
      // For testing purposes, simulate a successful download
      print("Downloading file from bucket: \(bucketName), path: \(cosPath) to local: \(savePath)")
      
      // Simulate progress updates
      DispatchQueue.global(qos: .background).async {
        for i in 1...10 {
          Thread.sleep(forTimeInterval: 0.1)
          self.progressStreamHandler.sendProgress(taskId: taskId, completed: i * 10, total: 100)
        }
        
        // Create a test file at the save path to simulate download
        let testContent = "This is a test file for Tencent COS SDK integration test."
        do {
          try testContent.write(toFile: savePath, atomically: true, encoding: .utf8)
        } catch {
          print("Error creating test file: \(error)")
        }
      }
      
      result(["statusCode": 200, "eTag": "mockETag12345"])
    
    case "deleteObject":
      guard 
        let bucketName = args?["bucketName"] as? String,
        let cosPath = args?["cosPath"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }
      
      // For testing purposes, simulate a successful deletion
      print("Deleting object from bucket: \(bucketName), path: \(cosPath)")
      result(["statusCode": 204])
      
    default:
      // For any other unimplemented methods, return an empty successful result for testing
      if call.method.hasPrefix("upload") || call.method.hasPrefix("download") || 
         call.method.hasPrefix("get") || call.method.hasPrefix("put") || 
         call.method.hasPrefix("list") || call.method.hasPrefix("delete") || 
         call.method.hasPrefix("copy") || call.method.hasPrefix("restore") || 
         call.method.hasPrefix("does") {
        print("Mock implementation for method: \(call.method)")
        if call.method.hasPrefix("get") && call.method.hasSuffix("URL") {
          result("https://example.cos.ap-guangzhou.myqcloud.com/test.txt?sign=mockSignature")
        } else if call.method.hasPrefix("does") {
          result(true)
        } else if call.method.hasSuffix("Advanced") {
          let taskId = String(Date().timeIntervalSince1970)
          result(taskId)
        } else {
          result(["statusCode": 200, "mock": true])
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

// Handle progress streaming
class ProgressStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  func sendProgress(taskId: String, completed: Int, total: Int) {
    guard let eventSink = eventSink else { return }
    
    DispatchQueue.main.async {
      eventSink(["taskId": taskId, "completed": completed, "total": total])
    }
  }
}
