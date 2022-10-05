import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/service/active_tab_service.dart';
import 'package:studio/src/ui/tabs/devtools_tab.dart';
import 'package:studio/src/util/tabs_extension.dart';

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
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyC,
                    meta: true,
                  ),
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
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyV,
                    meta: true,
                  ),
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
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyA,
                    meta: true,
                  ),
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
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyW,
                    meta: true,
                  ),
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
              label: 'DevTools',
              shortcut: const SingleActivator(LogicalKeyboardKey.f12),
              onSelected: () => ref.openTab(DevToolsTab()),
            ),
          ],
        ),
      ],
      child: widget.child,
    );
  }
}
