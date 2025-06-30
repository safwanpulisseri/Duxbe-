#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>

#include <optional>
#include <winspool.h>
#include <vector>
#include <string>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

std::vector<std::string> GetPrinterNames() {
    std::vector<std::string> printerNames;
    DWORD bytesNeeded = 0;
    DWORD printersReturned = 0;

    // First call to get required buffer size
    EnumPrinters(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
                 NULL, 2, NULL, 0, &bytesNeeded, &printersReturned);

    if (bytesNeeded == 0) {
        return printerNames;
    }

    // Allocate buffer
    std::vector<BYTE> buffer(bytesNeeded);
    PRINTER_INFO_2* printerInfo = reinterpret_cast<PRINTER_INFO_2*>(buffer.data());

    // Second call to get actual printer info
    BOOL success = EnumPrinters(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
                               NULL, 2, buffer.data(), bytesNeeded,
                               &bytesNeeded, &printersReturned);

    if (success) {
        for (DWORD i = 0; i < printersReturned; i++) {
            if (printerInfo[i].pPrinterName != NULL) {
                // Convert wide string to narrow string
                int size_needed = WideCharToMultiByte(CP_UTF8, 0, printerInfo[i].pPrinterName, -1, 
                                                    NULL, 0, NULL, NULL);
                std::string printerName(size_needed, 0);
                WideCharToMultiByte(CP_UTF8, 0, printerInfo[i].pPrinterName, -1, 
                                  &printerName[0], size_needed, NULL, NULL);
                // Remove the null terminator if present
                if (!printerName.empty() && printerName.back() == '\0') {
                    printerName.pop_back();
                }
                printerNames.push_back(printerName);
            }
        }
    }

    return printerNames;
}

std::vector<flutter::EncodableValue> ConvertToEncodableList(const std::vector<std::string>& printerNames) {
    std::vector<flutter::EncodableValue> encodableList;
    encodableList.reserve(printerNames.size());  // Reserve space for efficiency

    for (const auto& printerName : printerNames) {
        encodableList.push_back(flutter::EncodableValue(printerName));
    }

    return encodableList;
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "com.duxbe.business/printer",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
         if (call.method_name() == "getAvailablePrinters") {
            // Get printer names
            std::vector<std::string> printerNames = GetPrinterNames();

            // Convert to EncodableValue vector
            std::vector<flutter::EncodableValue> encodablePrinters = ConvertToEncodableList(printerNames);

            result->Success(flutter::EncodableValue(encodablePrinters));
        } else {
            result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
