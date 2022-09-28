import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio/src/core/fs.dart';
import 'package:studio/src/core/plugin.dart';

class FileManagerPlugin with Plugin {
  final files = ValueNotifier([]);

  @override
  void activate() async {
    final fs = await host.fileSystem;

    final files = await fs.directory('.').list().fold(
      <FileSystemEntity>[],
      (files, file) => [...files, file],
    );

    this.files.value = files;

    setTitle('File Manager');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: ValueListenableBuilder(
        valueListenable: files,
        builder: (context, files, child) {
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                title: Text(file.path),
              );
            },
          );
        },
      ),
    );
  }
}
