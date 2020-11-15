import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restaurant_app/admin/AllAdminScreen.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/screens/top_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

final realTimeDataBase = FirebaseDatabase.instance.reference();
final fireStoreDataBase = FirebaseFirestore.instance;

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool obscurePassword = true;
  bool errorTextPassword = false;
  bool errorTextEmail = false;
  bool isSpinning = false;
  bool isConnected;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void showToast(String _message) {
    Fluttertoast.showToast(
      msg: _message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      fontSize: 17.0,
    );
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
        return;
      }
    } on SocketException catch (_) {
      setState(() {
        isConnected = false;
      });
      showToast('No Internet Access');
      return;
    }
  }

//   Future<void> signIn() async {
//     try {
//       AuthResult k = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       if (k != null) {
//         var prefs1 = await SharedPreferences.getInstance();
//         var prefs2 = await SharedPreferences.getInstance();
//         await prefs1.setString('loginEmail', email);
//         await prefs2.setString('loginPassword', password);

//         setState(() {
//           isSpinning = false;
//         });
//         Provider.of<Data>(context, listen: false).setUserEmail(email);
//         if (email != 'auth1@gmail.com') {
//           Navigator.push(context, ScaleRoute(page: MainMenuScreen()));
//         } else if (email == 'auth1@gmail.com') {
// //          Navigator.push(context, ScaleRoute(page:AdminOptionScreen()));
//           // Navigator.push(context, ScaleRoute(page: OrdersScreen()));
//         }
//       }
//     } on PlatformException {
//       setState(() {
//         isSpinning = false;
//       });
//       _scaffoldKey.currentState.showSnackBar(SnackBar(
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 2),
//         content: Container(
//             height: 40,
//             child: Center(
//                 child: Text(
//               'Incorrect email or password',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ))),
//       ));
//     } catch (e) {
//       setState(() {
//         isSpinning = false;
//       });
//       _scaffoldKey.currentState.showSnackBar(SnackBar(
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 2),
//         content: Container(
//             height: 40,
//             child: Center(
//                 child: Text(
//               'An error occurred while signing in',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ))),
//       ));
//       print('Sign in la error ${e.message}');
//     }
//   }

  // ignore: missing_return
  Future<String> signInWithGoogle() async {
    setState(() {
      isSpinning = true;
    });
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final User currentUser = _auth.currentUser;
        assert(user.uid == currentUser.uid);
        print(user.uid);
        var prefs1 = await SharedPreferences.getInstance();
        await prefs1.setString('foodyUserEmail', user.email.toString());
        if (user.email != 'premwork.pr@gmail.com') {
          await fireStoreDataBase
              .collection(user.email.toString())
              .doc('contactCredentials')
              .get()
              .then((DocumentSnapshot docSnapshot) async {
            if (docSnapshot.exists) {
              await fireStoreDataBase
                  .collection(user.email.toString())
                  .doc('contactCredentials')
                  .update({
                'name': user.displayName.toString(),
                'email': user.email.toString(),
                'photoUrl': user.photoURL.toString(),
                'uid': user.uid.toString(),
                'mobileNumber':
                    user.phoneNumber == null ? null : user.phoneNumber,
                'loggedIn': 'yes',
              });
            } else {
              await fireStoreDataBase
                  .collection(user.email.toString())
                  .doc('contactCredentials')
                  .set({
                'name': user.displayName.toString(),
                'email': user.email.toString(),
                'photoUrl': user.photoURL.toString(),
                'uid': user.uid.toString(),
                'mobileNumber':
                    user.phoneNumber == null ? null : user.phoneNumber,
                'loggedIn': 'yes',
                'address': null
              });
            }
          });
          Provider.of<Data>(context, listen: false).setPhotoUrl(user.photoURL);
          Provider.of<Data>(context, listen: false)
              .setUserName(user.displayName);
          Provider.of<Data>(context, listen: false).setUserEmail(user.email);
          Provider.of<Data>(context, listen: false)
              .setPhoneNumber(user.phoneNumber);
        } else {
          Provider.of<Data>(context, listen: false).setUserEmail(user.email);
        }
        print('Sign in with GOOGLE SUCCEDEED');
        print('DISPLAY NAME:   ${user.displayName}');
        print('EMAIL:  ${user.email}');
        return '$user';
      }

      return null;
    } on NoSuchMethodError {
      setState(() {
        isSpinning = false;
      });
    } catch (e) {
      setState(() {
        isSpinning = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          content: Container(
            height: 40,
            child: Center(
              child: Text(
                'An error occurred while signing in',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      );
      print('The google sign in error is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return;
      },
      child: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Scaffold(
          key: _scaffoldKey,
          body: Scrollbar(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/pancakes_in_a_pan.png'),
                    fit: BoxFit.cover),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Material(
                          color: Colors.transparent,
                          elevation: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'foody',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 75,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 3,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 75,
                        margin: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            await checkConnection();
                            if (isConnected) {
                              FocusScope.of(context).unfocus();
                              googleSignIn.signOut();
                              signInWithGoogle().then(
                                (result) {
                                  if (result != null) {
                                    setState(() {
                                      isSpinning = false;
                                    });
                                    if (Provider.of<Data>(context,
                                                listen: false)
                                            .userEmail ==
                                        'premwork.pr@gmail.com') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllAdminScreen(),
                                        ),
                                      );
                                    } else
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return TopScreen();
                                          },
                                        ),
                                      );
                                  } else {
                                    setState(() {
                                      isSpinning = false;
                                    });
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 2),
                                        content: Container(
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              'An error occurred while signing in',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Montserrat',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                          child: ListTile(
                            leading: Image.asset(
                              'images/GoogleLogo.png',
                              height: 25,
                              width: 25,
                            ),
                            title: Text(
                              'SIGN IN WITH GOOGLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //  Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Container(
              //       height: 420,
              //       padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
              //       margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: Column(
              //         children: <Widget>[
              //           Padding(
              //             padding: const EdgeInsets.only(left: 10, bottom: 10),
              //             child: Text(
              //               'Welcome Back ',
              //               style: TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 30,
              //                   color: Colors.white),
              //             ),
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 10),
              //             child: TextField(
              //               controller: _emailController,
              //               decoration: InputDecoration(
              //                 labelStyle:
              //                     TextStyle(fontWeight: FontWeight.bold),
              //                 labelText: 'Email',
              //                 errorText: errorTextEmail
              //                     ? 'Please enter valid email address'
              //                     : null,
              //                 errorStyle: TextStyle(color: Colors.red),
              //               ),
              //               keyboardType: TextInputType.emailAddress,
              //               onChanged: (value) {
              //                 setState(() {
              //                   errorTextEmail = false;
              //                 });
              //                 email = value;
              //               },
              //             ),
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 10),
              //             child: TextField(
              //               controller: _passwordController,
              //               obscureText: obscurePassword,
              //               decoration: InputDecoration(
              //                 labelStyle:
              //                     TextStyle(fontWeight: FontWeight.bold),
              //                 labelText: 'Password',
              //                 errorText: errorTextPassword
              //                     ? 'Password should be of minimum 7 characters'
              //                     : null,
              //                 errorStyle: TextStyle(color: Colors.red),
              //                 suffixIcon: InkWell(
              //                     onTap: () {
              //                       setState(() {
              //                         obscurePassword =
              //                             obscurePassword ? false : true;
              //                       });
              //                     },
              //                     child: Icon(Icons.remove_red_eye)),
              //               ),
              //               onChanged: (value) {
              //                 setState(() {
              //                   errorTextPassword = false;
              //                 });
              //                 password = value;
              //               },
              //             ),
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 10, vertical: 10),
              //             child: InkWell(
              //               onTap: () async {
              //                 if (email != null) {
              //                   try {
              //                     FocusManager.instance.primaryFocus.unfocus();
              //                     await FirebaseAuth.instance
              //                         .sendPasswordResetEmail(email: email);
              //                     _scaffoldKey.currentState.showSnackBar(
              //                       SnackBar(
              //                         backgroundColor: Colors.red,
              //                         duration: Duration(seconds: 2),
              //                         content: Container(
              //                           height: 40,
              //                           child: Center(
              //                             child: Text(
              //                               'Check mail to reset password',
              //                               style: TextStyle(
              //                                   fontWeight: FontWeight.bold,
              //                                   fontSize: 20),
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                     );
              //                   } on PlatformException {
              //                     setState(() {
              //                       errorTextEmail = true;
              //                     });
              //                   } catch (e) {
              //                     setState(() {
              //                       errorTextEmail = true;
              //                     });
              //                   }
              //                 } else {
              //                   setState(() {
              //                     errorTextEmail = true;
              //                   });
              //                 }
              //               },
              //               child: Text(
              //                 'Forgot password ?',
              //                 style: TextStyle(
              //                     color: Colors.indigo,
              //                     fontWeight: FontWeight.bold),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             height: 55,
              //             margin: EdgeInsets.only(
              //                 left: 10, right: 10, bottom: 10, top: 25),
              //             decoration: BoxDecoration(
              //                 gradient: LinearGradient(
              //                     begin: Alignment.centerLeft,
              //                     end: Alignment.centerRight,
              //                     colors: [Colors.indigo, Colors.blue]),
              //                 color: Colors.indigo,
              //                 borderRadius: BorderRadius.circular(20)),
              //             child: FlatButton(
              //               onPressed: () async {
              //                 await checkConnection();
              //                 if (isConnected) {
              //                   if (password != null && password.length > 6) {
              //                     setState(() {
              //                       isSpinning = true;
              //                     });
              //                     FocusScope.of(context).unfocus();
              //                     signIn();
              //                   } else {
              //                     setState(() {
              //                       errorTextPassword = true;
              //                     });
              //                   }
              //                 }
              //               },
              //               child: Center(
              //                 child: Text(
              //                   'SIGN IN',
              //                   style: TextStyle(color: Colors.white),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             height: 20,
              //             margin: EdgeInsets.symmetric(
              //                 horizontal: 15, vertical: 10),
              //             decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(20)),
              //             child: Center(
              //               child: InkWell(
              //                 onTap: () {
              //                   Vibration.vibrate(duration: 30);
              //                   FocusManager.instance.primaryFocus.unfocus();
              //                   Navigator.push(
              //                       context, ScaleRoute(page: SignUpScreen()));
              //                 },
              //                 child: Text(
              //                   "Don't have an account ? Sign Up",
              //                   style: TextStyle(color: Colors.black),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
        ),
      ),
    );
  }
}

