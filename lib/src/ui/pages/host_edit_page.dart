import 'package:flex_tabs/flex_tabs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/record/ssh_host_record.dart';
import 'package:terminal_studio/src/core/state/database.dart';
import 'package:terminal_studio/src/ui/shared/fluent_back_button.dart';
import 'package:terminal_studio/src/ui/shared/fluent_form.dart';
import 'package:terminal_studio/src/ui/shared/fluent_navigator.dart';
import 'package:terminal_studio/src/util/validators.dart';

class HostEditPage extends ConsumerStatefulWidget {
  const HostEditPage({super.key, this.record});

  final SSHHostRecord? record;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HostEditDialogState();
}

class _HostEditDialogState extends ConsumerState<HostEditPage> {
  bool get isEditing => widget.record != null;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text(isEditing ? 'Edit Host' : 'Add Host'),
        leading:
            Navigator.of(context).canPop() ? const FluentBackButton() : null,
        actions: FluentNavigatorCommandBar(
          primaryItems: [
            if (isEditing)
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () async {
                  if (widget.record != null) {
                    await widget.record!.delete();
                  }
                  close();
                },
              ),
          ],
        ),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: 0,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.server),
            title: const Text('Host'),
            body: SSHHostEditForm(
              record: widget.record,
              onSaved: _onSaved,
            ),
          ),
        ],
      ),
      // content: SSHHostEditForm(
      //   record: widget.record,
      //   onSaved: _onSaved,
      // ),
    );
  }

  Future<void> _onSaved(record) async {
    final box = await ref.read(sshHostBoxProvider.future);
    if (record.isInBox) {
      record.save();
    } else {
      box.add(record);
    }
    close();
  }

  void close() {
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        return Navigator.of(context).pop();
      }

      if (TabScope.of(context) != null) {
        return TabScope.of(context)!.dispose();
      }
    }
  }
}

class SSHHostEditForm extends ConsumerStatefulWidget {
  const SSHHostEditForm({super.key, this.record, this.onSaved});

  final SSHHostRecord? record;

  final void Function(SSHHostRecord record)? onSaved;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HostEditFormState();
}

class _HostEditFormState extends ConsumerState<SSHHostEditForm> {
  final formKey = GlobalKey<FormState>();

  late final record = widget.record ?? SSHHostRecord.uninitialized();

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const FluentFormDivider(),
              TextFormBox(
                header: 'Label',
                initialValue: record.name,
                onSaved: (value) => record.name = value!,
              ),
            ],
          ),
        ),
        const FluentFormSeparator(),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormBox(
                header: 'Host',
                initialValue: record.host,
                placeholder: 'example.com / 1.2.3.4',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Host is required';
                  return isHostOrIP(value) ? null : 'Invalid host or IP';
                },
                onSaved: (value) => record.host = value!,
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'Port',
                initialValue: record.port.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Port is required';
                  return isPort(value) ? null : 'Invalid port';
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) => record.port = int.parse(value!),
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'User',
                initialValue: record.username,
                placeholder: 'root',
                onSaved: (value) => record.username = value,
              ),
              const FluentFormDivider(),
              TextFormBox(
                header: 'Password',
                placeholder: '',
                initialValue: record.password,
                obscureText: true,
                onSaved: (value) => record.password = value,
              ),
            ],
          ),
        ),
        const FluentFormSeparator(),
        // Card(
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
        Card(
          child: Row(
            children: [
              FilledButton(
                onPressed: _submitForm,
                child: const Text('Save'),
              ),
              const SizedBox(width: 8),
              Button(
                child: const Text('Test Connection'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );

    widget = Form(
      key: formKey,
      child: widget,
    );

    widget = Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 500,
        child: widget,
      ),
    );

    widget = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: widget,
    );

    return widget;
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      widget.onSaved?.call(record);
    }
  }
}
