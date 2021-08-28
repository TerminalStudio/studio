import 'package:flutter/cupertino.dart';
import 'package:xterm/terminal/terminal_ui_interaction.dart';
import 'package:xterm/terminal/terminal_search.dart';

class TerminalSearchBar extends StatefulWidget {
  const TerminalSearchBar({
    Key? key,
    required this.terminal,
    required this.searchTextController,
    required this.focusNode,
    this.itemSize = 20,
  }) : super(key: key);

  final TerminalUiInteraction terminal;
  final int itemSize;
  final TextEditingController searchTextController;
  final FocusNode focusNode;

  @override
  _TerminalSearchBarState createState() {
    return _TerminalSearchBarState();
  }
}

class _TerminalSearchBarState extends State<TerminalSearchBar> {
  int _currentSearchHit = 0;
  int _numberOfSearchHits = 0;
  TerminalSearchOptions _options = TerminalSearchOptions();
  String _searchText = '';

  void _onTerminalChanges() {
    if (widget.terminal.currentSearchHit != _currentSearchHit ||
        widget.terminal.numberOfSearchHits != _numberOfSearchHits ||
        widget.terminal.userSearchOptions != _options) {
      setState(() {
        _currentSearchHit = widget.terminal.currentSearchHit;
        _numberOfSearchHits = widget.terminal.numberOfSearchHits;
        _options = widget.terminal.userSearchOptions;
      });
    }
  }

  void _onSearchTextChanges() {
    if (_searchText != widget.searchTextController.text) {
      setState(() {
        _searchText = widget.searchTextController.text;
      });
    }
  }

  @override
  void initState() {
    widget.terminal.addListener(_onTerminalChanges);
    widget.searchTextController.addListener(_onSearchTextChanges);
    _searchText = widget.searchTextController.text;
    _currentSearchHit = widget.terminal.currentSearchHit;
    _numberOfSearchHits = widget.terminal.numberOfSearchHits;
    _options = widget.terminal.userSearchOptions;
    super.initState();
  }

