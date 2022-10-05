import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/fs.dart';
import 'package:studio/src/core/plugin.dart';
import 'package:studio/src/core/service/tabs_service.dart';
import 'package:studio/src/plugins/file_manager/navigation_breadcrumbs.dart';
import 'package:studio/src/plugins/file_manager/navigation_stack.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FileManagerPlugin with Plugin {
  late FileSystem fs;

  final files = ValueNotifier(<FileSystemEntity>[]);

  final currentPath = ValueNotifier<String?>(null);

  late final navigationStack = NavigationStack<String>(onNavigate: _onNavigate);

  final _filesCache = <String, List<FileSystemEntity>>{};

  Future<void> _fetchFiles() async {
    final path = currentPath.value;

    if (path == null) {
      return;
    }

    this.files.value = _filesCache[path] ?? [];

    final files = await fs.directory(path).list().fold(
      <FileSystemEntity>[],
      (files, file) => [...files, file],
    );

    _filesCache[path] = files;

    if (currentPath.value == path) {
      this.files.value = files;
    }
  }

  Future<void> _onNavigate(String path) async {
    currentPath.value = path;
    _fetchFiles();
  }

  Future<void> goto(Directory target) async {
    late final String path;

    if (fs.path.isAbsolute(target.path)) {
      path = target.path;
    } else {
      path = fs.path.join(currentPath.value!, target.path);
    }

    navigationStack.push(path);
  }

  List<String> get breadcrumbs {
    final path = currentPath.value;
    if (path == null) {
      return [];
    }

    final parts = fs.path.split(path);
    return parts;
  }

  @override
  void didMounted() {
    title.value = Text('Files (${hostSpec.name})');
  }

  @override
  void didConnected() async {
    fs = await host.connectFileSystem();

    goto(await fs.directory('.').absolute);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          SizedBox(height: 40, child: FileNavigationView(this)),
          Expanded(child: FileListView(this))
        ],
      ),
    );
  }
}

class FileNavigationView extends StatelessWidget {
  const FileNavigationView(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  NavigationStack<String> get stack => plugin.navigationStack;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: stack,
      builder: (context, _) {
        return _buildToolbar(context);
      },
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return NavigationToolbar(
      leading: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: stack.canGoBack ? stack.back : null,
            iconSize: 16,
            color: CupertinoColors.label,
            disabledColor: CupertinoColors.inactiveGray,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.forward),
            onPressed: stack.canGoForward ? stack.forward : null,
            iconSize: 16,
            color: CupertinoColors.label,
            disabledColor: CupertinoColors.inactiveGray,
          ),
          const SizedBox(width: 8),
          // Text(plugin.currentPath.value ?? ''),
          Expanded(child: _buildPath(context)),
        ],
      ),
    );
  }

  Widget _buildPath(BuildContext context) {
    return NavigationBreadcrumbs(
      breadcrumbs: plugin.breadcrumbs,
      onTap: (breadcrumbs) {
        plugin.goto(plugin.fs.directory(plugin.fs.path.joinAll(breadcrumbs)));
      },
    );
  }
}

class FileListView extends ConsumerStatefulWidget {
  const FileListView(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  @override
  FileListViewState createState() => FileListViewState();
}

class FileListViewState extends ConsumerState<FileListView> {
  FileManagerPlugin get plugin => widget.plugin;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: plugin.files,
      builder: (context, files, child) {
        return _buildTable(context, files);
      },
    );
  }

  Widget _buildTable(BuildContext context, List<FileSystemEntity> files) {
    final source = _FilesDataSource(files);
    return SfDataGrid(
      headerRowHeight: 40,
      allowSorting: true,
      allowFiltering: true,
      horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
      onCellTap: (details) {
        final rowIndex = details.rowColumnIndex.rowIndex;

        if (rowIndex == 0) return;

        final row = source.effectiveRows[rowIndex - 1] as _FileDataGridRow;

        final file = row.file;

        if (file is Directory) {
          plugin.goto(file);
        } else if (file is File) {
          ref.read(tabsServiceProvider).openFile(file);
        }
      },
      columns: [
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8),
            child: const Text('Name'),
          ),
          columnWidthMode: ColumnWidthMode.fill,
          allowFiltering: true,
        ),
        GridColumn(
          columnName: 'date',
          label: Container(
            padding: const EdgeInsets.all(8),
            child: const Text('Date'),
          ),
          minimumWidth: 210,
          allowFiltering: false,
        ),
      ],
      source: source,
    );
  }
}

class _FilesDataSource extends DataGridSource {
  _FilesDataSource(this.files);

  final List<FileSystemEntity> files;

  @override
  late final rows = files
      .where((file) => file.basename != '.' && file.basename != '..')
      .map((file) => _FileDataGridRow(file))
      .toList();

  @override
  DataGridRowAdapter buildRow(covariant _FileDataGridRow row) {
    return DataGridRowAdapter(
      cells: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Icon(
              row.file is Directory
                  ? CupertinoIcons.folder
                  : CupertinoIcons.doc,
              size: 16,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(row.name),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(row.date),
        ),
      ],
    );
  }
}

class _FileDataGridRow implements DataGridRow {
  _FileDataGridRow(this.file);

  final FileSystemEntity file;

  late final name = file.basename;

  late final date = '${file.cachedStat?.modified ?? ''}';

  @override
  List<DataGridCell> getCells() {
    return [
      DataGridCell<String>(columnName: 'name', value: name),
      DataGridCell<String>(columnName: 'date', value: date),
    ];
  }
}
