import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:terminal_studio/src/core/record/ssh_host_record.dart';
import 'package:terminal_studio/src/core/record/ssh_key_record.dart';

final hiveProvider = FutureProvider<HiveInterface>((ref) async {
  await Hive.initFlutter('.TerminalStudio');
  return Hive;
});

// typeId: 0
final sshHostBoxProvider = FutureProvider<Box<SSHHostRecord>>((ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerAdapter(SSHHostRecordAdapter());
  return hive.openBox<SSHHostRecord>('ssh_hosts');
});

final sshHostsProvider = FutureProvider<List<SSHHostRecord>>((ref) async {
  final box = await ref.watch(sshHostBoxProvider.future);
  box.watch().listen((event) => ref.invalidateSelf());
  return box.values.toList();
});

// typeId: 1
final sshKeyBoxProvider = FutureProvider<Box<SSHKeyRecord>>((ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerAdapter(SSHKeyRecordAdapter());
  return hive.openBox<SSHKeyRecord>('ssh_keys');
});
