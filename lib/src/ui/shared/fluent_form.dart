import 'package:fluent_ui/fluent_ui.dart';

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

class FluentFormSeparator extends StatelessWidget {
  const FluentFormSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8);
  }
}
