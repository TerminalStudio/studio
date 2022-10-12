import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/hosts/local_spec.dart';
import 'package:studio/src/core/service/tabs_service.dart';
import 'package:studio/src/core/state/database.dart';
import 'package:studio/src/ui/tabs/add_host_tab.dart';
import 'package:studio/src/ui/tabs/settings_tab/settings_tab.dart';
import 'package:studio/src/util/tabs_extension.dart';

class DropdownContextMenu extends ConsumerStatefulWidget {
  const DropdownContextMenu(this.tabs, {super.key});

  final Tabs tabs;

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends ConsumerState<DropdownContextMenu>
    with ContextMenuStateMixin {
  Tabs get tabs => widget.tabs;

  @override
  Widget build(BuildContext context) {
    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Local',
            icon: const Icon(FluentIcons.tablet),
            onPressed: () => handlePressed(context, () {
              final tabsService = ref.read(tabsServiceProvider);
              tabsService.openTerminal(LocalHostSpec());
            }),
          ),
        ),
        ...buildHosts(),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Add New',
            icon: const Icon(FluentIcons.add),
            onPressed: () => handlePressed(
              context,
              () => ref.openTab(AddHostTab()),
            ),
          ),
        ),
        buildDivider(),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Settings',
            icon: const Icon(FluentIcons.settings),
            onPressed: () => handlePressed(
              context,
              () => ref.openTab(SettingsTab()),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildHosts() {
    final sshHosts = ref.watch(sshHostBoxProvider).asData;

    if (sshHosts == null || sshHosts.value.isEmpty) {
      return [];
    }

    final items = <Widget>[];

    for (final host in sshHosts.value.values) {
      items.add(
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            host.name,
            icon: const Icon(FluentIcons.cloud),
            onPressed: () => handlePressed(context, () async {
              final tabsService = ref.read(tabsServiceProvider);
              tabsService.openTerminal(host, tabs: tabs);
            }),
          ),
        ),
      );
    }

    return items;
  }
}
