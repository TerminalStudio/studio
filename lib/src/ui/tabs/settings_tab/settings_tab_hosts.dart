import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:terminal_studio/src/core/state/database.dart';
import 'package:terminal_studio/src/ui/pages/host_edit_page.dart';

class HostsSettingView extends ConsumerStatefulWidget {
  const HostsSettingView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HostsSettingViewState();
}

class _HostsSettingViewState extends ConsumerState<HostsSettingView> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Hosts'),
        commandBar: Expanded(
          child: _buildCommandBar(context),
        ),
      ),
      children: [
        _buildSSHHosts(),
      ],
    );
  }

  Widget _buildCommandBar(BuildContext context) {
    return CommandBar(
      mainAxisAlignment: MainAxisAlignment.end,
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FontAwesomeIcons.plus),
          label: const Text('Add'),
          onPressed: () {
            Navigator.of(context).push(
              FluentPageRoute(
                builder: (context) => const HostEditPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSSHHosts() {
    final hosts = ref.watch(sshHostsProvider);

    return hosts.when(
      loading: () => const Center(child: ProgressRing()),
      error: (e, st) => Text('Error: $e'),
      data: (box) => ListView.builder(
        shrinkWrap: true,
        itemCount: box.length,
        itemBuilder: (context, index) {
          final record = box[index];
          return ListTile(
            title: Text(record.name),
            subtitle: Text('${record.host}:${record.port}'),
            leading: const FaIcon(FontAwesomeIcons.computer),
            onPressed: () {
              Navigator.of(context).push(
                FluentPageRoute(
                  builder: (context) => HostEditPage(record: record),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
