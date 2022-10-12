// Import the language & theme
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:highlight/languages/all.dart';
import 'package:studio/src/core/fs.dart';

class CodeEditorTab extends TabItem {
  final File file;

  CodeEditorTab(this.file) {
    title.value = Text(file.basename);
    content.value = CodeEditorView(this);
    loadContent();
  }

  final codeController = ValueNotifier(
    CodeController(
      text: 'Loading...',
      theme: githubTheme,
    ),
  );

  Future<void> loadContent() async {
    final content = await file.readAsString();
    codeController.value = CodeController(
      text: content,
      language: detectLanguage(content),
      theme: githubTheme,
    );
  }
}

class CodeEditorView extends StatelessWidget {
  const CodeEditorView(this.tab, {super.key});

  final CodeEditorTab tab;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: githubTheme['root']!.backgroundColor,
      child: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: tab.codeController,
          builder: (context, codeController, child) {
            return CodeField(
              controller: codeController,
              cursorColor: CupertinoTheme.of(context).primaryColor,
              textStyle: const TextStyle(
                fontFamily: 'SourceCode',
                fontSize: 12,
                fontFamilyFallback: [
                  'Menlo', // macos
                  'Consolas', // windows
                  'monospace',
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Mode detectLanguage(String source) {
  final result = highlight.parse(source, autoDetection: true);
  return allLanguages[result.language]!;
}
