import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/state/tabs.dart';

class ActiveTabService {
  final Ref ref;

  ActiveTabService(this.ref);

  Tabs? getActiveTabGroup() {
    return getActiveTab()?.parent;
  }

  TabItem? getActiveTab() {
    return ref.read(tabsProvider).activeTab.value;
  }
}

final activeTabServiceProvider = Provider<ActiveTabService>(
  name: 'activeTabServiceProvider',
  (ref) => ActiveTabService(ref),
);
