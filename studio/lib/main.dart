import 'dart:io';

import 'package:context_menu_macos/context_menu_macos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pty/pty.dart';
import 'package:studio/shortcut/intents.dart';
import 'package:studio/shortcut/terminal_shortcut.dart';
import 'package:studio/terminal_search_bar.dart';
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

    final focusNode = FocusNode(
      skipTraversal:
          true, //this is needed so that Tabs in the Terminal don't lead to a focus jump
    );

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

  final searchTextController = TextEditingController();
  late final FocusNode focusNodeUserSearchInput;
  var _isUserSearchActive = false;

  void _onTerminalChanges() {
    if (widget.terminal.isUserSearchActive != _isUserSearchActive) {
      setState(() {
        _isUserSearchActive = widget.terminal.isUserSearchActive;
      });
    }
  }

  @override
  void initState() {
    searchTextController.text = widget.terminal.userSearchPattern ?? "";
    searchTextController.addListener(() {
      if (searchTextController.text == '') {
        widget.terminal.userSearchPattern = null;
      } else {
        widget.terminal.userSearchPattern = searchTextController.text;
      }
    });
    focusNodeUserSearchInput = FocusNode(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          disableSearch();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
    widget.terminal.addListener(_onTerminalChanges);
    super.initState();
  }

  @override
  void dispose() {
    widget.terminal.removeListener(_onTerminalChanges);
    super.dispose();
  }

  List<TerminalShortcut> getShortcuts() => [
        TerminalShortcut(
            name: 'Zoom In',
            onExecute: (terminal) async => onZoomIn(),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.add),
              _withModifier(LogicalKeyboardKey.equal),
            ],
            intent: ZoomInIntent()),
        TerminalShortcut(
            name: 'Zoom Out',
            onExecute: (terminal) async => onZoomOut(),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.minus),
            ],
            intent: ZoomOutIntent()),
        TerminalShortcut(
            name: 'Copy',
            onExecute: (terminal) async => onCopy(terminal),
            onIsAvailable: (terminal) async {
              final hasSelection =
                  !(widget.terminal.selection?.isEmpty ?? true);
              return hasSelection;
            },
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyC, needsExtraModifier: true),
            ],
            intent: CopyIntent()),
        TerminalShortcut(
            name: 'Paste',
            onExecute: (terminal) async => onPaste(terminal),
            onIsAvailable: (terminal) async {
              final clipboardData = await Clipboard.getData('text/plain');

              final clipboardHasData = clipboardData?.text?.isNotEmpty == true;

              return clipboardHasData;
            },
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyV, needsExtraModifier: true),
            ],
            intent: PasteIntent()),
        TerminalShortcut(
            name: 'Select all',
            onExecute: (terminal) async => onSelectAll(terminal),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyA, needsExtraModifier: true),
            ],
            intent: SelectAllIntent()),
        TerminalShortcut(
            name: 'Clear',
            onExecute: (terminal) async => onClear(terminal),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyK, needsExtraModifier: true),
            ],
            intent: ClearIntent()),
        TerminalShortcut(
            name: 'Kill',
            onExecute: (terminal) async => onKill(terminal),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyE, needsExtraModifier: true),
            ],
            intent: KillIntent()),
        TerminalShortcut(
            name: 'Search',
            onExecute: (terminal) async => onSearch(),
            keyCombinations: [
              _withModifier(LogicalKeyboardKey.keyF, needsExtraModifier: false),
            ],
            intent: SearchIntent()),
      ];

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
      BuildContext context, TerminalUiInteraction terminal) async {
    final result = List<MacosContextMenuItem>.empty(growable: true);
    final shortcuts = getShortcuts();

    for (final shortcut in shortcuts) {
      final firstAlternative = shortcut.keyCombinations[0];
      result.add(MacosContextMenuItem(
        content: Text(shortcut.name),
        trailing: Text(_shortcutKeysToString(firstAlternative.triggers)),
        enabled: await shortcut.isAvailable(terminal),
        onTap: () async {
          await shortcut.execute(terminal);
          Navigator.of(context).pop();
        },
      ));
    }
    return result;
  }

  static Map<ShortcutActivator, Intent> shortcutsToActivatorMap(
      List<TerminalShortcut> shortcuts) {
    final result = Map<ShortcutActivator, Intent>();

    for (final shortcut in shortcuts) {
      for (final keyCombination in shortcut.keyCombinations) {
        result.putIfAbsent(keyCombination, () => shortcut.intent);
      }
    }

    return result;
  }

  static Map<Type, Action<Intent>> shortcutsToActions(
      List<TerminalShortcut> shortcuts, TerminalUiInteraction terminal) {
    final result = Map<Type, Action<Intent>>();

    for (final shortcut in shortcuts) {
      result.putIfAbsent(
          shortcut.intent.runtimeType,
          () => CallbackAction(
                onInvoke: (intent) => shortcut.execute(terminal),
              ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = getShortcuts();
    return Stack(children: [
      Shortcuts(
        shortcuts: shortcutsToActivatorMap(shortcuts),
        child: Actions(
          actions: shortcutsToActions(shortcuts, widget.terminal),
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
                children:
                    await createContextMenuItems(context, widget.terminal),
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
      ),
      Visibility(
        child: TerminalSearchBar(
          terminal: widget.terminal,
          focusNode: focusNodeUserSearchInput,
          searchTextController: searchTextController,
        ),
        visible: _isUserSearchActive,
      ),
    ]);
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

  void onZoomIn() {
    updateFontSize(1);
  }

  void onZoomOut() {
    updateFontSize(-1);
  }

  void onCopy(TerminalUiInteraction terminal) {
    final text = terminal.selectedText ?? '';
    Clipboard.setData(ClipboardData(text: text));
    terminal.clearSelection();
    //terminal.debug.onMsg('copy ┤$text├');
    terminal.refresh();
  }

  void onPaste(TerminalUiInteraction terminal) async {
    final clipboardData = await Clipboard.getData('text/plain');

    final clipboardHasData = clipboardData?.text?.isNotEmpty == true;

    if (clipboardHasData) {
      terminal.paste(clipboardData!.text!);
      //terminal.debug.onMsg('paste ┤${clipboardData.text}├');
    }
  }

  void onSelectAll(TerminalUiInteraction terminal) {
    print('Select All is currently not implemented.');
  }

  void onClear(TerminalUiInteraction terminal) {
    print('Clear is currently not implemented.');
  }

  void onKill(TerminalUiInteraction terminal) {
    terminal.terminateBackend();
  }

  void disableSearch() {
    if (!widget.terminal.isUserSearchActive) {
      return;
    }
    widget.terminal.isUserSearchActive = false;
    widget.focusNode.requestFocus();
  }

  void onSearch() {
    widget.terminal.isUserSearchActive = true;
    // sets the initial search to the currently selected text if
    // there is something selected and if there is no search term already
    if (widget.terminal.selectedText != null &&
        widget.terminal.userSearchPattern == null) {
      searchTextController.text = widget.terminal.selectedText!;
      widget.terminal.userSearchPattern = searchTextController.text;
    } else if (widget.terminal.userSearchPattern != null) {
      searchTextController.text = widget.terminal.userSearchPattern!;
    } else {
      searchTextController.text = '';
    }
    focusNodeUserSearchInput.requestFocus();
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
