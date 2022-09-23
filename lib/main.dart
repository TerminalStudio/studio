import 'dart:convert';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:flutter_pty/flutter_pty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/service/window_service.dart';
import 'package:studio/src/ui/context_menu.dart';
import 'package:studio/src/ui/platform_menu.dart';
import 'package:studio/src/ui/shortcut/global_actions.dart';
import 'package:studio/src/ui/shortcut/global_shortcuts.dart';
import 'package:studio/src/util/provider_logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await initAcrylic();

  await initWindow();

  runApp(
    const ProviderScope(
      observers: [ProviderLogger()],
      child: MyApp(),
    ),
  );
}

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  await windowManager.setBackgroundColor(const Color(0XE01E1E1E));
  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<void> initAcrylic() async {
  await acrylic.Window.initialize();
  await acrylic.Window.setEffect(
    effect: acrylic.WindowEffect.aero,
    color: const Color(0x00FFFFFF),
  );

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    await acrylic.Window.setBlurViewState(acrylic.MacOSBlurViewState.active);
    await acrylic.Window.makeTitlebarTransparent();
    // await acrylic.Window.setWindowAlphaValue(0.95);
    // await acrylic.Window.overrideMacOSBrightness(dark: true);
  }
}

final shellProvider = Provider<String>(
  name: 'Shell',
  (ref) {
    if (Platform.isMacOS || Platform.isLinux) {
      return Platform.environment['SHELL'] ?? 'bash';
    }

    if (Platform.isWindows) {
      return 'cmd.exe';
    }

    return 'sh';
  },
);

final terminalProvider = Provider<Terminal>(
  name: 'Terminal',
  (ref) {
    final terminal = Terminal(
      maxLines: 10000,
    );

    var _title = '';

    void updateTitle() {
      ref
          .read(windowServiceProvider)
          .setTitle('$_title — ${terminal.viewWidth}x${terminal.viewHeight}');
    }

    final pty = Pty.start(
      ref.watch(shellProvider),
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      exit(code);
    });

    terminal.onTitleChange = (title) {
      _title = title;
      updateTitle();
    };

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
      updateTitle();
    };

    return terminal;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContextMenuOverlay(
        cardBuilder: (context, children) =>
            TerminalContextMenuCard(children: children),
        child: const GlobalPlatformMenu(
          child: GlobalShortcuts(
            child: GlobalActions(
              child: Home(),
            ),
          ),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final terminalController = TerminalController();

  @override
  Widget build(BuildContext context) {
    GestureBinding.instance;
    RendererBinding.instance;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final terminal = ref.watch(terminalProvider);

            return ContextMenuRegion(
              enableLongPress: true,
              contextMenu: TerminalContextMenu(
                terminal: terminal,
                terminalController: terminalController,
              ),
              child: TerminalView(
                terminal,
                controller: terminalController,
                backgroundOpacity: 0,
                autofocus: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
