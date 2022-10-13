import 'package:flex_tabs/flex_tabs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/ui/tabs/settings_tab/settings_tab_hosts.dart';

class SettingsTab extends TabItem {
  SettingsTab() {
    title.value = const Text('Settings');
    content.value = const SettingsView();
  }
}

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) => NavigationView(
        pane: NavigationPane(
          selected: _selectedIndex,
          onChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          displayMode: PaneDisplayMode.open,
          size: const NavigationPaneSize(
            openWidth: 200,
            openMinWidth: 200,
          ),
          items: [
            PaneItemHeader(header: const Text('Settings')),
            PaneItemSeparator(),
            PaneItem(
              icon: const Icon(FluentIcons.server),
              title: const Text('Hosts'),
              body: const HostsSettingView(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.key_phrase_extraction),
              title: const Text('SSH keys'),
              body: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}
