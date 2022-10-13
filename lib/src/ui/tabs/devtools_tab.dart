import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:terminal_studio/src/core/state/database.dart';
import 'package:terminal_studio/src/ui/tabs/add_host_tab.dart';
import 'package:terminal_studio/src/ui/tabs/playground.dart';
import 'package:terminal_studio/src/util/tabs_extension.dart';
import 'package:xterm/xterm.dart';

class DevToolsTab extends TabItem {
  DevToolsTab() {
    title.value = const Text('DevTools');
    content.value = DevToolsTabView(this);
  }

  final terminal = Terminal();
}

class DevToolsTabView extends ConsumerStatefulWidget {
  const DevToolsTabView(this.tab, {super.key});

  final DevToolsTab tab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DevToolsTabViewState();
}

class _DevToolsTabViewState extends ConsumerState<DevToolsTabView> {
  DevToolsTab get tab => widget.tab;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                PushButton(
                  buttonSize: ButtonSize.large,
                  onPressed: _openAddHostTab,
                  child: const Text('Add SSH host'),
                ),
                PushButton(
                  buttonSize: ButtonSize.large,
                  onPressed: _clearHosts,
                  child: const Text('Clear SSH hosts'),
                ),
                PushButton(
                  buttonSize: ButtonSize.large,
                  onPressed: () => tab.replace(PlaygroundTab()),
                  child: const Text('Playground'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: TerminalView(tab.terminal),
            ),
            // const PlayGround(),
          ],
        ),
      ),
    );
  }

  void _openAddHostTab() {
    // ref.openTab(AddHostTab());
  }

  void _clearHosts() async {
    final sshHosts = await ref.read(sshHostBoxProvider.future);
    await sshHosts.clear();
    tab.terminal.write('Cleared SSH hosts\r\n');
  }
}

class PlayGround extends ConsumerWidget {
  const PlayGround({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(16),
      color: const Color.fromARGB(255, 251, 251, 251),
      // child:
    );
  }
}
