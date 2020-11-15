// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:restaurant_app/components/MySlide.dart';
// import 'package:restaurant_app/components/data_provider_restaurant_app.dart';
// import 'package:restaurant_app/screens/main_menu_screen.dart';
// import 'package:restaurant_app/screens/top_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';

// final _fireStoreDataBase = Firestore.instance;

// class SignUpScreen extends StatefulWidget {
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   String email;
//   String password;
//   String name;
//   String mobileNumber;
//   bool isConnected;
//   bool isSpinning = false;
//   bool obscurePassword = true;
//   bool errorTextPassword = false;
//   bool errorTextEmail = false;
//   bool errorTextName = false;
//   bool errorTextMobileNumber = false;

//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _mobileNumberController = TextEditingController();

//   void showToast(String _message) {
//     Fluttertoast.showToast(
//       msg: _message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.CENTER,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.red[600],
//       textColor: Colors.white,
//       fontSize: 17.0,
//     );
//   }

//   Future<void> checkConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         setState(() {
//           isConnected = true;
//         });
//         return;
//       }
//     } on SocketException catch (_) {
//       setState(() {
//         isConnected = false;
//       });
//       showToast('No Internet Access');
//       return;
//     }
//   }

//   // Future<void> signUp() async {
//   //   try {
//   //     Auth k = await FirebaseAuth.instance
//   //         .createUserWithEmailAndPassword(email: email, password: password);
//   //     if (k != null) {
//   //       await _fireStoreDataBase
//   //           .collection(email)
//   //           .document('contactCredentials')
//   //           .setData({
//   //         'name': '$name',
//   //         'mobileNumber': '$mobileNumber',
//   //         'email': '$email'
//   //       });
//   //       var prefs1 = await SharedPreferences.getInstance();
//   //       var prefs2 = await SharedPreferences.getInstance();
//   //       await prefs1.setString('loginEmail', email);
//   //       await prefs2.setString('loginPassword', password);

