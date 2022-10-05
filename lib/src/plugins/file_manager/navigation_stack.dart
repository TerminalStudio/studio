import 'package:flutter/widgets.dart';

class NavigationStack<T> with ChangeNotifier {
  final void Function(T item)? onNavigate;

  NavigationStack({this.onNavigate});

  final List<T> _stack = [];

  /// Pointer to the current position in the stack. -1 if the stack is empty.
  var _current = -1;

  /// The current path in the stack.
  T? get current => _current >= 0 ? _stack[_current] : null;

  /// Weather calling [back] will have any effect.
  bool get canGoBack => _current > 0;

  /// Weather calling [forward] will have any effect.
  bool get canGoForward => _current < _stack.length - 1;

  /// Pushes a new path to the stack at the current position, clears the stack
  /// after the current position.
  void push(T path) {
    if (_current < _stack.length - 1) {
      _stack.removeRange(_current + 1, _stack.length);
    }

    _stack.add(path);
    _current = _stack.length - 1;

    onNavigate?.call(path);
    notifyListeners();
  }

  /// Navigates back in the stack.
  void back() {
    if (_current > 0) {
      _current--;

      onNavigate?.call(_stack[_current]);
      notifyListeners();
    }
  }

  /// Navigates forward in the stack.
  void forward() {
    if (_current < _stack.length - 1) {
      _current++;

      onNavigate?.call(_stack[_current]);
      notifyListeners();
    }
  }
}
