import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/cart_screen.dart';
import 'package:restaurant_app/screens/main_menu_screen.dart';

class TopScreen extends StatefulWidget {
  @override
  _TopScreenState createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  PageController pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
        onPageChanged: (index) {},
        children: <Widget>[
          MainMenuScreen(),
          CartScreen(),
        ],
      ),
    );
  }
}

//class TopScreen extends StatefulWidget {
//  @override
//  _TopScreenState createState() => _TopScreenState();
//}
//
//class _TopScreenState extends State<TopScreen> {
//  int currentPage = 0;
//  int currentBotNavIndex = 0;
//  bool ok = true;
//
//  PageController _pageController;
//
//  @override
//  void initState() {
//    super.initState();
//    _pageController = PageController();
//  }
//
//  @override
//  void dispose() {
//    _pageController.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Colors.indigo,
//        automaticallyImplyLeading: false,
//        actions: <Widget>[
//          IconButton(
//            icon: Image.asset(
//              'images/shopping-cart-fill.png',
//              color: Colors.white,
//            ),
//            onPressed: () {
//              Navigator.push(context, MySlide(builder: (context){
//                return CartScreen();
//              }));
//            },
//          ),
//          IconButton(
//              icon: Image.asset(
//                'images/user-3-fill.png',
//                color: Colors.white,
//              ),
//              onPressed: () {
//                Navigator.push(context, MySlide(builder: (context){
//                  return AccountScreen();
//                }));
//              }),
//        ],
//        title: FlatButton(
//          onPressed: () {},
//          child: Row(
//            children: <Widget>[
//              Icon(
//                Icons.location_on,
//                size: 25,
//                color: Colors.white,
//              ),
//              SizedBox(
//                width: 5,
//              ),
//              Text(
//                Provider.of<Data>(context).currentLocation != null
//                    ? Provider.of<Data>(context).currentLocation
//                    : 'Set Location',
//                style: TextStyle(fontSize: 15, color: Colors.white),
//              ),
//            ],
//          ),
//        ),
//      ),
//      body: SafeArea(
//        child: Stack(
//          children: <Widget>[
//            PageView(
//              controller: _pageController,
//              onPageChanged: (index) {
//                setState(() {
//                  if (ok) {
//                    if (currentBotNavIndex != index) {
//                      currentBotNavIndex = index;
//                    }
//                  }
//                });
//                setState(() {
//                  ok = true;
//                });
//              },
//              children: <Widget>[
//                MainMenuScreen(),
//                CartScreen(),
//                AccountScreen(),
//              ],
//            ),
//            Positioned(
//              bottom: 0,
//              left: 0,
//              right: 0,
//              child: Hero(
//                tag: 'bottomNavBar',
//                child: Container(
//                  height: 60,
//                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.circular(10),
//                    color: Colors.indigo,
//                  ),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      IconButton(
//                          icon: Image.asset(
//                            currentBotNavIndex == 0
//                                ? 'images/home-2-fill.png'
//                                : 'images/home-2-line.png',
//                            color: Colors.white,
//                          ),
//                          iconSize: 30,
//                          onPressed: () {
//                            if (currentBotNavIndex != 0)
//                              _pageController.animateToPage(0,
//                                  duration: Duration(milliseconds: 250),
//                                  curve: Curves.bounceInOut);
//                          }),
//                      IconButton(
//                          icon: Image.asset(
//                            currentBotNavIndex == 1
//                                ? 'images/shopping-cart-fill.png'
//                                : 'images/shopping-cart-line.png',
//                            color: Colors.white,
//                          ),
//                          onPressed: () {
//                            if (currentBotNavIndex != 1)
//                              _pageController.animateToPage(1,
//                                  duration: Duration(milliseconds: 250),
//                                  curve: Curves.bounceInOut);
//                          }),
//                      IconButton(
//                          icon: Image.asset(
//                            currentBotNavIndex == 2
//                                ? 'images/user-3-fill.png'
//                                : 'images/user-3-line.png',
//                            color: Colors.white,
//                          ),
//                          onPressed: () {
//                            if (currentBotNavIndex != 2)
//                              _pageController.animateToPage(2,
//                                  duration: Duration(milliseconds: 250),
//                                  curve: Curves.bounceInOut);
//                          }),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}

//      bottomNavigationBar: CurvedNavigationBar(
//        height: 65,
//        backgroundColor: Colors.transparent,
//        color: Colors.indigo,
//        animationCurve: Curves.easeInOutExpo,
//        index: currentBotNavIndex,
//        animationDuration: Duration(milliseconds: 250),
//        items: <Widget>[
//          Image.asset(
//            currentBotNavIndex == 0
//                ? 'images/home-2-fill.png'
//                : 'images/home-2-line.png',
//            color: Colors.white,
//          ),
//          Image.asset(
//            currentBotNavIndex == 1
//                ? 'images/shopping-cart-fill.png'
//                : 'images/shopping-cart-line.png',
//            color: Colors.white,
//          ),
//          Image.asset(
//            currentBotNavIndex == 2
//                ? 'images/user-3-fill.png'
//                : 'images/user-3-line.png',
//            color: Colors.white,
//          ),
//        ],
//        onTap: (index) {
//          setState(() {
//            currentBotNavIndex=index;
//            ok=false;
//          });
//          _pageController.animateToPage(index,
//              duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
//        },
//      ),
