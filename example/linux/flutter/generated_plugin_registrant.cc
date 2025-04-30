//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <tencent_cos_sdk/tencent_cos_sdk_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) tencent_cos_sdk_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TencentCosSdkPlugin");
  tencent_cos_sdk_plugin_register_with_registrar(tencent_cos_sdk_registrar);
}
