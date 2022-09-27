import 'dart:io' as io;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:studio/src/core/fs.dart';

class LocalFileSystem extends FileSystem {
  @override
  Directory get currentDirectory {
    return LocalDirectory(this, io.Directory.current);
  }

  @override
  Directory directory(String path) {
    return LocalDirectory(this, io.Directory(path));
  }

  @override
  File file(String path) {
    return LocalFile(this, io.File(path));
  }

  @override
  Future<bool> identical(String path1, String path2) {
    return io.FileSystemEntity.identical(path1, path2);
  }

  @override
  bool get isWatchSupported => io.FileSystemEntity.isWatchSupported;

  @override
  Link link(String path) {
    return LocalLink(this, io.Link(path));
  }

  @override
  p.Context get path => p.Context();

  @override
  Future<FileStat> stat(String path) async {
    final stat = await io.FileStat.stat(path);
    return LocalFileStat(stat);
  }

  @override
  Future<FileSystemEntityType> type(
    String path, {
    bool followLinks = true,
  }) async {
    final type = await io.FileSystemEntity.type(path, followLinks: followLinks);

    if (type == io.FileSystemEntityType.notFound) {
      throw FileSystemException('Not found', path);
    }

    switch (type) {
      case io.FileSystemEntityType.directory:
        return FileSystemEntityType.directory;
      case io.FileSystemEntityType.file:
        return FileSystemEntityType.file;
      case io.FileSystemEntityType.link:
        return FileSystemEntityType.link;
      default:
        return FileSystemEntityType.unknown;
    }
  }
}

class LocalFileStat implements FileStat {
  final io.FileStat _stat;

  LocalFileStat(this._stat);

  @override
  int get size => _stat.size;

  @override
  DateTime get accessed => _stat.accessed;

  @override
  DateTime get changed => _stat.changed;

  @override
  DateTime get modified => _stat.modified;

  @override
  FileSystemEntityType get type {
    switch (_stat.type) {
      case io.FileSystemEntityType.directory:
        return FileSystemEntityType.directory;
      case io.FileSystemEntityType.file:
        return FileSystemEntityType.file;
      case io.FileSystemEntityType.link:
        return FileSystemEntityType.link;
      default:
        return FileSystemEntityType.unknown;
    }
  }
}

mixin LocalFileSystemEntity {
  io.FileSystemEntity get delegate;

  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    return delegate.watch(events: events, recursive: recursive).map((event) {
      if (event is io.FileSystemCreateEvent) {
        return FileSystemEvent(FileSystemEvent.create, event.path, true);
      } else if (event is io.FileSystemModifyEvent) {
        return FileSystemEvent(FileSystemEvent.modify, event.path, true);
      } else if (event is io.FileSystemDeleteEvent) {
        return FileSystemEvent(FileSystemEvent.delete, event.path, true);
      } else if (event is io.FileSystemMoveEvent) {
        return FileSystemEvent(FileSystemEvent.move, event.path, true);
      } else {
        throw StateError('Unknown event type: $event');
      }
    });
  }

  Future<bool> exists() async {
    return await delegate.exists();
  }
}

class LocalDirectory extends Directory with LocalFileSystemEntity {
  @override
  final FileSystem fileSystem;

  @override
  final io.Directory delegate;

  LocalDirectory(this.fileSystem, this.delegate);

  @override
  String get path => delegate.path;

  @override
  Future<LocalDirectory> get absolute async =>
      LocalDirectory(fileSystem, delegate.absolute);

  @override
  Future<LocalDirectory> create({bool recursive = false}) async {
    final newDelegate = await delegate.create(recursive: recursive);
    return LocalDirectory(fileSystem, newDelegate);
  }

