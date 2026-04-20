cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "flutter_gpu_texture_renderer")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "flutter_gpu_texture_renderer_plugin")

add_library(${PLUGIN_NAME} SHARED
  "include/flutter_gpu_texture_renderer/flutter_gpu_texture_renderer_plugin_c_api.h"
  "flutter_gpu_texture_renderer_plugin.cpp"
  "flutter_gpu_texture_renderer_plugin.h"
  "flutter_gpu_texture_renderer_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(flutter_gpu_texture_renderer_bundled_libraries
  ""
  PARENT_SCOPE
)
