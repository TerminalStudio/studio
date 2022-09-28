import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosFormRow extends StatelessWidget {
  static const labelWidth = 100.0;

  static const spaceBetween = 8.0;

  final Widget? label;

  final Widget child;

  const MacosFormRow({
    super.key,
    this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          if (label != null)
            Container(
              width: labelWidth,
              alignment: Alignment.centerRight,
              child: label,
            ),
          if (label != null)
            const SizedBox(
              width: spaceBetween,
            ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class MacosTextFormRow extends ConsumerWidget {
  final Widget? label;

  final String? placeholder;

  final bool obscureText;

  final void Function(String)? onChanged;

  final TextEditingController? controller;

  const MacosTextFormRow({
    super.key,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MacosFormRow(
      label: label,
      child: MacosTextField(
        padding: const EdgeInsets.symmetric(vertical: 4),
        placeholder: placeholder,
        obscureText: obscureText,
        decoration: kDefaultRoundedBorderDecoration.copyWith(
          borderRadius: BorderRadius.circular(1),
        ),
        onChanged: onChanged,
        controller: controller,
      ),
    );
  }
}
