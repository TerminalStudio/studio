import 'package:flutter/widgets.dart';
import 'package:studio/src/core/conn.dart';
import 'package:studio/src/core/host.dart';

abstract class Plugin {
  PluginManager? _manager;

  /// The plugin manager that manages the lifecycle of this plugin.
  PluginManager get manager {
    if (_manager == null) {
      throw StateError('Plugin is not attached to a manager');
    }

    return _manager!;
  }

  HostSpec? _hostSpec;

  /// The interface through which the plugin can read information about the host.
  /// This is available after [didMounted] is called.
  HostSpec get hostSpec {
    if (_hostSpec == null) {
      throw Exception('Plugin has not been mounted');
    }
    return _hostSpec!;
  }

  Host? _host;

  /// The interface through which the plugin can interact with the host. Access
  /// to this property will throw an exception if the host has not been connected.
  Host get host {
    if (_host == null) {
      throw Exception('Plugin has not been connected to a host.');
    }
    return _host!;
  }

  /// Whether the plugin is currently mounted.
  bool get mounted => _manager != null;

  /// Whether the plugin is connected to a host.
  bool get connected => _host != null;

  /// The title of the plugin. Usually displayed as the tab title.
  final title = ValueNotifier<String?>(null);

  /// Called when the plugin is mounted to a host. After this method is called,
  /// the [hostSpec] property will be available.
  void didMounted() {}

  /// Called when the plugin is unmounted from a host. After this method is
  /// called, the [hostSpec] property will no longer be available.
  void didUnmounted() {}

  /// Called when the host that this plugin is mounted to is connected. This
  /// method may be called multiple times if the host is disconnected and
  /// reconnected.
  void didConnected() {}

  /// Called when the host that this plugin is mounted to is disconnected. This
  /// method may be called multiple times if the host is disconnected and
  /// reconnected.
  void didDisconnected() {}

  /// Builds the UI for this plugin. This may be called multiple times during
  /// the lifetime of the plugin, for example when the plugin is moved to a new
  /// tab group.
  Widget build(BuildContext context);
}

class PluginManager with ChangeNotifier {
  final HostSpec hostSpec;

  PluginManager(this.hostSpec);

  final _plugins = <Plugin>[];

  List<Plugin> get plugins => List.unmodifiable(_plugins);

  Host? _host;

  void add(Plugin plugin) {
    if (plugin._manager != null) {
      throw Exception('Plugin is already mounted');
    }
    _plugins.add(plugin);

    plugin._manager = this;
    plugin._hostSpec = hostSpec;
    plugin.didMounted();

    if (_host != null) {
      plugin._host = _host;
      plugin.didConnected();
    }

    notifyListeners();
  }

  void remove(Plugin plugin) {
    if (plugin._manager != this) {
      throw Exception('Plugin is not mounted');
    }
    _plugins.remove(plugin);

    plugin.didUnmounted();
    plugin._manager = null;
    plugin._hostSpec = null;
    plugin._host = null;

    notifyListeners();
  }

  void didConnected(Host host) {
    if (_host != null) {
      throw Exception('plugin manager is already connected to $_host');
    }

    _host = host;

    for (final plugin in _plugins) {
      plugin._host = host;
      plugin.didConnected();
    }
  }

  void didDisconnected() {
    if (_host == null) {
      throw Exception('plugin manager is not connected');
    }

    _host = null;

    for (final plugin in _plugins) {
      plugin._host = null;
      plugin.didDisconnected();
    }
  }
}
