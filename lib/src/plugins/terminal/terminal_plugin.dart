import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/host.dart';
import 'package:studio/src/core/plugin.dart';
import 'package:studio/src/plugins/terminal/terminal_menu.dart';
import 'package:xterm/xterm.dart';

class TerminalPlugin extends Plugin {
  final terminal = Terminal(maxLines: 10000);

  final terminalController = TerminalController();

  var terminalTitle = '';

  ExecutionSession? session;

  void _updateTitle() {
    if (session != null) {
      title.value =
          '$terminalTitle — ${terminal.viewWidth}x${terminal.viewHeight}';
    }
  }

  @override
  void didMounted() {
    title.value = 'Connecting';

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      _updateTitle();
    };

    terminal.onOutput = (data) {
      session?.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      session?.resize(w, h);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _updateTitle();
      });
    };

    super.didMounted();
  }

  @override
  void didConnected() async {
    title.value = 'Terminal';

    session = await host.shell(
      width: terminal.viewWidth,
      height: terminal.viewHeight,
    );

    session!.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    session!.exitCode.then((code) {
      session = null;
      if (mounted) {
        manager.remove(this);
      }
    });
  }

  @override
  void didDisconnected() {
    session = null;
  }

  @override
  Widget build(BuildContext context) {
    return TerminalTabView(this);
  }
}

class TerminalTabView extends ConsumerStatefulWidget {
  const TerminalTabView(this.plugin, {super.key});

  final TerminalPlugin plugin;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TerminalTabViewState();
}

class _TerminalTabViewState extends ConsumerState<TerminalTabView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: ValueKey(widget.plugin),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: ClipRect(
          child: TerminalView(
            widget.plugin.terminal,
            controller: widget.plugin.terminalController,
            onSecondaryTapDown: (_, __) => showMenu(),
            backgroundOpacity: 0.8,
            autofocus: true,
          ),
        ),
      ),
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(plugin: widget.plugin);
    context.contextMenuOverlay.show(menu);
  }
}
