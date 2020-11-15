import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/login_credentials/loading_screen.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore = FirebaseFirestore.instance;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = '';
  String mobileNumber = '';
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    getContactDetails();
  }

  Future getContactDetails() async {
    await _firestore
        .collection(
            Provider.of<Data>(context, listen: false).userEmail.toString())
        .doc('contactCredentials')
        .get()
        .then((value) {
      if (value.data() != null) {
        Map<dynamic, dynamic> values = value.data();
        values.forEach((key, value1) {
          if (key.toString() == 'name') {
            setState(() {
              name = value1.toString();
            });
          } else if (key.toString() == 'mobileNumber') {
            setState(() {
              mobileNumber = value1.toString();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isSpinning,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Color(0xFF13161D),
          automaticallyImplyLeading: false,
          title: ListTile(
            title: Text(
              name.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
            subtitle: Row(
              children: <Widget>[
                Text(
                  mobileNumber == 'null' ? '' : mobileNumber,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  name != null
                      ? name != ''
                          ? ' • ${Provider.of<Data>(context).userEmail}'
                          : ' '
                      : ' ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Scrollbar(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue[800],
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            GoogleSignIn().signOut();
                            var _pref = await SharedPreferences.getInstance();
                            _pref.remove('foodyUserEmail');
                            try {
                              await firestore
                                  .collection(
                                      Provider.of<Data>(context, listen: false)
                                          .userEmail)
                                  .doc('contactCredentials')
                                  .update({'loggedIn': 'no'})
                                  .then((value) => print('Success'))
                                  .catchError((e) => print(e));
                            } catch (e) {
                              print(e);
                            }
                            Provider.of<Data>(context, listen: false)
                                .setEveryThingToNull();
                            Navigator.push(context, MySlide(builder: (context) {
                              return LoginScreen();
                            }));
                          },
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//          Positioned(
//            bottom: 0,
//            left: 0,
//            right: 0,
//            child: Container(
//              height: 70,
//              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(10),
//                color: Colors.indigo,
//              ),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  IconButton(
//                      icon: Image.asset(
//                        'images/home-2-line.png',
//                        color: Colors.white,
//                      ),
//                      iconSize: 30,
//                      onPressed: () {
//                        Navigator.push(
//                            context, MaterialPageRoute(builder: (context){
//                          return MainMenuScreen();
//                        }));
//                      }),
//                  IconButton(
//                      icon: Image.asset(
//                        'images/shopping-cart-line.png',
//                        color: Colors.white,
//                      ),
//                      onPressed: () {
//                        Navigator.push(
//                            context, MaterialPageRoute(builder: (context){
//                          return CartScreen();
//                        }));
//                      }),
//                  IconButton(
//                      icon: Image.asset(
//                        'images/user-3-fill.png',
//                        color: Colors.white,
//                      ),
//                      onPressed: () {}),
//                ],
//              ),
//            ),
//          ),
