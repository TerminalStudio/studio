import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()

//    self.contentView?.window?.styleMask = NSWindow.NSwinds
    // self.backgroundColor = .black
//    self.titlebarAppearsTransparent = true

  // self.titleVisibility = NSWindow.TitleVisibility.hidden;
  // self.titlebarAppearsTransparent = true;
  // self.isMovableByWindowBackground = true;
  // self.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = false;

   // Transparent view
   self.isOpaque = false
   self.backgroundColor = .clear

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