//   //       setState(() {
//   //         isSpinning = false;
//   //       });
//   //       Provider.of<Data>(context, listen: false).setUserEmail(email);
//   //       Navigator.push(context, ScaleRoute(page: MainMenuScreen()));
//   //     }
//   //   } on PlatformException {
//   //     setState(() {
//   //       isSpinning = false;
//   //     });
//   //     _scaffoldKey.currentState.showSnackBar(SnackBar(
//   //       backgroundColor: Colors.red,
//   //       duration: Duration(seconds: 2),
//   //       content: Container(
//   //           height: 40,
//   //           child: Center(
//   //               child: Text(
//   //             'Incorrect email or password',
//   //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//   //           ))),
//   //     ));
//   //   } catch (e) {
//   //     setState(() {
//   //       isSpinning = false;
//   //     });
//   //     _scaffoldKey.currentState.showSnackBar(SnackBar(
//   //       backgroundColor: Colors.red,
//   //       duration: Duration(seconds: 2),
//   //       content: Container(
//   //           height: 40,
//   //           child: Center(
//   //               child: Text(
//   //             'An error occurred while signing up',
//   //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//   //           ))),
//   //     ));
//   //     print('Sign Up la error ${e.message}');
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return ModalProgressHUD(
//       inAsyncCall: isSpinning,
//       child: Scaffold(
//         resizeToAvoidBottomPadding: false,
//         resizeToAvoidBottomInset: false,
//         key: _scaffoldKey,
//         body: Scrollbar(
//           child: Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage('images/bg 2.jpg'), fit: BoxFit.cover),
//             ),
//             alignment: Alignment.bottomCenter,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   height: 520,
//                   padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
//                   margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.only(left: 10, bottom: 10),
//                         child: Text(
//                           'SIGN UP ',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 30),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                             labelText: 'Name',
//                             errorText:
//                                 errorTextName ? 'Enter a valid name' : null,
//                             errorStyle: TextStyle(color: Colors.red),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           onChanged: (value) {
//                             setState(() {
//                               errorTextName = false;
//                             });
//                             name = value;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           controller: _mobileNumberController,
//                           decoration: InputDecoration(
//                             labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                             labelText: 'Mobile Number',
//                             errorText: errorTextMobileNumber
//                                 ? 'Enter a valid mobile number'
//                                 : null,
//                             errorStyle: TextStyle(color: Colors.red),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           onChanged: (value) {
//                             setState(() {
//                               errorTextMobileNumber = false;
//                             });
//                             mobileNumber = value;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           controller: _emailController,
//                           decoration: InputDecoration(
//                             labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                             labelText: 'Email',
//                             errorText: errorTextEmail
//                                 ? 'Enter a valid email address'
//                                 : null,
//                             errorStyle: TextStyle(color: Colors.red),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           onChanged: (value) {
//                             setState(() {
//                               errorTextEmail = false;
//                             });
//                             email = value;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             EdgeInsets.only(left: 10, right: 10, bottom: 25),
//                         child: TextField(
//                           controller: _passwordController,
//                           obscureText: obscurePassword,
//                           decoration: InputDecoration(
//                             labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                             labelText: 'Password',
//                             errorText: errorTextPassword
//                                 ? 'Password should be of minimum 7 characters'
//                                 : null,
//                             errorStyle: TextStyle(color: Colors.red),
//                             suffixIcon: InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     obscurePassword =
//                                         obscurePassword ? false : true;
//                                   });
//                                 },
//                                 child: Icon(Icons.remove_red_eye)),
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               errorTextPassword = false;
//                             });
//                             password = value;
//                           },
//                         ),
//                       ),
//                       Container(
//                         height: 55,
//                         margin:
//                             EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                         decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 colors: [Colors.indigo, Colors.blue]),
//                             color: Colors.indigo,
//                             borderRadius: BorderRadius.circular(20)),
//                         child: FlatButton(
//                           onPressed: () async {
//                             await checkConnection();
//                             if (isConnected) {
//                               if (name != null &&
//                                   mobileNumber != null &&
//                                   email != null &&
//                                   password != null) {
//                                 if (password.length > 6) {
//                                   setState(() {
//                                     isSpinning = true;
//                                   });
//                                   // signUp();
//                                 } else {
//                                   setState(() {
//                                     errorTextPassword = true;
//                                   });
//                                 }
//                               } else {
//                                 if (name == null) {
//                                   setState(() {
//                                     errorTextName = true;
//                                   });
//                                 } else if (mobileNumber == null) {
//                                   setState(() {
//                                     errorTextMobileNumber = true;
//                                   });
//                                 } else if (email == null) {
//                                   setState(() {
//                                     errorTextEmail = true;
//                                   });
//                                 } else if (password == null) {
//                                   setState(() {
//                                     errorTextPassword = true;
//                                   });
//                                 }
//                               }
//                             }
//                           },
//                           child: Center(
//                             child: Text(
//                               'SIGN UP',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 20,
//                         margin:
//                             EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20)),
//                         child: Center(
//                           child: InkWell(
//                             onTap: () {
//                               Vibration.vibrate(duration: 30);
//                               FocusManager.instance.primaryFocus.unfocus();
//                               Navigator.pop(context);
//                             },
//                             child: Text(
//                               "Already have an account ? Sign In",
//                               style: TextStyle(color: Colors.black),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// //                  InkWell(
// //                    onTap: () async {
// //                      await FirebaseAuth.instance.signOut();
// //                      await GoogleSignIn().signOut();
// //                      GoogleSignInAccount googleUser =
// //                          await GoogleSignIn().signIn();
// //                      GoogleSignInAuthentication googleAuth =
// //                          await googleUser.authentication;
// //                      final AuthCredential credential =
// //                          GoogleAuthProvider.getCredential(
// //                        accessToken: googleAuth.accessToken,
// //                        idToken: googleAuth.idToken,
// //                      );
// //
// //                      try {
// //                        Future<AuthResult> user = FirebaseAuth.instance
// //                            .signInWithCredential(credential);
// //                        var _userName;
// //                        await FirebaseAuth.instance.currentUser().then((user){
// //                          setState((){_userName= user.displayName;});
// //                          print(_userName);
// //                        });
// //
// //
// //                        if (user != null) {
// //                          var prefs3 = await SharedPreferences.getInstance();
// //                          var prefs4 = await SharedPreferences.getInstance();
// //                          await prefs3.setString('loginEmail', email);
// //                          await prefs4.setString('loginPassword', password);
// //                          Navigator.push(context, ScaleRoute(page: MainMenuScreen()));
// //                        }
// //                      } on PlatformException {
// //                        print('konda');
// //                      } catch (e) {
// //                        print(e);
// //                      }
// //                    },
// //                    child: Container(
// //                      height: 55,
// //                      margin:
// //                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
// //                      decoration: BoxDecoration(
// //                          gradient: LinearGradient(
// //                              begin: Alignment.centerLeft,
// //                              end: Alignment.centerRight,
// //                              colors: [Colors.indigo, Colors.blue]),
// //                          color: Colors.indigo,
// //                          borderRadius: BorderRadius.circular(20)),
// //                      child: Center(
// //                        child: Text(
// //                          'Continue with Google',
// //                          style: TextStyle(color: Colors.white),
// //                        ),
// //                      ),
// //                    ),
// //                  ),
