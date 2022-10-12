import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:path/path.dart' as p;
import 'package:studio/src/core/fs.dart';

class SSHFileSystem extends FileSystem {
  final SftpClient client;

  SSHFileSystem(this.client, String currentDirectory) {
    this.currentDirectory = directory(currentDirectory);
  }

  @override
  late final SSHDirectory currentDirectory;

  @override
  SSHDirectory directory(String path) {
    return SSHDirectory(this, path);
  }

  @override
  File file(String path) {
    return SSHFile(this, path);
  }

  @override
  Link link(String path) {
    return SSHLink(this, path);
  }

  @override
  Future<bool> identical(String path1, String path2) async {
    final absolute1 = await client.absolute(path1);
    final absolute2 = await client.absolute(path2);
    return absolute1 == absolute2;
  }

  @override
  final bool isWatchSupported = false;

  @override
  p.Context get path => p.Context(style: p.Style.posix);

  @override
  Future<FileStat> stat(String path) async {
    final stat = await client.stat(path);
    return SSHFileStat(stat);
  }

  @override
  Future<FileSystemEntityType> type(
    String path, {
    bool followLinks = true,
  }) async {
    final stat = await client.stat(path);
    return _toFileSystemEntityType(stat.type);
  }
}

FileSystemEntityType _toFileSystemEntityType(SftpFileType? type) {
  switch (type) {
    case SftpFileType.directory:
      return FileSystemEntityType.directory;
    case SftpFileType.regularFile:
    case SftpFileType.blockDevice:
    case SftpFileType.characterDevice:
    case SftpFileType.whiteout:
      return FileSystemEntityType.file;
    case SftpFileType.symbolicLink:
      return FileSystemEntityType.link;
    case SftpFileType.pipe:
      return FileSystemEntityType.pipe;
    case SftpFileType.socket:
      return FileSystemEntityType.socket;
    case SftpFileType.unknown:
    case null:
      return FileSystemEntityType.unknown;
  }
}

class SSHFileStat implements FileStat {
  final SftpFileAttrs stat;

  SSHFileStat(this.stat);

  @override
  DateTime get accessed =>
      DateTime.fromMillisecondsSinceEpoch((stat.accessTime ?? 0) * 1000);

  @override
  DateTime get changed => modified;

  @override
  DateTime get modified =>
      DateTime.fromMillisecondsSinceEpoch((stat.modifyTime ?? 0) * 1000);

  @override
  int get size => stat.size ?? 0;

  @override
  FileSystemEntityType get type => _toFileSystemEntityType(stat.type);
}

class SSHDirectory extends Directory {
  @override
  final SSHFileSystem fileSystem;

  @override
  final String path;

  @override
  final SSHFileStat? cachedStat;

  SSHDirectory(this.fileSystem, this.path, [this.cachedStat]);

  SftpClient get client => fileSystem.client;

  @override
  Future<SSHDirectory> get absolute async {
    final absolute = await fileSystem.client.absolute(path);
    return SSHDirectory(fileSystem, absolute);
  }

  @override
  Future<SSHDirectory> create({bool recursive = false}) async {
    await client.mkdir(path);
    return this;
  }

  @override
  Future<SSHDirectory> delete({bool recursive = false}) async {
    await client.rmdir(path);
    return this;
  }

  @override
  Future<bool> exists() async {
    try {
      final stat = await client.stat(path);
      return stat.type == SftpFileType.directory;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) async* {
    await for (final chunk in client.readdir(path)) {
      for (final file in chunk) {
        final path = fileSystem.path.join(this.path, file.filename);
        if (file.attr.isDirectory) {
          yield SSHDirectory(fileSystem, path, SSHFileStat(file.attr));
        } else if (file.attr.isSymbolicLink) {
          yield SSHLink(fileSystem, path, SSHFileStat(file.attr));
        } else {
          yield SSHFile(fileSystem, path, SSHFileStat(file.attr));
        }
      }
    }
  }

  @override
  Future<Directory> rename(String newPath) async {
    await client.rename(path, newPath);
    return SSHDirectory(fileSystem, newPath);
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    throw FileSystemException('Watch on SSHDirectory is not supported', path);
  }
}

class SSHFile extends File {
  @override
  final SSHFileSystem fileSystem;

