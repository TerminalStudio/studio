import 'dart:convert';
import 'dart:io';

import 'package:context_menu_macos/context_menu_macos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pty/pty.dart';
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final tabs = TabsController();
  final group = TabGroupController();

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
                onTap: (group) {
                  group.addTab(buildTab(), activate: true);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void addTab() {
    this.group.addTab(buildTab(), activate: true);
  }

  Tab buildTab() {
    final tab = TabController();

    final shell = getShell();
    final pty = PseudoTerminal.start(shell, []);

    final terminal = Terminal(
      onTitleChange: tab.setTitle,
      platform: getPlatform(),
      onInput: pty.write,
    );

    terminal.debug.enable();

    pty.out.listen((data) {
      print(data);
      terminal.write(data);
    });

    final focusNode = FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });

    pty.exitCode.then((_) {
      tab.requestClose();
    });

    return Tab(
      controller: tab,
      title: 'Terminal',
      content: GestureDetector(
        onSecondaryTapDown: (details) async {
          final hasSelection = !terminal.selection.isEmpty;
          final clipboardData = await Clipboard.getData('text/plain');

          showMacosContextMenu(
            context: context,
            globalPosition: details.globalPosition,
            children: [
              MacosContextMenuItem(
                content: Text('Copy'),
                trailing: Text('⌘ C'),
                enabled: hasSelection,
                onTap: () {
                  final text = terminal.getSelectedText();
                  Clipboard.setData(ClipboardData(text: text));
                  terminal.selection.clear();
                  terminal.debug.onMsg('copy ┤$text├');
                  terminal.refresh();
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuItem(
                content: Text('Paste'),
                trailing: Text('⌘ V'),
                enabled: clipboardData.text.isNotEmpty,
                onTap: () {
                  terminal.paste(clipboardData.text);
                  terminal.debug.onMsg('paste ┤${clipboardData.text}├');
                  Navigator.of(context).pop();
                },
              ),
              MacosContextMenuItem(
                content: Text('Select All'),
                trailing: Text('⌘ A'),
                onTap: () => Navigator.of(context).pop(),
              ),
              MacosContextMenuDivider(),
              MacosContextMenuItem(
                content: Text('Clear'),
                trailing: Text('⌘ K'),
                onTap: () => Navigator.of(context).pop(),
              ),
              MacosContextMenuDivider(),
              MacosContextMenuItem(
                content: Text('Kill'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
        child: TerminalView(
          terminal: terminal,
          // onResize: pty.resize,
          onResize: pty.resize,
          focusNode: focusNode,
          style: TerminalStyle(
            fontSize: 12,
          ),
          opacity: 0.85,
        ),
      ),
      onActivate: () {
        focusNode.requestFocus();
      },
      onDrop: () {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          focusNode.requestFocus();
        });
      },
      onClose: () {
        pty.kill();
      },
    );
  }

  String getShell() {
    if (Platform.isWindows) {
      return r'C:\windows\system32\cmd.exe';
      // return r'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe';
    }

    return Platform.environment['SHELL'] ?? 'sh';
    // return '/bin/zsh';
  }

  PlatformBehavior getPlatform() {
    if (Platform.isWindows) {
      return PlatformBehaviors.windows;
    }

    return PlatformBehaviors.unix;
  }
}
