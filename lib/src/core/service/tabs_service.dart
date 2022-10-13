import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/conn.dart';
import 'package:terminal_studio/src/core/fs.dart';
import 'package:terminal_studio/src/core/plugin.dart';
import 'package:terminal_studio/src/core/service/active_tab_service.dart';
import 'package:terminal_studio/src/core/state/plugin.dart';
import 'package:terminal_studio/src/plugins/terminal/terminal_plugin.dart';
import 'package:terminal_studio/src/ui/tabs/code_editor_tab.dart';
import 'package:terminal_studio/src/ui/tabs/plugin_tab.dart';

class TabsService {
  final Ref ref;

  TabsService(this.ref);

  void openTerminal(HostSpec hostSpec, {Tabs? tabs, bool activate = true}) {
    return openPlugin(hostSpec, TerminalPlugin(),
        tabs: tabs, activate: activate);
  }

  void openPlugin(
    HostSpec host,
    Plugin plugin, {
    Tabs? tabs,
    bool activate = true,
  }) {
    openTab(
      PluginTab(plugin, ref.read(pluginManagerProvider(host))),
      tabs: tabs,
      activate: activate,
    );
  }

  void openFile(File file, {Tabs? tabs, bool activate = true}) {
    openTab(CodeEditorTab(file), tabs: tabs, activate: activate);
  }

  void openTab(TabItem tab, {Tabs? tabs, bool activate = true}) {
    final targetTabGroup =
        tabs ?? ref.read(activeTabServiceProvider).getActiveTabGroup();

    if (targetTabGroup == null) {
      return;
    }

    targetTabGroup.add(tab);

    if (activate) {
      tab.activate();
    }
  }
}

final tabsServiceProvider = Provider(
  name: 'tabsServiceProvider',
  (ref) => TabsService(ref),
);
