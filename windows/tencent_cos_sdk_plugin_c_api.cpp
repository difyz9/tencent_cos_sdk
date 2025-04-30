#include "include/tencent_cos_sdk/tencent_cos_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tencent_cos_sdk_plugin.h"

void TencentCosSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tencent_cos_sdk::TencentCosSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
