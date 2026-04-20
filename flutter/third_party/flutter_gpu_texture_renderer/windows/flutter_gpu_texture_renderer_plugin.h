#ifndef FLUTTER_PLUGIN_FLUTTER_GPU_TEXTURE_RENDERER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_GPU_TEXTURE_RENDERER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_gpu_texture_renderer {

class FlutterGpuTextureRendererPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FlutterGpuTextureRendererPlugin();

  ~FlutterGpuTextureRendererPlugin() override;

  FlutterGpuTextureRendererPlugin(const FlutterGpuTextureRendererPlugin&) = delete;
  FlutterGpuTextureRendererPlugin& operator=(const FlutterGpuTextureRendererPlugin&) = delete;
};

}  // namespace flutter_gpu_texture_renderer

#endif  // FLUTTER_PLUGIN_FLUTTER_GPU_TEXTURE_RENDERER_PLUGIN_H_
