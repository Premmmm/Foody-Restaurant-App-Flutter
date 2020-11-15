// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class UploadScreen extends StatefulWidget {
//   @override
//   _UploadScreenState createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> {
//   File _imageFile;
//   String itemName;
//   String cost;
//   bool errorTextRecipeName = false;
//   String progressPercent;
//   StorageUploadTask _uploadTask;

//   TextEditingController _itemNameController = TextEditingController();
//   TextEditingController _itemCostController = TextEditingController();
//   final FirebaseStorage storage = FirebaseStorage.instance;

//   Future<void> _pickImage(ImageSource source) async {
//     File selected =
//         // ignore: deprecated_member_use
//         await ImagePicker.pickImage(source: source, imageQuality: 85);

//     setState(() {
//       _imageFile = selected;
//     });
//   }

//   Future _startUpload() async {
//     String filePath = '$itemName.png';
//     setState(() {
//       _uploadTask = storage.ref().child(filePath).putFile(_imageFile);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.indigo,
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: Text('Upload Recipe'),
//       ),
//       body: Scrollbar(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListView(
//             children: <Widget>[
//               Center(
//                 child: Container(
//                   height: 300,
//                   width: 600,
//                   child: _imageFile != null ? Image.file(_imageFile) : Text(''),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextField(
//                 controller: _itemNameController,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(width: 2),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(width: 2),
//                   ),
//                   labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                   labelText: 'Name of the item',
//                   errorText: errorTextRecipeName ? 'Please enter name' : null,
//                   errorStyle: TextStyle(color: Colors.red),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     errorTextRecipeName = false;
//                   });
//                   itemName = value;
//                 },
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextField(
//                 controller: _itemCostController,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(width: 2),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(width: 2),
//                   ),
//                   labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                   labelText: 'Cost of the item to be displayed',
//                   errorText:
//                       errorTextRecipeName ? 'Please enter the cost' : null,
//                   errorStyle: TextStyle(color: Colors.red),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     errorTextRecipeName = false;
//                   });
//                   cost = value;
//                 },
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.indigo,
//                 ),
//                 child: FlatButton(
//                   onPressed: () {
//                     setState(() {
//                       progressPercent = '0';
//                     });
//                     _pickImage(ImageSource.gallery);
//                   },
//                   child: Center(
//                     child: Text(
//                       'Select Item Picture',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.indigo,
//                 ),
//                 child: FlatButton.icon(
//                     onPressed: () {
//                       _startUpload();
//                     },
//                     icon: Icon(
//                       Icons.cloud_upload,
//                       color: Colors.white,
//                     ),
//                     label: Text(
//                       "Upload Item",
//                       style: TextStyle(color: Colors.white),
//                     )),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               if (_uploadTask != null)
//                 StreamBuilder<StorageTaskEvent>(
//                   stream: _uploadTask.events,
//                   builder: (context, snapshot) {
//                     var event = snapshot?.data?.snapshot;
//                     progressPercent = event != null
//                         ? (event.bytesTransferred / event.totalByteCount)
//                             .toStringAsPrecision(3)
//                         : '0';
//                     return Column(
//                       children: <Widget>[
//                         if (_uploadTask.isInProgress)
//                           LinearProgressIndicator(
//                             value: double.parse(progressPercent),
//                           ),
//                         if (_uploadTask.isInProgress)
//                           Text(
//                             'Uploading',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 17),
//                           ),
//                         if (_uploadTask.isComplete)
//                           Text(
//                             'Successfully uploaded',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 17),
//                           ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           '${double.parse(progressPercent) * 100} %',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 15),
//                         )
//                       ],
//                     );
//                   },
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// //
// //class Uploader extends StatefulWidget {
// //  final File file;
// //  final String recipeName;
// //  Uploader({this.file, this.recipeName});
// //  @override
// //  _UploaderState createState() => _UploaderState();
// //}
// //
// //class _UploaderState extends State<Uploader> {
// //  final FirebaseStorage storage = FirebaseStorage.instance;
// //  double progressPercent;
// //  StorageUploadTask _uploadTask;
// //
// //  Future _startUpload() async {
// //    String filePath = '${widget.recipeName}.png';
// //    setState(() {
// //      _uploadTask = storage.ref().child(filePath).putFile(widget.file);
// //    });
// //    if (_uploadTask.isComplete) {
// //      setState(() {
// //        _uploadTask = null;
// //      });
// //    }
// //  }
// //
// //  @override
// //  Widget build(BuildContext context) {
// //    return Column(
// //      children: <Widget>[
// //        FlatButton.icon(
// //            onPressed: () {
// //              setState(() {
// //                progressPercent = 0;
// //              });
// //              _startUpload();
// //            },
// //            icon: Icon(
// //              Icons.cloud_upload,
// //            ),
// //            label: Text("upload to FB")),
// //        if (_uploadTask != null)
// //          StreamBuilder<StorageTaskEvent>(
// //            stream: _uploadTask.events,
// //            builder: (context, snapshot) {
// //              var event = snapshot?.data?.snapshot;
// //              progressPercent = event != null
// //                  ? event.bytesTransferred / event.totalByteCount
// //                  : 0;
// //              return Column(
// //                children: <Widget>[
// //                  if (_uploadTask.isInProgress)
// //                    LinearProgressIndicator(
// //                      value: progressPercent,
// //                    ),
// //                  Text('${progressPercent * 100} %')
// //                ],
// //              );
// //            },
// //          )
// //      ],
// //    );
// //  }
// //}
