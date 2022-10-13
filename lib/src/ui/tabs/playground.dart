import 'package:flex_tabs/flex_tabs.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PlaygroundTab extends TabItem {
  PlaygroundTab() {
    title.value = const Text('Playground');
    content.value = const PlaygroundView();
  }
}

class PlaygroundView extends StatefulWidget {
  const PlaygroundView({super.key});

  @override
  State<PlaygroundView> createState() => _PlaygroundViewState();
}

class _PlaygroundViewState extends State<PlaygroundView> {
  var topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        SizedBox(
          width: 300,
          height: 300,
          child: Text('Hello'),
        ),
        Acrylic(),
      ],
    );
  }
}