  @override
  Future<LocalDirectory> delete({bool recursive = false}) async {
    final newDelegate = await delegate.delete(recursive: recursive);
    return LocalDirectory(fileSystem, newDelegate as io.Directory);
  }

  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    return delegate
        .list(
      recursive: recursive,
      followLinks: followLinks,
    )
        .map((entity) {
      if (entity is io.File) {
        return LocalFile(fileSystem, entity);
      } else if (entity is io.Directory) {
        return LocalDirectory(fileSystem, entity);
      } else if (entity is io.Link) {
        return LocalLink(fileSystem, entity);
      } else {
        throw StateError('Unknown entity type: $entity');
      }
    });
  }

  @override
  Future<LocalDirectory> rename(String newPath) async {
    final newDelegate = await delegate.rename(newPath);
    return LocalDirectory(fileSystem, newDelegate);
  }
}

class LocalFile extends File with LocalFileSystemEntity {
  @override
  final FileSystem fileSystem;

  @override
  final io.File delegate;

  LocalFile(this.fileSystem, this.delegate);

  @override
  String get path => delegate.path;

  @override
  Future<LocalFile> get absolute async =>
      LocalFile(fileSystem, delegate.absolute);

  @override
  Future<LocalFile> create({bool recursive = false}) async {
    final newDelegate = await delegate.create(recursive: recursive);
    return LocalFile(fileSystem, newDelegate);
  }

  @override
  Future<LocalFile> delete({bool recursive = false}) async {
    final newDelegate = await delegate.delete(recursive: recursive);
    return LocalFile(fileSystem, newDelegate as io.File);
  }

  @override
  Future<FileStat> stat() async {
    final stat = await delegate.stat();
    return LocalFileStat(stat);
  }

  @override
  Future<LocalFile> rename(String newPath) async {
    final newDelegate = await delegate.rename(newPath);
    return LocalFile(fileSystem, newDelegate);
  }

  @override
  Future<LocalFile> copy(String newPath) async {
    final newDelegate = await delegate.copy(newPath);
    return LocalFile(fileSystem, newDelegate);
  }

  @override
  Future<LocalFile> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    final newDelegate = await delegate.writeAsBytes(
      bytes,
      mode: _toIoFileMode(mode),
      flush: flush,
    );
    return LocalFile(fileSystem, newDelegate);
  }

  @override
  Future<LocalFile> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    final newDelegate = await delegate.writeAsString(
      contents,
      mode: _toIoFileMode(mode),
      flush: flush,
    );
    return LocalFile(fileSystem, newDelegate);
  }

  io.FileMode _toIoFileMode(FileMode mode) {
    switch (mode) {
      case FileMode.append:
        return io.FileMode.append;
      case FileMode.write:
        return io.FileMode.write;
      case FileMode.writeOnly:
        return io.FileMode.writeOnly;
      case FileMode.writeOnlyAppend:
        return io.FileMode.writeOnlyAppend;
      case FileMode.read:
        return io.FileMode.read;
      default:
        throw StateError('Unknown file mode: $mode');
    }
  }
}

class LocalLink extends Link with LocalFileSystemEntity {
  @override
  final FileSystem fileSystem;

  @override
  final io.Link delegate;

  LocalLink(this.fileSystem, this.delegate);

  @override
  String get path => delegate.path;

  @override
  Future<LocalLink> get absolute async =>
      LocalLink(fileSystem, delegate.absolute);

  @override
  Future<LocalLink> create(String target, {bool recursive = false}) async {
    final newDelegate = await delegate.create(target, recursive: recursive);
    return LocalLink(fileSystem, newDelegate);
  }

  @override
  Future<LocalLink> delete({bool recursive = false}) async {
    final newDelegate = await delegate.delete(recursive: recursive);
    return LocalLink(fileSystem, newDelegate as io.Link);
  }

  @override
  Future<LocalLink> rename(String newPath) async {
    final newDelegate = await delegate.rename(newPath);
    return LocalLink(fileSystem, newDelegate);
  }

  @override
  Future<LocalLink> update(String target) async {
    final newDelegate = await delegate.update(target);
    return LocalLink(fileSystem, newDelegate);
  }

  @override
  Future<String> target() async {
    return await delegate.target();
  }
}
