import 'package:fluent_ui/fluent_ui.dart';

class FluentBackButton extends StatelessWidget {
  const FluentBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PaneItem(
      icon: const Icon(FluentIcons.back, size: 14.0),
      body: const SizedBox.shrink(),
    ).build(
      context,
      false,
      () => _onPressed(context),
      displayMode: PaneDisplayMode.compact,
    );
  }

  void _onPressed(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }
}
