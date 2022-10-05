import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/hosts/local_spec.dart';
import 'package:studio/src/core/service/tabs_service.dart';
import 'package:studio/src/core/state/database.dart';
import 'package:studio/src/ui/tabs/add_host_tab.dart';
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
            icon: const Icon(Icons.computer_outlined),
            onPressed: () => handlePressed(context, () {
              final tabsService = ref.read(tabsServiceProvider);
              tabsService.openTerminal(LocalHostSpec());
            }),
          ),
        ),
        buildDivider(),
        ...buildHosts(),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Add New',
            icon: const Icon(Icons.add),
            onPressed: () => handlePressed(context, handleAddHost),
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
            icon: const Icon(Icons.computer_outlined),
            onPressed: () => handlePressed(context, () async {
              final tabsService = ref.read(tabsServiceProvider);
              tabsService.openTerminal(host, tabs: tabs);
            }),
          ),
        ),
      );
    }

    items.add(buildDivider());

    return items;
  }

  Future<void> handleAddHost() async {
    ref.openTab(AddHostTab());
  }
}
