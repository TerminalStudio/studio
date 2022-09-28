import 'package:flutter/widgets.dart';
import 'package:studio/src/core/host.dart';

abstract class Plugin {
  Host? _host;

  Host get host {
    assert(isActive, 'Plugin is not activated');
    return _host!;
  }

  bool _isActive = false;

  bool get isActive => _isActive;

  final title = ValueNotifier<String>('');

  void setTitle(String title) {
    assert(isActive, 'Plugin is not activated');
    this.title.value = title;
  }

  void mount(Host host) {
    assert(!_isActive, 'Plugin is already activated');
    _host = host;
    _isActive = true;
    activate();
  }

  void unmount() {
    assert(_isActive, 'Plugin is not activated');
    _host = null;
    _isActive = false;
    deactivate();
  }

  void activate() {}

  void deactivate() {}

  Widget build(BuildContext context);
}
