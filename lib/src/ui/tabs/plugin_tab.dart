import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/plugin.dart';

class PluginTab extends TabItem {
  final Plugin plugin;

  final PluginManager manager;

  PluginTab(this.plugin, this.manager) {
    manager.add(plugin);

    plugin.title.addListener(_updateTitle);

    manager.addListener(_onPluginManagerChanged);

    _updateTitle();

    content.value = PluginTabView(plugin);
  }

  @override
  void detach() {
    // if (plugin.mounted) {
    //   manager.remove(plugin);
    // }
    // plugin.title.removeListener(_updateTitle);
    // manager.removeListener(_onPluginManagerChanged);
    super.detach();
  }

  void _updateTitle() {
    title.value = plugin.title.value;
  }

  void _onPluginManagerChanged() {
    if (!plugin.mounted) {
      detach();
    }
  }
}

class PluginTabView extends ConsumerStatefulWidget {
  const PluginTabView(this.plugin, {super.key});

  final Plugin plugin;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PluginTabViewState();
}

class _PluginTabViewState extends ConsumerState<PluginTabView> {
  Plugin get plugin => widget.plugin;

  @override
  Widget build(BuildContext context) {
    return plugin.build(context);
  }
}