  @override
  final String path;

  @override
  final SSHFileStat? cachedStat;

  SSHFile(this.fileSystem, this.path, [this.cachedStat]);

  SftpClient get client => fileSystem.client;

  @override
  Future<SSHFile> get absolute async {
    final absolute = await fileSystem.client.absolute(path);
    return SSHFile(fileSystem, absolute);
  }

  @override
  Future<SSHFile> create({bool recursive = false}) async {
    final file = await client.open(path, mode: SftpFileOpenMode.create);
    await file.close();
    return this;
  }

  @override
  Future<SSHFile> delete({bool recursive = false}) async {
    await client.remove(path);
    return this;
  }

  @override
  Future<bool> exists() async {
    try {
      final stat = await client.stat(path);
      return stat.type != SftpFileType.directory &&
          stat.type != SftpFileType.symbolicLink;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<SSHFile> rename(String newPath) async {
    await client.rename(path, newPath);
    return SSHFile(fileSystem, newPath);
  }

  @override
  Future<SSHFile> copy(String newPath) async {
    final file1 = await client.open(path);
    final file2 = await client.open(newPath, mode: SftpFileOpenMode.create);
    await file2.write(file1.read());
    return SSHFile(fileSystem, newPath);
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    throw FileSystemException('Watch on SSHFile is not supported', path);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final file = await client.open(path);
    final bytes = await file.readBytes();
    await file.close();
    return bytes;
  }

  @override
  Future<String> readAsString() async {
    final bytes = await readAsBytes();
    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  Future<SSHFile> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    final file = await client.open(path, mode: _toSftpFileMode(mode));
    await file.writeBytes(bytes);
    await file.close();
    return this;
  }

  @override
  Future<SSHFile> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    final encoded = const Utf8Encoder().convert(contents);
    return await writeAsBytes(encoded, mode: mode, flush: flush);
  }

  static SftpFileOpenMode _toSftpFileMode(FileMode mode) {
    switch (mode) {
      case FileMode.append:
        return SftpFileOpenMode.append;
      case FileMode.write:
        return SftpFileOpenMode.write | SftpFileOpenMode.read;
      case FileMode.writeOnly:
        return SftpFileOpenMode.write;
      case FileMode.writeOnlyAppend:
        return SftpFileOpenMode.write | SftpFileOpenMode.append;
      case FileMode.read:
        return SftpFileOpenMode.read;
    }
  }
}

class SSHLink extends Link {
  @override
  final SSHFileSystem fileSystem;

  @override
  final String path;

  @override
  final SSHFileStat? cachedStat;

  SSHLink(this.fileSystem, this.path, [this.cachedStat]);

  SftpClient get client => fileSystem.client;

  @override
  Future<SSHLink> get absolute async {
    final absolute = await fileSystem.client.absolute(path);
    return SSHLink(fileSystem, absolute);
  }

  @override
  Future<SSHLink> create(String target, {bool recursive = false}) async {
    await client.link(path, target);
    return this;
  }

  @override
  Future<SSHLink> rename(String newPath) async {
    await client.rename(path, newPath);
    return SSHLink(fileSystem, newPath);
  }

  @override
  Future<Link> update(String target) async {
    await client.link(path, target);
    return this;
  }

  @override
  Future<SSHLink> delete({bool recursive = false}) async {
    await client.remove(path);
    return this;
  }

  @override
  Future<bool> exists() async {
    try {
      final stat = await client.stat(path);
      return stat.type == SftpFileType.symbolicLink;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> target() async {
    return await client.readlink(path);
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    throw FileSystemException('Watch on SSHLink is not supported', path);
  }
}
