import 'dart:typed_data';

import 'package:path/path.dart' as p;

enum FileSystemEntityType {
  /// The file system entity is a file.
  file,

  /// The file system entity is a directory.
  directory,

  /// The file system entity is a link.
  link,

  /// The file system entity is a socket.
  socket,

  /// The file system entity is a pipe.
  pipe,

  /// The file system entity is unknown.
  unknown,
}

/// A generic representation of a file system.
abstract class FileSystem {
  /// Creates a new `FileSystem`.
  const FileSystem();

  /// Returns a reference to a [Directory] at [path].
  Directory directory(String path);

  /// Returns a reference to a [File] at [path].
  File file(String path);

  /// Returns a reference to a [Link] at [path].
  Link link(String path);

  /// An object for manipulating paths in this file system.
  p.Context get path;

  /// Creates a directory object pointing to the current working directory.
  Directory get currentDirectory;

  /// Asynchronously calls the operating system's stat() function on [path].
  /// Returns a Future which completes with a [FileStat] object containing
  /// the data returned by stat().
  Future<FileStat> stat(String path);

  /// Checks whether two paths refer to the same object in the
  /// file system. Returns a [Future<bool>] that completes with the result.
  ///
  /// Comparing a link to its target returns false, as does comparing two links
  /// that point to the same target.  To check the target of a link, use
  /// Link.target explicitly to fetch it.  Directory links appearing
  /// inside a path are followed, though, to find the file system object.
  ///
  /// Completes the returned Future with an error if one of the paths points
  /// to an object that does not exist.
  Future<bool> identical(String path1, String path2);

  /// Tests if [FileSystemEntity.watch] is supported on the current system.
  bool get isWatchSupported;

  /// Finds the type of file system object that a [path] points to. Returns
  /// a Future<FileSystemEntityType> that completes with the result.
  ///
  /// [FileSystemEntityType.LINK] will only be returned if [followLinks] is
  /// `false`, and [path] points to a link
  ///
  /// If the [path] does not point to a file system object or an error occurs
  /// then [FileSystemEntityType.notFound] is returned.
  Future<FileSystemEntityType> type(String path, {bool followLinks = true});

  /// Checks if [`type(path)`](type) returns [FileSystemEntityType.FILE].
  Future<bool> isFile(String path) async =>
      await type(path) == FileSystemEntityType.file;

  /// Checks if [`type(path)`](type) returns [FileSystemEntityType.DIRECTORY].
  Future<bool> isDirectory(String path) async =>
      await type(path) == FileSystemEntityType.directory;

  /// Checks if [`type(path)`](type) returns [FileSystemEntityType.LINK].
  Future<bool> isLink(String path) async =>
      await type(path) == FileSystemEntityType.link;
}

/// The common super class for [File], [Directory], and [Link] objects.
abstract class FileSystemEntity {
  String get path;

  /// Returns the file system responsible for this entity.
  FileSystem get fileSystem;

  /// Gets the part of this entity's path after the last separator.
  ///
  ///     context.basename('path/to/foo.dart'); // -> 'foo.dart'
  ///     context.basename('path/to');          // -> 'to'
  ///
  /// Trailing separators are ignored.
  ///
  ///     context.basename('path/to/'); // -> 'to'
  String get basename => fileSystem.path.basename(path);

  /// Gets the part of this entity's path before the last separator.
  ///
  ///     context.dirname('path/to/foo.dart'); // -> 'path/to'
  ///     context.dirname('path/to');          // -> 'path'
  ///     context.dirname('foo.dart');         // -> '.'
  ///
  /// Trailing separators are ignored.
  ///
  ///     context.dirname('path/to/'); // -> 'path'
  String get dirname => fileSystem.path.dirname(path);

  /// The parent directory of this entity.
  Directory get parent => fileSystem.directory(dirname);

  /// Checks whether the file system entity with this path exists.
  ///
  /// Returns a `Future<bool>` that completes with the result.
  ///
  /// Since [FileSystemEntity] is abstract, every [FileSystemEntity] object
  /// is actually an instance of one of the subclasses [File],
  /// [Directory], and [Link]. Calling [exists] on an instance of one
  /// of these subclasses checks whether the object exists in the file
  /// system object exists *and* is of the correct type (file, directory,
  /// or link). To check whether a path points to an object on the
  /// file system, regardless of the object's type, use the [type]
  /// static method.
  Future<bool> exists();

  /// Renames this file system entity.
  ///
  /// Returns a `Future<FileSystemEntity>` that completes with a
  /// [FileSystemEntity] instance for the renamed file system entity.
  ///
  /// If [newPath] identifies an existing entity of the same type,
  /// that entity is removed first.
  /// If [newPath] identifies an existing entity of a different type,
  /// the operation fails and the future completes with an exception.
  Future<FileSystemEntity> rename(String newPath);

  /// Calls the operating system's `stat()` function on [path].
  ///
  /// Returns a `Future<FileStat>` object containing the data returned by
  /// `stat()`.
  ///
  /// If [path] is a symbolic link then it is resolved and results for the
  /// resulting file are returned.
  Future<FileStat> stat() => fileSystem.stat(path);

