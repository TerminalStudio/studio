import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/core/fs.dart';
import 'package:studio/src/core/plugin.dart';
import 'package:studio/src/core/service/tabs_service.dart';
import 'package:studio/src/plugins/file_manager/navigation_breadcrumbs.dart';
import 'package:studio/src/plugins/file_manager/navigation_stack.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FileManagerPlugin with Plugin {
  late FileSystem fs;

  String? homePath;

  final currentPath = ValueNotifier<String?>(null);

  String? get currentDirectory =>
      currentPath.value == null ? null : fs.path.basename(currentPath.value!);

  final files = ValueNotifier(<FileSystemEntity>[]);

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
    currentPath.value = fs.path.normalize(path);
    title.value = currentDirectory;
    _fetchFiles();
  }

  Future<void> goto(String target) async {
    late final String path;

    if (fs.path.isAbsolute(target)) {
      path = target;
    } else {
      path = fs.path.normalize(fs.path.join(currentPath.value!, target));
    }

    navigationStack.push(path);
  }

  List<String> get breadcrumbs {
    final path = currentPath.value;
    if (path == null) return [];
    final parts = fs.path.split(path);
    return parts;
  }

  bool get canGoUp => breadcrumbs.length > 1;

  Future<void> goUp() async {
    if (!canGoUp) return;
    await goto('..');
  }

  Future<void> goHome() async {
    if (homePath == null) return;
    await goto(homePath!);
  }

  @override
  void didMounted() {
    title.value = 'Files';
  }

  @override
  void didConnected() async {
    fs = await host.connectFileSystem();

    homePath = (await fs.directory('.').absolute).path;

    goto(homePath!);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40, child: FileListToolbar(this)),
          Expanded(child: FileListView(this)),
          const Divider(),
          SizedBox(height: 30, child: FileListNavigator(this)),
        ],
      ),
    );
  }
}

class FileListToolbar extends StatelessWidget {
  const FileListToolbar(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  NavigationStack<String> get stack => plugin.navigationStack;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: plugin.currentPath,
      builder: (context, currentPath, _) => _buildToolbar(context),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: stack.canGoBack ? stack.back : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(FluentIcons.forward),
            onPressed: stack.canGoForward ? stack.forward : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(FluentIcons.up),
            onPressed: plugin.canGoUp ? plugin.goUp : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(FluentIcons.home),
            onPressed: plugin.homePath == null ? null : plugin.goHome,
          ),
          const SizedBox(width: 16),
          const Divider(direction: Axis.vertical),
          const SizedBox(width: 16),
          Expanded(child: Text(plugin.currentDirectory ?? '')),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(FluentIcons.refresh),
            onPressed: () => plugin._fetchFiles(),
          ),
        ],
      ),
    );
  }
}

class FileListNavigator extends StatelessWidget {
  const FileListNavigator(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  NavigationStack<String> get stack => plugin.navigationStack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder(
        valueListenable: plugin.currentPath,
        builder: (context, currentPath, _) {
          return NavigationBreadcrumbs(
            breadcrumbs: plugin.breadcrumbs,
            onTap: (breadcrumbs) {
              plugin.goto(plugin.fs.path.joinAll(breadcrumbs));
            },
          );
        },
      ),
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
          plugin.goto(file.path);
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
                  ? FluentIcons.folder
                  : FluentIcons.file_code,
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
