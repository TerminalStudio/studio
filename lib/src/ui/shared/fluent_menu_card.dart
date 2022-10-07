import 'package:fluent_ui/fluent_ui.dart';

class FluentMenuCard extends StatelessWidget {
  const FluentMenuCard({
    Key? key,
    required this.children,
    this.borderRadius,
    this.bgColor,
    this.border,
    this.shadows,
    this.padding,
  }) : super(key: key);

  final List<Widget> children;
  final Border? border;
  final BorderRadius? borderRadius;
  final Color? bgColor;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final shadowColor = FluentTheme.of(context).shadowColor;
    final radius = borderRadius ?? BorderRadius.circular(4);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: bgColor ?? FluentTheme.of(context).menuColor,
            border: border ?? Border.all(color: Colors.grey[100]),
            borderRadius: radius,
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: shadowColor.withOpacity(.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                  BoxShadow(
                    color: shadowColor.withOpacity(.02),
                    blurRadius: 2,
                    offset: const Offset(2, 2),
                  ),
                ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
