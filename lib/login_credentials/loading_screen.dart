import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/admin/AllAdminScreen.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';
import 'package:restaurant_app/screens/main_menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/data.dart';

final firestore = FirebaseFirestore.instance;

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  // void getLocation() async {
  //   Position position = await getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.bestForNavigation);
  //   print(position.latitude);
  //   print(position.longitude);
  //   final coordinates = Coordinates(position.latitude, position.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;

  //   if (first.locality != null && first.adminArea != null) {
  //     if (first.subLocality != null) {
  //       Provider.of<Data>(context, listen: false).setCurrentLocation(
  //           first.subLocality.toString() + ', ' + first.locality);

  //       getLoginInfo();
  //     } else {
  //       Provider.of<Data>(context, listen: false).setCurrentLocation(
  //           first.locality.toString() + ', ' + first.adminArea);
  //       getLoginInfo();
  //     }
  //   }
  // }

//   Future<void> signIn() async {
//     try {
//       AuthResult k = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       if (k != null) {
//         Provider.of<Data>(context, listen: false).setUserEmail(email);
//         if(email!='auth1@gmail.com'){
//           Navigator.push(context, ScaleRoute(page: MainMenuScreen()));
//         }else if(email=='auth1@gmail.com'){
// //          Navigator.push(context, ScaleRoute(page:AdminOptionScreen()));
//           Navigator.push(context, ScaleRoute(page:OrdersScreen()));

//         }
//       }
//     } on PlatformException {
//       Navigator.push(context, ScaleRoute(page: LoginScreen()));
//       print('platform exception daw');
//     } catch (e) {
//       Navigator.push(context, ScaleRoute(page: LoginScreen()));
//       print('Sign in la error ${e.message}');
//     }
//   }

  void showToast(String _message) {
    Fluttertoast.showToast(
      msg: _message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
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
        getLoginInfo();
        return;
      }
    } on SocketException catch (_) {
      Navigator.push(context, ScaleRoute(page: LoginScreen()));
      return;
    }
  }

  Future<void> getLoginInfo() async {
    var prefs1 = await SharedPreferences.getInstance();
    var _email = prefs1.getString('foodyUserEmail').toString();
    print('USER EMAIL:  $_email');
    try {
      if (_email != 'null') {
        if (_email == 'premwork.pr@gmail.com') {
          Navigator.push(context, ScaleRoute(page: AllAdminScreen()));
        } else {
          try {
            firestore.collection(_email).doc('contactCredentials').get().then(
              (snapshot) {
                if (snapshot.data != null) {
                  Map<dynamic, dynamic> values = snapshot.data();
                  values.forEach(
                    (key, value) {
                      if (key.toString() == 'loggedIn') {
                        if (value.toString() == 'yes') {
                          Provider.of<Data>(context, listen: false)
                              .setUserEmail(_email);
                          Navigator.push(
                              context, ScaleRoute(page: MainMenuScreen()));
                        } else {
                          Navigator.push(
                              context, ScaleRoute(page: LoginScreen()));
                        }
                      }
                    },
                  );
                } else {
                  Navigator.push(context, ScaleRoute(page: LoginScreen()));
                }
              },
            );
          } catch (e) {
            print('Firestore error $e');
            Navigator.push(context, ScaleRoute(page: LoginScreen()));
          }
        }
      } else {
        Navigator.push(context, ScaleRoute(page: LoginScreen()));
      }
    } catch (e) {
      print('Error in splash screen: $e');
      Navigator.push(context, ScaleRoute(page: LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE05C52),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/foody.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