  @override
  void dispose() {
    widget.terminal.removeListener(_onTerminalChanges);
    widget.searchTextController.removeListener(_onSearchTextChanges);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = CupertinoColors.label;
    final itemColor = CupertinoColors.secondaryLabel;
    final itemColorSuffixActive = CupertinoColors.label;
    final itemColorSuffixInactive = CupertinoColors.tertiaryLabel;
    const searchBackgroundColor = CupertinoColors.secondarySystemBackground;
    final resolvedSearchBackgroundColor =
        CupertinoDynamicColor.resolve(searchBackgroundColor, context);
    const placeholderColor = CupertinoColors.systemGrey;
    final resolvedPlaceholderColor =
        CupertinoDynamicColor.resolve(placeholderColor, context);

    final double scaledIconSize =
        MediaQuery.textScaleFactorOf(context) * widget.itemSize;
    final IconThemeData iconThemeData = IconThemeData(
      color: CupertinoDynamicColor.resolve(itemColor, context),
      size: scaledIconSize,
    );
    final IconThemeData iconThemeDataSuffixActive = IconThemeData(
      color: CupertinoDynamicColor.resolve(itemColorSuffixActive, context),
      size: scaledIconSize,
    );
    final IconThemeData iconThemeDataSuffixInactive = IconThemeData(
      color: CupertinoDynamicColor.resolve(itemColorSuffixInactive, context),
      size: scaledIconSize,
    );
    const suffixPadding = EdgeInsets.fromLTRB(0, 0, 5, 0);

    final isUpEnabled = _currentSearchHit > 1;
    final isDownEnabled = _currentSearchHit < _numberOfSearchHits;
    final isClearEnabled = widget.searchTextController.text != '';

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: widget.searchTextController,
                  placeholder: "Search",
                  placeholderStyle: TextStyle(color: resolvedPlaceholderColor),
                  style: TextStyle(color: textColor),
                  prefix: IconTheme(
                    data: iconThemeData,
                    child: const Icon(CupertinoIcons.search),
                  ),
                  suffix: Row(
                    children: [
                      Text("$_currentSearchHit/$_numberOfSearchHits"),
                      _TerminalSearchBarSuffixIcon(
                        padding: suffixPadding,
                        enabled: isUpEnabled,
                        active: isUpEnabled,
                        onPressed: () {
                          widget.terminal.currentSearchHit =
                              widget.terminal.currentSearchHit - 1;

                          widget.focusNode.requestFocus();
                        },
                        icon: CupertinoIcons.arrow_up,
                        themeActive: iconThemeDataSuffixActive,
                        themeInactive: iconThemeDataSuffixInactive,
                      ),
                      _TerminalSearchBarSuffixIcon(
                        padding: suffixPadding,
                        enabled: isDownEnabled,
                        active: isDownEnabled,
                        onPressed: () {
                          widget.terminal.currentSearchHit =
                              widget.terminal.currentSearchHit + 1;

                          widget.focusNode.requestFocus();
                        },
                        icon: CupertinoIcons.arrow_down,
                        themeActive: iconThemeDataSuffixActive,
                        themeInactive: iconThemeDataSuffixInactive,
                      ),
                      _TerminalSearchBarSuffixIcon(
                        padding: suffixPadding,
                        enabled: true,
                        active: _options.caseSensitive,
                        onPressed: () {
                          widget.terminal.userSearchOptions =
                              widget.terminal.userSearchOptions.copyWith(
                                  caseSensitive: !widget.terminal
                                      .userSearchOptions.caseSensitive);
                          widget.focusNode.requestFocus();
                        },
                        icon: CupertinoIcons.textformat_size,
                        themeActive: iconThemeDataSuffixActive,
                        themeInactive: iconThemeDataSuffixInactive,
                      ),
                      _TerminalSearchBarSuffixIcon(
                        padding: suffixPadding,
                        enabled: true,
                        active: _options.matchWholeWord,
                        onPressed: () {
                          widget.terminal.userSearchOptions =
                              widget.terminal.userSearchOptions.copyWith(
                                  matchWholeWord: !widget.terminal
                                      .userSearchOptions.matchWholeWord);
                          widget.focusNode.requestFocus();
                        },
                        icon: CupertinoIcons.textbox,
                        themeActive: iconThemeDataSuffixActive,
                        themeInactive: iconThemeDataSuffixInactive,
                      ),
                      _TerminalSearchBarSuffixIcon(
                        padding: suffixPadding,
                        enabled: isClearEnabled,
                        active: isClearEnabled,
                        onPressed: () {
                          widget.searchTextController.text = '';
                          widget.focusNode.requestFocus();
                        },
                        icon: CupertinoIcons.xmark_circle_fill,
                        themeActive: iconThemeDataSuffixActive,
                        themeInactive: iconThemeDataSuffixInactive,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: resolvedSearchBackgroundColor,
                      borderRadius: BorderRadius.circular(9)),
                  autocorrect: false,
                  focusNode: widget.focusNode,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

typedef OnPressedHandler = void Function();

class _TerminalSearchBarSuffixIcon extends StatelessWidget {
  const _TerminalSearchBarSuffixIcon({
    Key? key,
    required this.padding,
    this.onPressed,
    required this.enabled,
    required this.active,
    required this.themeActive,
    required this.themeInactive,
    required this.icon,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final OnPressedHandler? onPressed;
  final bool enabled;
  final bool active;
  final IconThemeData themeActive;
  final IconThemeData themeInactive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CupertinoButton(
        onPressed: enabled ? onPressed : null,
        minSize: 0,
        padding: EdgeInsets.zero,
        child: IconTheme(
          data: active ? themeActive : themeInactive,
          child: Icon(icon),
        ),
      ),
    );
  }
}
