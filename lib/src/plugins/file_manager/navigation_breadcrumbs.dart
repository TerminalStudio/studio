import 'package:fluent_ui/fluent_ui.dart';

class NavigationBreadcrumbs extends StatelessWidget {
  const NavigationBreadcrumbs({
    super.key,
    required this.breadcrumbs,
    this.onTap,
  });

  final List<String> breadcrumbs;

  final void Function(List<String> breadcrumbs)? onTap;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < breadcrumbs.length; i++) {
      final breadcrumb = breadcrumbs[i];

      widgets.add(
        BreadcrumbButton(
          breadcrumb: breadcrumb,
          onPressed: () => onTap?.call(breadcrumbs.sublist(0, i + 1)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: widgets,
        ),
      ),
    );
  }
}

class BreadcrumbButton extends StatelessWidget {
  const BreadcrumbButton({
    super.key,
    this.onPressed,
    required this.breadcrumb,
    this.isPrimary = false,
  });

  final String breadcrumb;

  final bool isPrimary;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(breadcrumb),
    );
  }
}

class BreadcrumbSeprator extends StatelessWidget {
  const BreadcrumbSeprator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      FluentIcons.chevron_right,
      size: 8,
      // color: CupertinoColors.secondaryLabel,
    );
  }
}
