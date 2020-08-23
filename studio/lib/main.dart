import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pty/pty.dart';
import 'package:tabs/tabs.dart';

import 'package:flutter/material.dart' hide Tab, TabController;
import 'package:xterm/flutter.dart';
import 'package:xterm/xterm.dart';

void main() {
  runApp(MyApp());

  // ProcessSignal.sigterm.watch().listen((event) {
  //   print('sigterm');
  // });

  // ProcessSignal.
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

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
      body: SafeArea(
        child: Container(
          color: Color(0xFF3A3D3F),
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

  Tab buildPersuduTab() {
    final tab = TabController();

    // final pty = Pty();
    // final shell = Platform.environment['SHELL'] ?? 'sh';
    // final proc = pty.exec(shell, arguments: []);

    final terminal = Terminal(
      onTitleChange: tab.setTitle,
      // onInput: pty.write,
    );

    terminal.write('No Signal.');

    // terminal.debug.enable();

    final focusNode = FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });

    // readToTerminal(pty, terminal);

    // proc.wait().then((_) {
    //   tab.requestClose();
    // });

    return Tab(
      controller: tab,
      title: 'Terminal',
      content: GestureDetector(
        onSecondaryTap: () async {
          // final data = await Clipboard.getData('text/plain');
          // terminal.paste(data.text);
        },
        onSecondaryLongPress: () {
          // final data = ClipboardData(text: terminal.getSelectedText());
          // Clipboard.setData(data);
          // terminal.selection.clear();
          // terminal.refresh();
        },
        child: TerminalView(
          terminal: terminal,
          // onResize: pty.resize,
          focusNode: focusNode,
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
        // proc.kill();
      },
    );
  }

  Tab buildTab() {
    final tab = TabController();

    final pty = Pty();

    final terminal = Terminal(
      onTitleChange: tab.setTitle,
      onInput: pty.write,
      platform: getPlatform(),
    );

    terminal.debug.enable();
    final shell = getShell();
    final proc = pty.exec(shell, arguments: []);

    final focusNode = FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });

    readToTerminal(pty, terminal);

    proc.wait().then((_) {
      tab.requestClose();
    });

    return Tab(
      controller: tab,
      title: 'Terminal',
      content: GestureDetector(
        onSecondaryTap: () async {
          if (terminal.selection.isEmpty) {
            final data = await Clipboard.getData('text/plain');
            terminal.paste(data.text);
            terminal.debug.onMsg('paste ┤${data.text}├');
          } else {
            final text = terminal.getSelectedText();
            Clipboard.setData(ClipboardData(text: text));
            terminal.selection.clear();
            terminal.debug.onMsg('copy ┤$text├');
            terminal.refresh();
          }
        },
        child: TerminalView(
          terminal: terminal,
          onResize: pty.resize,
          focusNode: focusNode,
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
        proc.kill();
      },
    );
  }

  void readToTerminal(Pty pty, Terminal terminal) async {
    while (true) {
      final data = await pty.read();

      if (data == null) {
        break;
      }

      terminal.write(data);
    }
  }

  String getShell() {
    if (Platform.isWindows) {
      // return r'C:\windows\system32\cmd.exe';
      return r'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe';
    }

    return Platform.environment['SHELL'] ?? 'sh';
  }

  PlatformBehavior getPlatform() {
    if (Platform.isWindows) {
      return PlatformBehavior.windows;
    }

    return PlatformBehavior.unix;
  }
}
