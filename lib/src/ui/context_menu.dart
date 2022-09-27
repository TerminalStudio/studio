import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

class DropdownContextMenu extends StatefulWidget {
  const DropdownContextMenu({super.key});

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends State<DropdownContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Local",
            icon: const Icon(Icons.computer_outlined),
            onPressed: () {},
          ),
        ),
        buildDivider(),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Add New",
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
