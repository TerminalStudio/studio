import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studio/src/core/model/ssh_host_record.dart';
import 'package:studio/src/core/model/ssh_key_record.dart';

final hiveProvider = FutureProvider<HiveInterface>((ref) async {
  await Hive.initFlutter();
  return Hive;
});

// typeId: 0
final sshHostBoxProvider = FutureProvider<Box<SSHHostRecord>>((ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerAdapter(SSHHostRecordAdapter());
  return hive.openBox<SSHHostRecord>('ssh_hosts');
});

// typeId: 1
final sshKeyBoxProvider = FutureProvider<Box<SSHKeyRecord>>((ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerAdapter(SSHKeyRecordAdapter());
  return hive.openBox<SSHKeyRecord>('ssh_keys');
});
