import 'dart:io';

import 'package:context_menu_macos/context_menu_macos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pty/pty.dart';
import 'package:studio/shortcut/intents.dart';
import 'package:studio/utils/build_mode.dart';
import 'package:studio/utils/pty_terminal_backend.dart';
import 'package:tabs/tabs.dart';

import 'package:flutter/material.dart' hide Tab, TabController;
import 'package:xterm/flutter.dart';
import 'package:xterm/isolate.dart';
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

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });

    terminal.backendExited.then((_) => tab.requestClose());

    return Tab(
      controller: tab,
      title: 'Terminal',
      content: TerminalTab(
        terminal: terminal,
        focusNode: focusNode,
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

class TerminalTab extends StatefulWidget {
  TerminalTab({
    required this.terminal,
    required this.focusNode,
  });

  final TerminalUiInteraction terminal;
  final FocusNode focusNode;
  final scrollController = ScrollController();

  @override
  State<TerminalTab> createState() => _TerminalTabState();
}

class _TerminalTabState extends State<TerminalTab> {
  var fontSize = 14.0;

  Future<Map<List<ShortcutActivator>, TerminalIntent>> get shortcuts async {
    final clipboardData = await Clipboard.getData('text/plain');

    final hasSelection = !(widget.terminal.selection?.isEmpty ?? true);
    final clipboardHasData = clipboardData?.text?.isNotEmpty == true;

    return {
      [
        _withModifier(LogicalKeyboardKey.add),
        _withModifier(LogicalKeyboardKey.equal),
      ]: FontSizeIncreaseIntent(1, true),
      [_withModifier(LogicalKeyboardKey.minus)]:
          FontSizeDecreaseIntent(1, true),
      [_withModifier(LogicalKeyboardKey.keyC, needsExtraModifier: true)]:
          CopyIntent(widget.terminal, hasSelection),
      [_withModifier(LogicalKeyboardKey.keyV, needsExtraModifier: true)]:
          PasteIntent(widget.terminal, clipboardHasData),
      [_withModifier(LogicalKeyboardKey.keyA, needsExtraModifier: true)]:
          SelectAllIntent(widget.terminal, clipboardHasData),
      [_withModifier(LogicalKeyboardKey.keyK, needsExtraModifier: true)]:
          ClearIntent(widget.terminal, clipboardHasData),
      [_withModifier(LogicalKeyboardKey.keyE, needsExtraModifier: true)]:
          KillIntent(widget.terminal, clipboardHasData),
    };
  }

  Map<Type, Action<Intent>> get actions => {
        FontSizeIncreaseIntent: CallbackAction<FontSizeIncreaseIntent>(
          onInvoke: onFontSizeIncreaseIntent,
        ),
        FontSizeDecreaseIntent: CallbackAction<FontSizeDecreaseIntent>(
          onInvoke: onFontSizeDecreaseIntent,
        ),
        CopyIntent: CallbackAction<CopyIntent>(
          onInvoke: onCopyIntent,
        ),
        PasteIntent: CallbackAction<PasteIntent>(
          onInvoke: onPasteIntent,
        ),
        SelectAllIntent: CallbackAction<SelectAllIntent>(
          onInvoke: onSelectAllIntent,
        ),
        ClearIntent: CallbackAction<ClearIntent>(
          onInvoke: onClearIntent,
        ),
        KillIntent: CallbackAction<KillIntent>(
          onInvoke: onKillIntent,
        ),
      };

  String _shortcutKeysToString(Iterable<LogicalKeyboardKey>? triggers) {
    if (triggers == null) {
      return '';
    }
    String specialKeySequence = '';
    String normalKeySequence = '';
    var metaHandled = false;
    var controlHandled = false;
    var altHandled = false;
    var shiftHandled = false;
    for (final trigger in triggers) {
      if (trigger == LogicalKeyboardKey.meta ||
          trigger == LogicalKeyboardKey.metaLeft ||
          trigger == LogicalKeyboardKey.metaRight) {
        if (metaHandled) {
          continue;
        }
        specialKeySequence += '⌘';
        metaHandled = true;
      } else if (trigger == LogicalKeyboardKey.shift ||
          trigger == LogicalKeyboardKey.shiftLeft ||
          trigger == LogicalKeyboardKey.shiftRight) {
        if (shiftHandled) {
          continue;
        }
        specialKeySequence += '⇧';
        shiftHandled = true;
      } else if (trigger == LogicalKeyboardKey.control ||
          trigger == LogicalKeyboardKey.controlLeft ||
          trigger == LogicalKeyboardKey.controlRight) {
        if (controlHandled) {
          continue;
        }
        specialKeySequence += '⌃';
        controlHandled = true;
      } else if (trigger == LogicalKeyboardKey.alt ||
          trigger == LogicalKeyboardKey.altLeft ||
          trigger == LogicalKeyboardKey.altRight) {
        if (altHandled) {
          continue;
        }
        specialKeySequence += '⌥';
        altHandled = true;
      } else {
        normalKeySequence += trigger.keyLabel;
      }
    }
    return '$specialKeySequence $normalKeySequence';
  }

  Future<List<MacosContextMenuItem>> createContextMenuItems(
      BuildContext context) async {
    final result = List<MacosContextMenuItem>.empty(growable: true);
    final actionsWidget = Actions.of(context);
    final s = await shortcuts;
    for (final shortcutEntry in s.entries) {
      final firstAlternative = shortcutEntry.key[0];
      result.add(MacosContextMenuItem(
        content: Text(shortcutEntry.value.name),
        trailing: Text(_shortcutKeysToString(firstAlternative.triggers)),
        enabled: shortcutEntry.value.isEnabled,
        onTap: () {
          final action = actions[shortcutEntry.value.runtimeType];
          if (action != null) {
            actionsWidget.invokeAction(action, shortcutEntry.value, context);
          }
          Navigator.of(context).pop();
        },
      ));
    }
    return result;
  }

  static Map<ShortcutActivator, TerminalIntent> flattenShortcuts(
      Map<List<ShortcutActivator>, TerminalIntent> shortcuts) {
    final result = Map<ShortcutActivator, TerminalIntent>();
    for (final entry in shortcuts.entries) {
      for (final activator in entry.key) {
        result.putIfAbsent(activator, () => entry.value);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<List<ShortcutActivator>, TerminalIntent>>(
        future: shortcuts,
        builder: (context,
            AsyncSnapshot<Map<List<ShortcutActivator>, TerminalIntent>>
                snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Shortcuts(
                  shortcuts: flattenShortcuts(snapshot.data!),
                  child: Actions(
                    actions: actions,
                    child: GestureDetector(
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
                        showMacosContextMenu(
                          context: context,
                          globalPosition: details.globalPosition,
                          children: await createContextMenuItems(context),
                        );
                      },
                      child: CupertinoScrollbar(
                        controller: widget.scrollController,
                        isAlwaysShown: true,
                        child: TerminalView(
                          scrollController: widget.scrollController,
                          terminal: widget.terminal,
                          focusNode: widget.focusNode,
                          opacity: 0.85,
                          style: TerminalStyle(
                            fontSize: fontSize,
                            fontFamily: const ['Cascadia Mono'],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
        });
  }

  void updateFontSize(int delta) {
    final minFontSize = 4;
    final maxFontSize = 40;

    final newFontSize = fontSize + delta;

    if (newFontSize < minFontSize || newFontSize > maxFontSize) {
      return;
    }

    setState(() => fontSize = newFontSize);
  }

  void onFontSizeIncreaseIntent(FontSizeIncreaseIntent intent) {
    updateFontSize(1);
  }

  void onFontSizeDecreaseIntent(FontSizeDecreaseIntent intent) {
    updateFontSize(-1);
  }

  void onCopyIntent(CopyIntent intent) {
    final text = intent.terminal.selectedText ?? '';
    Clipboard.setData(ClipboardData(text: text));
    intent.terminal.clearSelection();
    //terminal.debug.onMsg('copy ┤$text├');
    intent.terminal.refresh();
  }

  void onPasteIntent(PasteIntent intent) async {
    final clipboardData = await Clipboard.getData('text/plain');

    final clipboardHasData = clipboardData?.text?.isNotEmpty == true;

    if (clipboardHasData) {
      intent.terminal.paste(clipboardData!.text!);
      //terminal.debug.onMsg('paste ┤${clipboardData.text}├');
    }
  }

  void onSelectAllIntent(SelectAllIntent intent) {
    print('Select All is currently not implemented.');
  }

  void onClearIntent(ClearIntent intent) {
    print('Clear is currently not implemented.');
  }

  void onKillIntent(KillIntent intent) {
    intent.terminal.terminateBackend();
  }
}

LogicalKeySet _withModifier(LogicalKeyboardKey key,
    {needsExtraModifier = false}) {
  final modifier = List<LogicalKeyboardKey>.empty(growable: true);

  if (Platform.isMacOS) {
    modifier.add(LogicalKeyboardKey.meta);
  } else {
    modifier.add(LogicalKeyboardKey.control);
    if (needsExtraModifier) {
      modifier.add(LogicalKeyboardKey.shift);
    }
  }
  return modifier.length == 1
      ? LogicalKeySet(modifier[0], key)
      : modifier.length == 2
          ? LogicalKeySet(modifier[0], modifier[1], key)
          : throw ArgumentError.value(
              modifier.length, 'modifier', 'Unexpected number of modifiers!');
}
