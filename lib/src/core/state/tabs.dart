import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabsProvider = Provider<TabsDocument>((ref) {
  return TabsDocument();
});
