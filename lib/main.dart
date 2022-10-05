import 'dart:async';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:studio/src/hosts/local_spec.dart';
import 'package:studio/src/core/service/tabs_service.dart';
import 'package:studio/src/core/state/tabs.dart';
import 'package:studio/src/ui/context_menu.dart';
import 'package:studio/src/ui/platform_menu.dart';
import 'package:studio/src/ui/shared/macos_titlebar.dart';
import 'package:studio/src/ui/shortcut/global_actions.dart';
import 'package:studio/src/ui/shortcut/global_shortcuts.dart';
import 'package:studio/src/util/provider_logger.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initWindow();

  runApp(
    const ProviderScope(
      observers: [ProviderLogger()],
      child: MyApp(),
    ),
  );
}

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  await windowManager.setBackgroundColor(const Color(0x00000000));
  await windowManager.setTitle('TerminalStudio');

  if (defaultTargetPlatform != TargetPlatform.macOS) {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget = const GlobalShortcuts(
      child: GlobalActions(
        child: Home(),
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      widget = GlobalPlatformMenu(
        child: widget,
      );
    }

    widget = ContextMenuOverlay(
      child: widget,
    );

    return MacosApp(
      title: 'TerminalStudio',
      debugShowCheckedModeBanner: false,
      home: widget,
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final tabsTheme = const TabsViewThemeData();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await initTabs();
    });
    super.initState();
  }

  Future<void> initTabs() async {
    final root = Tabs();

    ref.read(tabsServiceProvider).openTerminal(LocalHostSpec(), tabs: root);

    final document = ref.watch(tabsProvider);

    document.addListener(_onDocumentChanged);

    document.setRoot(root);
  }

  void _onDocumentChanged() {
    final document = ref.read(tabsProvider);

    document.root?.addListener(_onRootChanged);
  }

  void _onRootChanged() {
    final document = ref.read(tabsProvider);

    if (document.root == null || document.root!.children.isEmpty) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      children: [
        _buildTitlebar(context),
        Expanded(
          child: TabsView(
            ref.watch(tabsProvider),
            theme: tabsTheme,
            actionBuilder: buildTabActions,
          ),
        ),
      ],
    );

    // if (defaultTargetPlatform == TargetPlatform.windows) {
    //   widget = VirtualWindowFrame(child: widget);
    // }

    return widget;
  }

  Widget _buildTitlebar(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return MacosTitlebar(
        color: tabsTheme.selectedBackgroundColor,
      );
    }

    return SizedBox(
      height: kWindowCaptionHeight,
      child: WindowCaption(
        backgroundColor: tabsTheme.selectedBackgroundColor,
        brightness: Brightness.light,
        title: const Text('TerminalStudio'),
      ),
    );
  }

  List<TabsViewAction> buildTabActions(Tabs tabs) {
    return [
      TabsViewAction(
        icon: CupertinoIcons.chevron_down,
        onPressed: () {
          context.contextMenuOverlay.show(
            DropdownContextMenu(tabs),
          );
        },
      ),
      TabsViewAction(
        icon: CupertinoIcons.add,
        onPressed: () {
          ref
              .watch(tabsServiceProvider)
              .openTerminal(LocalHostSpec(), tabs: tabs);
        },
      ),
    ];
  }
}
