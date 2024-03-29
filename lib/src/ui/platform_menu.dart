import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_studio/src/core/service/active_tab_service.dart';
import 'package:terminal_studio/src/ui/shortcuts.dart' as shortcuts;
import 'package:terminal_studio/src/ui/tabs/devtools_tab.dart';
import 'package:terminal_studio/src/ui/tabs/settings_tab/settings_tab.dart';
import 'package:terminal_studio/src/util/tabs_extension.dart';

class GlobalPlatformMenu extends ConsumerStatefulWidget {
  const GlobalPlatformMenu({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GlobalPlatformMenu> createState() => _GlobalPlatformMenuState();
}

class _GlobalPlatformMenuState extends ConsumerState<GlobalPlatformMenu> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: <MenuItem>[
        PlatformMenu(
          label: 'TerminalStudio',
          menus: [
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.about))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.about,
              ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.servicesSubmenu))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.servicesSubmenu,
                  ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.hide))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hide,
                  ),
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.hideOtherApplications))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hideOtherApplications,
                  ),
              ],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.quit))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
          ],
        ),
        PlatformMenu(
          label: 'Edit',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Copy',
                  shortcut: shortcuts.terminalCopy,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    Actions.invoke(
                      primaryContext,
                      CopySelectionTextIntent.copy,
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Paste',
                  shortcut: shortcuts.terminalPaste,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    Actions.invoke(
                      primaryContext,
                      const PasteTextIntent(SelectionChangedCause.keyboard),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Select All',
                  shortcut: shortcuts.terminalSelectAll,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    try {
                      Actions.maybeFind<Intent>(
                        primaryContext,
                        intent: const SelectAllTextIntent(
                            SelectionChangedCause.keyboard),
                      );
                    } catch (e, st) {
                      print(e);
                      print(st);
                    }
                    Actions.invoke<Intent>(
                      primaryContext,
                      const SelectAllTextIntent(SelectionChangedCause.keyboard),
                    );
                  },
                ),
              ],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.quit))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Close Tab',
                  shortcut: shortcuts.tabClose,
                  onSelected: () {
                    return ref
                        .read(activeTabServiceProvider)
                        .getActiveTab()
                        ?.detach();
                  },
                ),
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.toggleFullScreen))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.toggleFullScreen),
              ],
            ),
            PlatformMenuItem(
              label: 'Settings',
              shortcut: shortcuts.openSettings,
              onSelected: () => ref.openTab(SettingsTab()),
            ),
            PlatformMenuItem(
              label: 'DevTools',
              shortcut: shortcuts.openDevTools,
              onSelected: () => ref.openTab(DevToolsTab()),
            ),
          ],
        ),
      ],
      child: widget.child,
    );
  }
}
