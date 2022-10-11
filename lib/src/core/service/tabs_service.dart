import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/conn.dart';
import 'package:studio/src/core/fs.dart';
import 'package:studio/src/core/plugin.dart';
import 'package:studio/src/core/service/active_tab_service.dart';
import 'package:studio/src/core/state/plugin.dart';
import 'package:studio/src/plugins/terminal/terminal_plugin.dart';
import 'package:studio/src/ui/tabs/code_editor_tab.dart';
import 'package:studio/src/ui/tabs/plugin_tab.dart';

class TabsService {
  final Ref ref;

  TabsService(this.ref);

  void openTerminal(HostSpec hostSpec, {Tabs? tabs}) {
    return openPlugin(hostSpec, TerminalPlugin(), tabs: tabs);
  }

  void openFile(File file, {Tabs? tabs}) {
    final targetTabs =
        tabs ?? ref.read(activeTabServiceProvider).getActiveTabGroup();

    targetTabs?.add(CodeEditorTab(file));
  }

  void openPlugin(HostSpec host, Plugin plugin, {Tabs? tabs}) {
    final targetTabs =
        tabs ?? ref.read(activeTabServiceProvider).getActiveTabGroup();

    if (targetTabs == null) {
      return;
    }

    targetTabs.add(PluginTab(plugin, ref.read(pluginManagerProvider(host))));
  }
}

final tabsServiceProvider = Provider(
  name: 'tabsServiceProvider',
  (ref) => TabsService(ref),
);
