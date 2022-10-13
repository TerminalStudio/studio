import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/service/window_service.dart';
import 'package:studio/src/ui/shortcut/intents.dart';

class GlobalActions extends ConsumerWidget {
  const GlobalActions({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Actions(
      actions: {
        NewWindowIntent: CallbackAction<NewWindowIntent>(
          onInvoke: (NewWindowIntent intent) async {
            await ref.read(windowServiceProvider).createWindow();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
