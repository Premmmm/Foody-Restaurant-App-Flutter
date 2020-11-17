import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/constants.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/login_credentials/loading_screen.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';

final _firestore = FirebaseFirestore.instance;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = '';
  String mobileNumber = '';
  bool isSpinning = false;
  Constants _constants;

  @override
  void initState() {
    super.initState();
    _constants = Constants();
    getContactDetails();
  }

  Future getContactDetails() async {
    await _firestore
        .collection(
            Provider.of<Data>(context, listen: false).user.email.toString())
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

  Future<void> _onSignOut() async {
    GoogleSignIn().signOut();
    try {
      await firestore
          .collection(Provider.of<Data>(context, listen: false).user.email)
          .doc('contactCredentials')
          .update({'loggedIn': 'no'})
          .then((value) => print('Success'))
          .catchError((e) => print(e));
      Navigator.push(context, SlideRightRoute(page: LoginScreen()));
      Provider.of<Data>(context, listen: false).setEveryThingToNull();
    } on FirebaseException {
      print('Customer sign out firebase exception');
    } catch (e) {
      print('customer sign out exception $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isSpinning,
      child: Scaffold(
        backgroundColor: _constants.backgroundColor,
        appBar: AppBar(
          backgroundColor: _constants.appbarBackgroundColor,
          automaticallyImplyLeading: false,
          title: Text(
            'PROFILE',
            style: TextStyle(fontFamily: 'Montserrat', letterSpacing: 1.4),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Scrollbar(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    height: screensize.height * 0.15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              Provider.of<Data>(context).user.photoURL,
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                Provider.of<Data>(context)
                                        .user
                                        .displayName
                                        .toUpperCase() ??
                                    'User Name',
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 22)),
                            Text(
                                Provider.of<Data>(context).user.email ??
                                    'User Email',
                                style: TextStyle(fontFamily: 'Montserrat')),
                            Text(
                                Provider.of<Data>(context).phoneNumber ??
                                    'Phone Number',
                                style: TextStyle(fontFamily: 'Montserrat')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue[800],
                      ),
                      child: FlatButton(
                        onPressed: _onSignOut,
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
