import 'package:pty/pty.dart';
import 'package:xterm/xterm.dart';

class PtyTerminalBackend implements TerminalBackend {
  final PseudoTerminal pty;

  PtyTerminalBackend(this.pty);

  @override
  void init() {
    pty.init();
  }

  @override
  Future<int> get exitCode => pty.exitCode;

  @override
  Stream<String> get out => pty.out;

  @override
  void resize(int width, int height) {
    pty.resize(width, height);
  }

  @override
  void write(String input) {
    pty.write(input);
  }

  @override
  void terminate() {
    pty.kill();
  }
}
