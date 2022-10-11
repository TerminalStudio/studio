import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/ui/pages/host_edit_page.dart';

class AddHostTab extends TabItem {
  AddHostTab() {
    title.value = const Text('Connect');
    content.value = const AddHostTabView();
  }
}

class AddHostTabView extends ConsumerStatefulWidget {
  const AddHostTabView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddHostTabViewState();
}

class _AddHostTabViewState extends ConsumerState<AddHostTabView> {
  @override
  Widget build(BuildContext context) {
    return const HostEditPage();
    // return Container(
    //   constraints: const BoxConstraints.expand(),
    //   color: const Color.fromARGB(255, 245, 245, 245),
    //   alignment: Alignment.center,
    //   child: Container(
    //     constraints: const BoxConstraints.tightFor(width: 550),
    //     child: const AddHostForm(),
    //   ),
    // );
  }
}

// class AddHostForm extends ConsumerStatefulWidget {
//   const AddHostForm({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _AddHostFormState();
// }

// class _AddHostFormState extends ConsumerState<AddHostForm> {
//   final formLabel = TextEditingController();
//   final formHost = TextEditingController();
//   final formPort = TextEditingController();
//   final formUsername = TextEditingController();
//   final formPassword = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(32),
//       children: [
//         MacosFormRow(
//           label: const Text('Protocol'),
//           child: Container(
//             constraints: const BoxConstraints.tightFor(width: 200),
//             alignment: Alignment.centerLeft,
//             child: const MacosPulldownButton(
//               title: 'SSH',
//               items: [
//                 MacosPulldownMenuItem(title: Text('SSH')),
//               ],
//             ),
//           ),
//         ),
//         MacosTextFormRow(
//           label: const Text('Label:'),
//           placeholder: 'Optional',
//           controller: formLabel,
//         ),
//         MacosTextFormRow(
//           label: const Text('Host:'),
//           placeholder: 'example.com / 1.2.3.4',
//           controller: formHost,
//         ),
//         MacosTextFormRow(
//           label: const Text('Port:'),
//           placeholder: '22',
//           controller: formPort,
//         ),
//         MacosTextFormRow(
//           label: const Text('User:'),
//           placeholder: 'root',
//           controller: formUsername,
//         ),
//         MacosTextFormRow(
//           label: const Text('Password:'),
//           obscureText: true,
//           placeholder: '',
//           controller: formPassword,
//         ),
//         const SizedBox(height: 8),
//         MacosFormRow(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               PushButton(
//                 buttonSize: ButtonSize.small,
//                 onPressed: submit,
//                 child: const Text('Connect'),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> submit() async {
//     final sshHosts = await ref.read(sshHostBoxProvider.future);
//     await sshHosts.add(
//       SSHHostRecord(
//         name: formLabel.text,
//         host: formHost.text,
//         port: int.parse(formPort.text),
//         username: formUsername.text,
//         password: formPassword.text,
//       ),
//     );

//     await alert('Success', 'Host added successfully');

//     closeTab();
//   }

//   Future<void> alert(String title, String message) async {
//     await showMacosAlertDialog(
//       context: context,
//       builder: (context) {
//         return MacosAlertDialog(
//           appIcon: const FlutterLogo(),
//           title: Text(title),
//           message: Text(message),
//           primaryButton: PushButton(
//             buttonSize: ButtonSize.small,
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         );
//       },
//     );
//   }

//   void closeTab() {
//     TabScope.of(context)?.dispose();
//   }
// }
