#include "flutter_gpu_texture_renderer_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

namespace flutter_gpu_texture_renderer {

FlutterGpuTextureRendererPlugin::FlutterGpuTextureRendererPlugin() {}

FlutterGpuTextureRendererPlugin::~FlutterGpuTextureRendererPlugin() {}

void FlutterGpuTextureRendererPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(),
      "flutter_gpu_texture_renderer",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "registerTexture" ||
            call.method_name() == "output") {
          result->Success(flutter::EncodableValue());
          return;
        }
        if (call.method_name() == "unregisterTexture") {
          result->Success();
          return;
        }
        result->NotImplemented();
      });

  registrar->AddPlugin(std::make_unique<FlutterGpuTextureRendererPlugin>());
}

}  // namespace flutter_gpu_texture_renderer
