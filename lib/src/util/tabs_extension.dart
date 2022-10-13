import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/state/tabs.dart';

extension RefTabsExtension on WidgetRef {
  void openTab(TabItem tab) {
    final document = read(tabsProvider);
    document.root?.add(tab);
    tab.activate();
  }
}

extension TabItemExtension on TabItem {
  void addToSide(TabItem item) {
    final parent = this.parent;

    if (parent == null) {
      return;
    }

    parent.insert(parent.indexOf(this) + 1, item);

    parent.activate(item);
  }
}
