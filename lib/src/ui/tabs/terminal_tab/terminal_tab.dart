import 'dart:convert';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flex_tabs/src/model/node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/host.dart';
import 'package:studio/src/ui/tabs/terminal_tab/terminal_menu.dart';
import 'package:xterm/xterm.dart';

class TerminalTab extends TabItem {
  final Host host;

  TerminalTab(this.host) {
    init;
    content.value = TerminalTabView(this);
  }

  final terminal = Terminal(maxLines: 10000);

  final terminalController = TerminalController();

  var terminalTitle = '';

  late final ExecutionSession session;

  late final init = () async {
    session = await host.shell(
      width: terminal.viewWidth,
      height: terminal.viewHeight,
    );

    session.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    session.exitCode.then((code) {
      if (document.root == null || document.root!.children.length == 1) {
        exit(0);
      } else {
        detach();
      }
    });

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      updateTitle();
    };

    terminal.onOutput = (data) {
      session.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      session.resize(w, h);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        updateTitle();
      });
    };
  }();

  void updateTitle() {
    title.value = Text(
      '$terminalTitle — ${terminal.viewWidth}x${terminal.viewHeight}',
    );
  }

  TabsDocument get document {
    TabsNode node = this;
    while (node.parent != null) {
      node = node.parent!;
    }
    return node as TabsDocument;
  }
}

class TerminalTabView extends ConsumerStatefulWidget {
  const TerminalTabView(this.tab, {super.key});

  final TerminalTab tab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TerminalTabViewState();
}

class _TerminalTabViewState extends ConsumerState<TerminalTabView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: ValueKey(widget.tab),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: ClipRect(
          child: TerminalView(
            widget.tab.terminal,
            controller: widget.tab.terminalController,
            onSecondaryTapDown: (_, __) => showMenu(),
            backgroundOpacity: 0,
            autofocus: true,
          ),
        ),
      ),
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(tab: widget.tab);
    context.contextMenuOverlay.show(menu);
  }
}
