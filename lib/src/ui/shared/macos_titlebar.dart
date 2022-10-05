import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

const kMacosTitlebarHeight = 28.0;

class MacosTitlebar extends StatefulWidget {
  const MacosTitlebar({super.key, required this.color});

  final Color color;

  @override
  State<MacosTitlebar> createState() => _MacosTitlebarState();
}

class _MacosTitlebarState extends State<MacosTitlebar> with WindowListener {
  var fullScreen = false;

  @override
  void onWindowEnterFullScreen() {
    setState(() => fullScreen = true);
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() => fullScreen = false);
    super.onWindowLeaveFullScreen();
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullScreen ? 0 : kMacosTitlebarHeight,
      color: widget.color,
    );
  }
}
