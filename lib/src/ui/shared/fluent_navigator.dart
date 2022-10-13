import 'package:fluent_ui/fluent_ui.dart';

class FluentNavigatorCommandBar extends StatelessWidget {
  const FluentNavigatorCommandBar({super.key, required this.primaryItems});

  final List<CommandBarItem> primaryItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: CommandBar(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        primaryItems: primaryItems,
      ),
    );
  }
}
