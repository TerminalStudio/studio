#include "flutter_window.h"

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(RunLoop* run_loop,
                             const flutter::DartProject& project)
    : run_loop_(run_loop), project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  aOldColors[0] = GetSysColor(aElements[0]); 
  aOldColors[1] = GetSysColor(aElements[1]); 

  aNewColors[0] = RGB(0x80, 0x80, 0x80);  // light gray 
  aNewColors[1] = RGB(0x80, 0x00, 0x80);  // dark purple 
  SetSysColors(2, aElements, aNewColors); 

  // The size here is arbitrary since SetChildContent will resize it.
  flutter_controller_ =
      std::make_unique<flutter::FlutterViewController>(100, 100, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_.get());
  run_loop_->RegisterFlutterInstance(flutter_controller_.get());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  return true;
}

void FlutterWindow::OnDestroy() {
  SetSysColors(2, aElements, aOldColors); 
  
  if (flutter_controller_) {
    run_loop_->UnregisterFlutterInstance(flutter_controller_.get());
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}
