// import 'package:flutter/material.dart';
// import 'package:teego/home/live/zego_live_stream.dart';
// import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
// import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
//
// class SelectScreen extends StatefulWidget {
//   const SelectScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SelectScreen> createState() => _SelectScreenState();
// }
//
// class _SelectScreenState extends State<SelectScreen> {
//   var host = false;
//
//   final TextEditingController userNameControler = TextEditingController();
//   final TextEditingController userIdControler = TextEditingController();
//
//   // static final String baseUrl = 'https://parseapi.back4app.com/classes/';
//
//    Future<String?> initParse() async {
//     // final keyAppId = 'HSnoUGSH5VrAik7tnZ9QrLi2TX5VugKptx8WHHh8';
//     // final keyClientKey = 'x1fpB32UIrc91d1ztznVQuEC2olPEBAymcWqOBk2';
//     // final keyParseServerUrl = 'https://parseapi.back4app.com/';
//     // await Parse().initialize(keyAppId, keyParseServerUrl,clientKey: keyClientKey,debug: true);
//     final streamingsss = ParseObject('Streamingsss')
//       ..set('userName', 'Ali Haider');
//     final response =  await streamingsss.save();
//     return streamingsss.objectId;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: CircleAvatar(radius: 75,backgroundColor: Colors.purple,),
//                 ),
//                 SizedBox(height: 70,),
//                 textField(
//                   controller: userNameControler,
//                   text: 'User Name',
//                   icon: Icons.person,
//                 ),
//                 const SizedBox(height: 25),
//                 textField(
//                   controller: userIdControler,
//                   text: 'User Id',
//                   icon: Icons.pin,
//                 ),
//                 const SizedBox(height: 10),
//                 hostCheck(),
//                 const SizedBox(height: 15),
//                 submitButton(context),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Row hostCheck() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text('Host'),
//         Checkbox(
//           value: host,
//           onChanged: ((value) {
//             setState(() {
//               host = value!;
//             });
//           }),
//         ),
//       ],
//     );
//   }
//
//   Material submitButton(BuildContext context) {
//     return Material(
//       elevation: 2,
//       borderRadius: BorderRadius.circular(5),
//       color: Colors.brown,
//       child: MaterialButton(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         minWidth: MediaQuery.of(context).size.width,
//         onPressed: () async {
//           // initParse();
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: ((context) => MyWidget(
//                 userID: userIdControler.text,
//                 userName: userNameControler.text,
//                 liveID: '100',
//                 isHost: host, config: ZegoUIKitPrebuiltLiveStreamingConfig(),
//               ))));
//         },
//         child: const Text(
//           'Join',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   TextFormField textField({
//     required TextEditingController controller,
//     required String text,
//     required IconData icon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       onSaved: (value) {
//         controller.text = value!;
//       },
//       decoration: InputDecoration(
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Colors.brown,
//             width: 1,
//           ),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Colors.brown,
//             width: 2,
//           ),
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: Colors.brown,
//         ),
//         contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
//         hintText: text,
//         hintStyle: const TextStyle(
//           color: Color.fromARGB(255, 182, 174, 172),
//         ),
//       ),
//     );
//   }
// }
