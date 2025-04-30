package com.tencent.tencent_cos_sdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper
import java.io.File
import java.util.*
import android.util.Log

/** TencentCosSdkPlugin */
class TencentCosSdkPlugin: FlutterPlugin, MethodCallHandler {
  private val TAG = "TencentCosSdkPlugin"

  /// The MethodChannel that will handle communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  
  /// The EventChannel for progress reporting
  private lateinit var progressChannel: EventChannel
  private val progressStreamHandler = ProgressStreamHandler()
  
  /// Handler for posting delayed events on the main thread
  private val handler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tencent_cos_sdk")
    channel.setMethodCallHandler(this)
    
    // Setup progress event channel
    progressChannel = EventChannel(flutterPluginBinding.binaryMessenger, "tencent_cos_sdk_progress")
    progressChannel.setStreamHandler(progressStreamHandler)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    Log.d(TAG, "Method called: ${call.method}")
    
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      
      "initWithPermanentKey" -> {
        val secretId = call.argument<String>("secretId")
        val secretKey = call.argument<String>("secretKey")
        val region = call.argument<String>("region")
        val appId = call.argument<String>("appId")
        
        if (secretId == null || secretKey == null || region == null || appId == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }
        
        // For testing, just log and return success
        Log.d(TAG, "Initializing with permanent key: $secretId, region: $region, appId: $appId")
        result.success(null)
      }
      
      "initWithTemporaryKey" -> {
        val secretId = call.argument<String>("secretId")
        val secretKey = call.argument<String>("secretKey")
        val sessionToken = call.argument<String>("sessionToken")
        val region = call.argument<String>("region")
        val appId = call.argument<String>("appId")
        
        if (secretId == null || secretKey == null || sessionToken == null || region == null || appId == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }
        
        // For testing, just log and return success
        Log.d(TAG, "Initializing with temporary key: $secretId, token: $sessionToken, region: $region, appId: $appId")
        result.success(null)
      }
      
      "uploadFile" -> {
        val bucketName = call.argument<String>("bucketName")
        val cosPath = call.argument<String>("cosPath")
        val filePath = call.argument<String>("filePath")
        val taskId = call.argument<String>("taskId")
        
        if (bucketName == null || cosPath == null || filePath == null || taskId == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }
        
        // For testing, simulate a successful upload with progress updates
        Log.d(TAG, "Uploading file from: $filePath to bucket: $bucketName, path: $cosPath")
        
        // Start a background thread to simulate progress updates
        Thread {
          for (i in 1..10) {
            Thread.sleep(100)
            progressStreamHandler.sendProgress(taskId, i * 10, 100)
          }
        }.start()
        
        val response = mapOf(
          "statusCode" to 200,
          "eTag" to "mockETag12345",
          "location" to "https://$bucketName.cos.ap-guangzhou.myqcloud.com/$cosPath"
        )
        
        result.success(response)
      }
      
      "downloadFile" -> {
        val bucketName = call.argument<String>("bucketName")
        val cosPath = call.argument<String>("cosPath")
        val savePath = call.argument<String>("savePath")
        val taskId = call.argument<String>("taskId")
        
        if (bucketName == null || cosPath == null || savePath == null || taskId == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }
        
        // For testing, simulate a successful download with progress updates
        Log.d(TAG, "Downloading file from bucket: $bucketName, path: $cosPath to local: $savePath")
        
        // Start a background thread to simulate progress updates and create a test file
        Thread {
          for (i in 1..10) {
            Thread.sleep(100)
            progressStreamHandler.sendProgress(taskId, i * 10, 100)
          }
          
          // Create a test file at the save path to simulate download
          try {
            val file = File(savePath)
            file.parentFile?.mkdirs()
            file.writeText("This is a test file for Tencent COS SDK integration test.")
          } catch (e: Exception) {
            Log.e(TAG, "Error creating test file: ${e.message}")
          }
        }.start()
        
        val response = mapOf(
          "statusCode" to 200,
          "eTag" to "mockETag12345"
        )
        
        result.success(response)
      }
      
      "deleteObject" -> {
        val bucketName = call.argument<String>("bucketName")
        val cosPath = call.argument<String>("cosPath")
        
        if (bucketName == null || cosPath == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }
        
        // For testing, simulate a successful deletion
        Log.d(TAG, "Deleting object from bucket: $bucketName, path: $cosPath")
        
        val response = mapOf(
          "statusCode" to 204
        )
        
        result.success(response)
      }
      
      else -> {
        // For any other unimplemented methods, return an empty successful result for testing
        if (call.method.startsWith("upload") || call.method.startsWith("download") || 
            call.method.startsWith("get") || call.method.startsWith("put") || 
            call.method.startsWith("list") || call.method.startsWith("delete") || 
            call.method.startsWith("copy") || call.method.startsWith("restore") || 
            call.method.startsWith("does")) {
            
          Log.d(TAG, "Mock implementation for method: ${call.method}")
          
          when {
            call.method.startsWith("get") && call.method.endsWith("URL") -> {
              result.success("https://example.cos.ap-guangzhou.myqcloud.com/test.txt?sign=mockSignature")
            }
            call.method.startsWith("does") -> {
              result.success(true)
            }
            call.method.endsWith("Advanced") -> {
              val taskId = Date().time.toString()
              result.success(taskId)
            }
            else -> {
              val response = mapOf(
                "statusCode" to 200,
                "mock" to true
              )
              result.success(response)
            }
          }
        } else {
          result.notImplemented()
        }
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    progressChannel.setStreamHandler(null)
  }
}

/** Stream handler for progress updates */
class ProgressStreamHandler : EventChannel.StreamHandler {
  private var eventSink: EventChannel.EventSink? = null
  private val handler = Handler(Looper.getMainLooper())
  
  override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
    eventSink = sink
  }
  
  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
  
  fun sendProgress(taskId: String, completed: Int, total: Int) {
    val eventSink = this.eventSink ?: return
    
    val event = mapOf(
      "taskId" to taskId,
      "completed" to completed,
      "total" to total
    )
    
    handler.post {
      eventSink.success(event)
    }
  }
}
