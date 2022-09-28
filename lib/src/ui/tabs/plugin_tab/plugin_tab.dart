import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/host.dart';
import 'package:studio/src/core/plugin.dart';

class PluginTab extends TabItem {
  final Host host;

  final Plugin plugin;

  PluginTab(this.host, this.plugin) {
    plugin.mount(host);
    content.value = PluginTabView(plugin);
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
