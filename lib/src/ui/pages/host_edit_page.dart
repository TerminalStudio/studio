import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/ui/shared/fluent_back_button.dart';

class HostEditPage extends ConsumerStatefulWidget {
  const HostEditPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HostEditDialogState();
}

class _HostEditDialogState extends ConsumerState<HostEditPage> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Edit Host'),
        leading:
            Navigator.of(context).canPop() ? const FluentBackButton() : null,
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: 0,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.server),
            title: const Text('Host'),
            body: const HostEditForm(),
          ),
        ],
      ),
    );
  }
}

class HostEditForm extends ConsumerStatefulWidget {
  const HostEditForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HostEditFormState();
}

class _HostEditFormState extends ConsumerState<HostEditForm> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      children: [
        FluentFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormBox(header: 'Label'),
              const FluentFormDivider(),
              const FluentFormHeader('Protocol'),
              ComboboxFormField(
                value: 'ssh',
                items: const [
                  ComboBoxItem(
                    value: 'ssh',
                    child: Text('SSH'),
                  ),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        const FluentCardSeparator(),
        FluentFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormBox(
                header: 'Host',
                placeholder: 'example.com / 1.2.3.4',
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'Port',
                initialValue: '22',
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'User',
                initialValue: 'root',
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'Password',
                placeholder: '',
              ),
            ],
          ),
        ),
        const FluentCardSeparator(),
        // FluentFormCard(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       TextFormBox(
        //         header: 'Private Key',
        //         placeholder: '',
        //       ),
        //       const FluentFormDivider(),
        //       TextFormBox(
        //         header: 'Passphrase',
        //         placeholder: '',
        //       ),
        //     ],
        //   ),
        // ),
        FluentFormCard(
          child: Row(
            children: [
              FilledButton(
                child: Text('Save'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Button(
                child: Text('Test Connection'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FluentFormDivider extends StatelessWidget {
  const FluentFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }
}

class FluentFormHeader extends StatelessWidget {
  const FluentFormHeader(this.header, {super.key});

  final String header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(header),
        const SizedBox(height: 8),
      ],
    );
  }
}

class FluentFormCard extends StatelessWidget {
  const FluentFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 500,
        child: Card(child: child),
      ),
    );
  }
}

class FluentCardSeparator extends StatelessWidget {
  const FluentCardSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8);
  }
}