//        await _fireStoreDataBase
//            .collection(email)
//            .document('contactCredentials')
//            .get()
//            .then((value) {
//          print(value.data);
//          if (value.data != null) {
//            Map<dynamic, dynamic> values = value.data;
//            values.forEach((key, value1) {
//              if (key.toString() == 'name') {
//                name = value1.toString();
//              } else if (key.toString() == 'mobileNumber') {
//                mobileNumber = value1.toString();
//              }
//            });
//          }
//        });

//Future<void> getLoginInfo() async {
//  var prefs1 = await SharedPreferences.getInstance();
//  var prefs2 = await SharedPreferences.getInstance();
//  var prefEmail = prefs1.getString('loginEmail');
//  var prefPassword = prefs2.getString('loginPassword');
//
//  if (prefEmail != null && prefPassword != null) {
//    setState(() {
//      email = prefEmail;
//      password = prefPassword;
//      isSpinning = true;
//      signIn();
//    });
//  } else {
//    setState(() {
//      isSpinning = false;
//      email = null;
//      password = null;
//    });
//  }
//}

//                InkWell(
//                  onTap: () async {
//                    GoogleSignInAccount googleUser =
//                        await GoogleSignIn().signIn();
//                    GoogleSignInAuthentication googleAuth =
//                        await googleUser.authentication;
//                    final AuthCredential credential =
//                        GoogleAuthProvider.getCredential(
//                      accessToken: googleAuth.accessToken,
//                      idToken: googleAuth.idToken,
//                    );
//                    try {
//                      final user = await FirebaseAuth.instance
//                          .signInWithCredential(credential);
//                      if (user != null) {
//                        _scaffoldKey.currentState.showSnackBar(SnackBar(
//                          backgroundColor: Colors.red,
//                          duration: Duration(seconds: 2),
//                          content: Container(
//                              height: 40,
//                              child: Center(
//                                  child: Text(
//                                'Signed In successfully',
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold, fontSize: 20),
//                              ))),
//                        ));
//                      }
//                    } on PlatformException {
//                      print('konda');
//                    } catch (e) {
//                      print(e);
//                    }
//                  },
//                  child: Container(
//                    height: 55,
//                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                    decoration: BoxDecoration(
//                        gradient: LinearGradient(
//                            begin: Alignment.centerLeft,
//                            end: Alignment.centerRight,
//                            colors: [Colors.indigo, Colors.blue]),
//                        color: Colors.indigo,
//                        borderRadius: BorderRadius.circular(20)),
//                    child: Center(
//                      child: Text(
//                        'SIGN IN with Google',
//                        style: TextStyle(color: Colors.white),
//                      ),
//                    ),
//                  ),
//                ),

//                  InkWell(
//                    onTap: () async {
//                      FirebaseAuth.instance.signOut();
//                      GoogleSignIn().signOut();
//                      _scaffoldKey.currentState.showSnackBar(SnackBar(
//                        backgroundColor: Colors.red,
//                        duration: Duration(seconds: 2),
//                        content: Container(
//                            height: 40,
//                            child: Center(
//                                child: Text(
//                                  'Signed out successfully',
//                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                                ))),
//                      ));
//                    },
//                    child: Container(
//                      height: 40,
//                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                      decoration: BoxDecoration(
//                          color: Colors.indigo,
//                          borderRadius: BorderRadius.circular(5)),
//                      child: Center(
//                        child: Text('Sign out'),
//                      ),
//                    ),
//                  ),
