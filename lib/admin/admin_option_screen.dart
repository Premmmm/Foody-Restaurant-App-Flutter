import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/admin/ordersScreen.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';

class AdminOptionScreen extends StatefulWidget {
  @override
  _AdminOptionScreenState createState() => _AdminOptionScreenState();
}

class _AdminOptionScreenState extends State<AdminOptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
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
                        onPressed: () {
                          Navigator.push(context, MySlide(builder: (context){
                            return OrdersScreen();
                          }));
                        },
                        child: Text('View Orders',style: TextStyle(color:Colors.white, fontFamily: 'Montserrat'),)),
                  ),
                ),
                SizedBox(height: 20,),
                Center(
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue[800],
                    ),
                    child: FlatButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Provider.of<Data>(context, listen: false)
                              .setEveryThingToNull();
                          Navigator.push(context,
                              MySlide(builder: (context) {
                                return LoginScreen();
                              }));
                        },
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat'),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
