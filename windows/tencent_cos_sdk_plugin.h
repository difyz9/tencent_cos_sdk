#ifndef FLUTTER_PLUGIN_TENCENT_COS_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_TENCENT_COS_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace tencent_cos_sdk {

class TencentCosSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TencentCosSdkPlugin();

  virtual ~TencentCosSdkPlugin();

  // Disallow copy and assign.
  TencentCosSdkPlugin(const TencentCosSdkPlugin&) = delete;
  TencentCosSdkPlugin& operator=(const TencentCosSdkPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace tencent_cos_sdk

#endif  // FLUTTER_PLUGIN_TENCENT_COS_SDK_PLUGIN_H_