  /// Deletes this [FileSystemEntity].
  ///
  /// If the [FileSystemEntity] is a directory, and if [recursive] is `false`,
  /// the directory must be empty. Otherwise, if [recursive] is true, the
  /// directory and all sub-directories and files in the directories are
  /// deleted. Links are not followed when deleting recursively. Only the link
  /// is deleted, not its target.
  ///
  /// If [recursive] is true, the [FileSystemEntity] is deleted even if the type
  /// of the [FileSystemEntity] doesn't match the content of the file system.
  /// This behavior allows [delete] to be used to unconditionally delete any file
  /// system object.
  ///
  /// Returns a `Future<FileSystemEntity>` that completes with this
  /// [FileSystemEntity] when the deletion is done. If the [FileSystemEntity]
  /// cannot be deleted, the future completes with an exception.
  Future<FileSystemEntity> delete({bool recursive = false});

  /// Start watching the [FileSystemEntity] for changes.
  ///
  /// The returned value is an endless broadcast [Stream], that only stops when
  /// one of the following happens:
  ///
  ///   * The [Stream] is canceled, e.g. by calling `cancel` on the
  ///      [StreamSubscription].
  ///   * The [FileSystemEntity] being watched is deleted.
  ///   * System Watcher exits unexpectedly.
  ///
  /// Use `events` to specify what events to listen for. The constants in
  /// [FileSystemEvent] can be or'ed together to mix events. Default is
  /// [FileSystemEvent.all].
  ///
  /// A move event may be reported as separate delete and create events.
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  });

  /// A [FileSystemEntity] whose path is the absolute path of [path].
  ///
  /// The type of the returned instance is the same as the type of
  /// this entity.
  ///
  /// A file system entity with an already absolute path is returned directly.
  /// For a non-absolute path, the returned entity is absolute *if possible*,
  /// but still refers to the same file system object.
  Future<FileSystemEntity> get absolute;

  FileStat? get cachedStat => null;
}

/// Base event class emitted by [FileSystemEntity.watch].
class FileSystemEvent {
  /// Bitfield for [FileSystemEntity.watch], to enable [FileSystemCreateEvent]s.
  static const int create = 1 << 0;

  /// Bitfield for [FileSystemEntity.watch], to enable [FileSystemModifyEvent]s.
  static const int modify = 1 << 1;

  /// Bitfield for [FileSystemEntity.watch], to enable [FileSystemDeleteEvent]s.
  static const int delete = 1 << 2;

  /// Bitfield for [FileSystemEntity.watch], to enable [FileSystemMoveEvent]s.
  static const int move = 1 << 3;

  /// Bitfield for [FileSystemEntity.watch], for enabling all of [create],
  /// [modify], [delete] and [move].
  static const int all = create | modify | delete | move;

  /// The type of event. See [FileSystemEvent] for a list of events.
  final int type;

  /// The path that triggered the event.
  ///
  /// Depending on the platform and the [FileSystemEntity], the path may be
  /// relative.
  final String path;

  /// Is `true` if the event target was a directory.
  ///
  /// Note that if the file has been deleted by the time the event has arrived,
  /// this will always be `false` on Windows. In particular, it will always be
  /// `false` for `delete` events.
  final bool isDirectory;

  FileSystemEvent(this.type, this.path, this.isDirectory);
}

class FileStat {
  /// The time of the last change to the data or metadata of the file system
  /// object.
  ///
  /// On Windows platforms, this is instead the file creation time.
  final DateTime changed;

  /// The time of the last change to the data of the file system object.
  final DateTime modified;

  /// The time of the last access to the data of the file system object.
  ///
  /// On Windows platforms, this may have 1 day granularity, and be
  /// out of date by an hour.
  final DateTime accessed;

  /// The type of the underlying file system object.
  final FileSystemEntityType type;

  /// The size of the file system object.
  final int size;

  const FileStat({
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.type,
    required this.size,
  });
}

abstract class File with FileSystemEntity {
  Future<File> create({bool recursive = false});

  @override
  Future<File> rename(String newPath);

  Future<File> copy(String newPath);

  @override
  Future<File> get absolute;

  Future<File> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  });

  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    bool flush = false,
  });

  Future<String> readAsString();

  Future<Uint8List> readAsBytes();
}

/// The modes in which a [File] can be opened.
enum FileMode {
  /// The mode for opening a file only for reading.
  read,

  /// Mode for opening a file for reading and writing. The file is
  /// overwritten if it already exists. The file is created if it does not
  /// already exist.
  write,

  /// Mode for opening a file for reading and writing to the
  /// end of it. The file is created if it does not already exist.
  append,

  /// Mode for opening a file for writing *only*. The file is
  /// overwritten if it already exists. The file is created if it does not
  /// already exist.
  writeOnly,

  /// Mode for opening a file for writing *only* to the
  /// end of it. The file is created if it does not already exist.
  writeOnlyAppend,
}

abstract class Directory with FileSystemEntity {
  Future<Directory> create({bool recursive = false});

  @override
  Future<Directory> rename(String newPath);

  @override
  Future<Directory> get absolute;

  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  });
}

abstract class Link with FileSystemEntity {
  Future<Link> create(String target, {bool recursive = false});

  Future<Link> update(String target);

  Future<String> target();

  @override
  Future<Link> rename(String newPath);

  @override
  Future<Link> get absolute;
}

class FileSystemException {
  final String message;

  final String path;

  FileSystemException(this.message, this.path);

  @override
  String toString() => "FileSystemException: $message, path = '$path'";
}
