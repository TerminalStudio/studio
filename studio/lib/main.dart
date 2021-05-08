import 'dart:io';

import 'package:context_menu_macos/context_menu_macos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pty/pty.dart';
import 'package:studio/utils/build_mode.dart';
import 'package:studio/utils/pty_terminal_backend.dart';
import 'package:tabs/tabs.dart';

import 'package:flutter/material.dart' hide Tab, TabController;
import 'package:xterm/flutter.dart';
import 'package:xterm/theme/terminal_style.dart';
import 'package:xterm/xterm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terminal Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final tabs = TabsController();
  final group = TabGroupController();
  var tabCount = 0;

  @override
  void initState() {
    addTab();

    final group = TabsGroup(controller: this.group);

    tabs.replaceRoot(group);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          // color: Color(0xFF3A3D3F),
          color: Colors.transparent,
          child: TabsView(
            controller: tabs,
            actions: [
              TabsGroupAction(
                icon: CupertinoIcons.add,
                onTap: (group) async {
                  final tab = await buildTab();
                  group.addTab(tab, activate: true);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void addTab() async {
    this.group.addTab(await buildTab(), activate: true);
  }

  Future<Tab> buildTab() async {
    tabCount++;
    var tabIsClosed = false;

    final tab = TabController();

    if (!Platform.isWindows) {
      Directory.current = Platform.environment['HOME'] ?? '/';
    }

    // terminal.debug.enable();

    final shell = getShell();

    final backend = PtyTerminalBackend(
      PseudoTerminal.start(
        shell,
        // ['-l'],
        [],
        blocking:
            false, //!BuildMode.isDebug, //disabled for now due to problems with the blocking pseudo terminal
        ackProcessed: !BuildMode.isDebug,
      ),
    );

    // pty.write('cd\n');

    final terminal = (!BuildMode.isDebug)
        ? TerminalIsolate(
            onTitleChange: tab.setTitle,
            backend: backend,
            platform: getPlatform(true),
            minRefreshDelay: Duration(milliseconds: 50),
            maxLines: 10000,
          )
        : Terminal(
            onTitleChange: tab.setTitle,
            backend: backend,
            platform: getPlatform(true),
            maxLines: 10000,
          );

    //terminal.debug.enable(true);
    if (terminal is TerminalIsolate) {
      await terminal.start();
    }

    final focusNode = FocusNode();
    final scrollController = ScrollController();

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });

    terminal.backendExited.then((_) => tab.requestClose());

    return Tab(
      controller: tab,
      title: 'Terminal',
      content: GestureDetector(
        onLongPress: () {
          print('onLongPress');
        },
        // onDoubleTapDown: (details) {
        onDoubleTap: () {
          print('onDoubleTap \$details');
        },
        //   print('onDoubleTapDown \$details');
        // },
        // onTertiaryTapDown: (details) {
        //   print('onTertiaryTapDown $details');
        // },
        onSecondaryTapDown: (details) async {
          final clipboardData = await Clipboard.getData('text/plain');

          final hasSelection = !(terminal.selection?.isEmpty ?? true);
          final clipboardHasData = clipboardData?.text?.isNotEmpty == true;

          showMacosContextMenu(
            context: context,
            globalPosition: details.globalPosition,
            children: [
              MacosContextMenuItem(
                content: Text('Copy'),
                trailing: Text('⌘ C'),
                enabled: hasSelection,
                onTap: () {
                  final text = terminal.selectedText ?? '';
                  Clipboard.setData(ClipboardData(text: text));
                  terminal.clearSelection();
                  //terminal.debug.onMsg('copy ┤$text├');
                  terminal.refresh();
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuItem(
                content: Text('Paste'),
                trailing: Text('⌘ V'),
                enabled: clipboardHasData,
                onTap: () {
                  terminal.paste(clipboardData!.text!);
                  //terminal.debug.onMsg('paste ┤${clipboardData.text}├');
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuItem(
                content: Text('Select All'),
                trailing: Text('⌘ A'),
                onTap: () {
                  print('Select All is currently not implemented.');
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuDivider(),
              MacosContextMenuItem(
                content: Text('Clear'),
                trailing: Text('⌘ K'),
                onTap: () {
                  print('Clear is currently not implemented.');
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuDivider(),
              MacosContextMenuItem(
                content: Text('Kill'),
                onTap: () {
                  terminal.terminateBackend();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
        child: CupertinoScrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: TerminalView(
            scrollController: scrollController,
            terminal: terminal,
            focusNode: focusNode,
            opacity: 0.85,
            style: TerminalStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
      onActivate: () {
        focusNode.requestFocus();
      },
      onDrop: () {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          focusNode.requestFocus();
        });
      },
      onClose: () {
        // this handler can be called multiple times.
        // e.g. click to close tab => handler => terminateBackend => exitedEvent => close tab
        // which leads to an inconsistent tabCount value
        if (tabIsClosed) {
          return;
        }
        tabIsClosed = true;
        terminal.terminateBackend();

        tabCount--;

        if (tabCount <= 0) {
          exit(0);
        }
      },
    );
  }

  String getShell() {
    if (Platform.isWindows) {
      // return r'C:\windows\system32\cmd.exe';
      return r'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe';
    }

    return Platform.environment['SHELL'] ?? 'sh';
  }

  PlatformBehavior getPlatform([bool forLocalShell = false]) {
    if (Platform.isWindows) {
      return PlatformBehaviors.windows;
    }

    if (forLocalShell && Platform.isMacOS) {
      return PlatformBehaviors.mac;
    }

    return PlatformBehaviors.unix;
  }
}
