import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/admin/acceptedOrdersScreen.dart';
import 'package:restaurant_app/admin/ordersScreen.dart';
import 'package:restaurant_app/components/AlertDialogCustom.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAdminScreen extends StatefulWidget {
  @override
  _AllAdminScreenState createState() => _AllAdminScreenState();
}

class _AllAdminScreenState extends State<AllAdminScreen> {
  PageController pageController =
      PageController(initialPage: 0, keepPage: true);
  bool acceptingOrders = false;
  String title = 'Orders';

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance
        .reference()
        .child('acceptingOrders')
        .once()
        .then((DataSnapshot data) {
      if (data.value != null) {
        if (data.value.toString() == 'yes') {
          Provider.of<Data>(context, listen: false).setAcceptingOrders(true);
          setState(() {
            acceptingOrders = true;
          });
        } else {
          setState(() {
            acceptingOrders = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return AlertDialogCustom().onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF13161D),
          title: Text(
            title,
            style: GoogleFonts.montserrat(),
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.grey[900],
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  curve: Curves.bounceOut,
                  duration: Duration(seconds: 1),
                  decoration: BoxDecoration(color: Color(0xFF13161D)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FOODY ADMIN',
                        style: GoogleFonts.montserrat(
                            fontSize: 25, fontWeight: FontWeight.w700),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey[850],
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ACCEPT ORDERS'),
                              Switch(
                                activeTrackColor: Colors.white,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                                inactiveTrackColor: Colors.white,
                                value: acceptingOrders,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    acceptingOrders = value;
                                  });
                                  Provider.of<Data>(context, listen: false)
                                      .setAcceptingOrders(value);
                                  acceptingOrders
                                      ? FirebaseDatabase.instance
                                          .reference()
                                          .update({
                                          'acceptingOrders': 'yes'
                                        }).then((value) => print('Done daw'))
                                      : FirebaseDatabase.instance
                                          .reference()
                                          .update({'acceptingOrders': 'no'});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                ListTile(
                  leading: Icon(Icons.menu),
                  title: Text(
                    'ORDERS',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    pageController.jumpToPage(0);
                    setState(() {
                      title = 'Orders';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.grading),
                  title: Text(
                    'ACCEPTED ORDERS',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    pageController.jumpToPage(1);
                    setState(() {
                      title = 'Accepted Orders';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app_outlined),
                  title: Text(
                    'SIGN OUT',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () async {
                    GoogleSignIn().signOut();
                    var _pref = await SharedPreferences.getInstance();
                    _pref.remove('foodyUserEmail');
                    Provider.of<Data>(context, listen: false)
                        .setEveryThingToNull();
                    Navigator.push(
                      context,
                      MySlide(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: PageView(
          controller: pageController,
          physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
          onPageChanged: (index) {},
          children: <Widget>[
            OrdersScreen(),
            AcceptedOrdersScreen(),
          ],
        ),
      ),
    );
  }
}
