import 'dart:typed_data';

import 'package:studio/src/core/fs.dart';

abstract class Host {
  Future<FileSystem> connectFileSystem();

  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  });

  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  });
}

/// Result of command execution.
abstract class ExecutionResult {
  /// Exit code of the command.
  int get exitCode;

  /// Standard output of the command.
  String get stdout;

  /// Standard error of the command.
  String get stderr;
}

abstract class ExecutionSession {
  Future<void> write(Uint8List data);

  Future<void> resize(int width, int height);

  Future<void> close();

  Stream<Uint8List> get output;

  Future<int> get exitCode;
}
