import 'dart:async';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/ui/context_menu.dart';
import 'package:studio/src/ui/platform_menu.dart';
import 'package:studio/src/ui/shortcut/global_actions.dart';
import 'package:studio/src/ui/shortcut/global_shortcuts.dart';
import 'package:studio/src/ui/tabs/terminal_tab.dart';
import 'package:studio/src/util/provider_logger.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await windowManager.setBackgroundColor(const Color(0xE01E1E1E));
  await windowManager.setTitle('TerminalStudio');
  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'TerminalStudio',
      debugShowCheckedModeBanner: false,
      home: ContextMenuOverlay(
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
  final document = TabsDocument();

  final tabsTheme = const TabsViewThemeData();

  @override
  void initState() {
    final root = Tabs();

    var terminalTab = TerminalTab();

    root.add(terminalTab);

    document.setRoot(root);

    document.addListener(_onDocumentChanged);

    super.initState();
  }

  void _onDocumentChanged() {
    if (document.root == null || document.root!.children.isEmpty) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (defaultTargetPlatform == TargetPlatform.macOS)
          _buildTitlebar(context),
        Expanded(
          child: TabsView(
            document,
            theme: tabsTheme,
            actionBuilder: buildTabActions,
          ),
        ),
      ],
    );
  }

  Widget _buildTitlebar(BuildContext context) {
    return Container(
      height: 28,
      color: tabsTheme.selectedBackgroundColor,
    );
  }

  List<TabsViewAction> buildTabActions(Tabs tabs) {
    return [
      TabsViewAction(
        icon: CupertinoIcons.chevron_down,
        onPressed: () {
          context.contextMenuOverlay.show(
            const DropdownContextMenu(),
          );
        },
      ),
      TabsViewAction(
        icon: CupertinoIcons.add,
        onPressed: () {
          final tab = TerminalTab();
          tabs.add(tab);
          tab.activate();
        },
      ),
    ];
  }
}
