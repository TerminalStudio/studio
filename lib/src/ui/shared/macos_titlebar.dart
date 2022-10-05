import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

class MacosTitlebar extends StatefulWidget {
  const MacosTitlebar({super.key, required this.color});

  final Color color;

  @override
  State<MacosTitlebar> createState() => _MacosTitlebarState();
}

class _MacosTitlebarState extends State<MacosTitlebar> with WindowListener {
  var maximized = false;
  @override
  void onWindowMaximize() {
    setState(() => maximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => maximized = false);
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
      height: maximized ? 28 : 0,
      color: widget.color,
    );
  }
}
