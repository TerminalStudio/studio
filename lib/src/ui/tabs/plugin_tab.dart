import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/plugin.dart';

class PluginTab extends TabItem {
  final Plugin plugin;

  final PluginManager manager;

  PluginTab(this.plugin, this.manager) {
    manager.add(plugin);

    _updateTitle();

    plugin.title.addListener(_updateTitle);

    manager.addListener(_onPluginManagerChanged);

    content.value = PluginTabView(plugin);
  }

  @override
  void didDispose() {
    if (plugin.mounted) {
      manager.remove(plugin);
    }
    plugin.title.removeListener(_updateTitle);
    manager.removeListener(_onPluginManagerChanged);
    super.didDispose();
  }

  void _updateTitle() {
    final titleWidget = plugin.title.value;
    title.value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleWidget != null)
          Flexible(
            child: Text(
              titleWidget,
              softWrap: false,
            ),
          ),
        if (titleWidget != null) const SizedBox(width: 4),
        Text(
          manager.hostSpec.name,
          style: const TextStyle(
            fontSize: 10,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
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
