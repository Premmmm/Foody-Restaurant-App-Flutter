import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoder/geocoder.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/MySlide.dart';
import 'package:restaurant_app/components/NotificationCheck.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:restaurant_app/screens/cart_screen.dart';
import 'package:restaurant_app/screens/account_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:restaurant_app/components/details.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/screens/viewitemscreen.dart';

final _firebasedb = FirebaseDatabase.instance.reference();
final _firestoredb = FirebaseFirestore.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool isSpinning = false, locationSpinning = false;
  ScrollController _scrollController = ScrollController();
  double orderContainerHeight = -80;
  TextStyle googleFonts;

  @override
  void initState() {
    super.initState();
    googleFonts = GoogleFonts.montserrat();
    print(Provider.of<Data>(context, listen: false).user.email);
    _firebaseMessaging.getToken().then(
          (value) => {
            print('Firebase Messaging token: $value'),
            _firestoredb
                .collection(
                    Provider.of<Data>(context, listen: false).user.email)
                .doc('userToken')
                .set({
                  'token': value.toString(),
                })
                .then((value) => print('Successfully set user token'))
                .catchError(
                    (e) => print('Error happened while setting token $e'))
          },
        );
    checkCurrentOrder();
    getLocation();
    getCategoriesAndDetails();
  }

  Future<void> checkCurrentOrder() async {
    await _firestoredb
        .collection((Provider.of<Data>(context, listen: false).user.email))
        .doc('currentOrder')
        .get()
        .then((value) {
      if (value.exists) {
        Provider.of<Data>(context, listen: false).setOrderLive(true);
      }
    });
  }

  void getLocation() async {
    setState(() {
      locationSpinning = true;
    });
    try {
      Position position = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      print(position.latitude);
      print(position.longitude);
      final coordinates = Coordinates(position.latitude, position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      if (first.locality != null && first.adminArea != null) {
        if (first.subLocality != null) {
          Provider.of<Data>(context, listen: false).setCurrentLocation(
              first.subLocality.toString() + ', ' + first.locality);
        } else {
          Provider.of<Data>(context, listen: false).setCurrentLocation(
              first.locality.toString() + ', ' + first.adminArea);
        }
      }
    } catch (e) {
      print('Get Location error : $e');
    }
    setState(() {
      locationSpinning = false;
    });
  }

  Future<void> getCategoriesAndDetails() async {
    List<String> _categories = [];
    List<String> _name = [];
    List<String> _price = [];
    List<String> _url = [];
    List<String> _type = [];
    List<String> _ingredients = [];
    List<String> _rating = [];
    List<String> _reviewers = [];
    List<CategoriesAndDetails> _categoriesAndDetails = [];
    List<Details> _details = [];
    int count = 0;
    await _firebasedb.child('categories').once().then(
      (snapshot) {
        if (snapshot.value != null) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach(
            (key, value) {
              _categories.add(value.toString());
            },
          );
        }
      },
    );
    String _tempString = _categories[1];
    _categories[1] = _categories[2];
    _categories[2] = _tempString;

    Provider.of<Data>(context, listen: false).setCategories(_categories);

    await _firebasedb.child('itemList').once().then(
      (snapshot) {
        if (snapshot.value != null) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach(
            (key, value) {
              if (key.toString() != 'Drinks' && key.toString() != 'Breads') {
                Map<dynamic, dynamic> values = value;
                values.forEach(
                  (key1, value1) {
                    if (key1.toString() == 'price') {
                      count += 1;
                      _price.add(value1.toString());
                    } else if (key1.toString() == 'type') {
                      _type.add(value1.toString());
                    } else if (key1.toString() == 'url') {
                      _url.add(value1.toString());
                    } else if (key1.toString() == 'ingredients') {
                      _ingredients.add(value1.toString());
                    } else if (key1.toString() == 'name') {
                      _name.add(value1.toString());
                    } else if (key1.toString() == 'rating') {
                      _rating.add(value1.toString());
                    } else if (key1.toString() == 'reviewers') {
                      _reviewers.add(value1.toString());
                    }
                  },
                );
              }
            },
          );
        }
      },
    );

    for (int i = 0; i < count; i++) {
      _details.add(Details(
        name: _name[i],
        url: _url[i],
        ingredients: _ingredients[i],
        type: _type[i],
        price: _price[i],
        rating: _rating[i],
        reviewers: _reviewers[i],
      ));
    }
    count = 0;
    _categoriesAndDetails.add(CategoriesAndDetails(
      category: 'Pizza',
      details: _details,
    ));

    for (String category in _categories) {
      _categories = [];
      _name = [];
      _price = [];
      _url = [];
      _type = [];
      _ingredients = [];
      _rating = [];
      _details = [];
      _reviewers = [];
      if (category != 'Pizza') {
        await _firebasedb
            .child('itemList')
            .child(category.toString())
            .once()
            .then(
          (snapshot) {
            if (snapshot.value != null) {
              Map<dynamic, dynamic> values = snapshot.value;
              values.forEach(
                (key, valuee) {
                  Map<dynamic, dynamic> val = valuee;
                  val.forEach(
                    (key, value) {
                      if (key.toString() == 'price') {
                        _price.add(value.toString());
                      } else if (key.toString() == 'type') {
                        _type.add(value.toString());
                      } else if (key.toString() == 'url') {
                        _url.add(value.toString());
                      } else if (key.toString() == 'ingredients') {
                        _ingredients.add(value.toString());
                      } else if (key.toString() == 'name') {
                        count += 1;
                        _name.add(value.toString());
                      } else if (key.toString() == 'rating') {
                        _rating.add(value.toString());
                      } else if (key.toString() == 'reviewers') {
                        _reviewers.add(value.toString());
                      }
                    },
                  );
                },
              );
            }
          },
        );

        for (int i = 0; i < count; i++) {
          _details.add(
            Details(
                name: _name[i],
                url: _url[i],
                ingredients: _ingredients.length != 0 ? _ingredients[i] : '',
                type: _type[i],
                price: _price[i],
                rating: _rating[i],
                reviewers: _reviewers[i]),
          );
        }
        count = 0;
        _categoriesAndDetails.add(CategoriesAndDetails(
          category: category.toString(),
          details: _details,
        ));
      }
    }
    Provider.of<Data>(context, listen: false)
        .setCategoriesAndDetails(_categoriesAndDetails);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        orderContainerHeight = 0;
      });
    });
  }

  void scrollTo(double value) {
    _scrollController.animateTo(value,
        duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
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
          backgroundColor: Color(0xAA121212),
          appBar: AppBar(
            backgroundColor: Color(0xFF13161D),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              NotificationCheck(),
              IconButton(
                icon: Image.asset(
                  Provider.of<Data>(context).orderLive
                      ? 'images/plate.png'
                      : Provider.of<Data>(context).cartEmpty
                          ? 'images/shopping-cart-line.png'
                          : 'images/shopping-cart-fill.png',
                  width: Provider.of<Data>(context).orderLive ? 25 : null,
                  height: Provider.of<Data>(context).orderLive ? 25 : null,
                  color: Provider.of<Data>(context).orderLive
                      ? null
                      : Colors.white,
                ),
                onPressed: () {
                  if (!Provider.of<Data>(context, listen: false).orderLive) {
                    Navigator.push(context, MySlide(builder: (context) {
                      return CartScreen();
                    }));
                  } else {
                    if (orderContainerHeight != 0)
                      setState(() {
                        orderContainerHeight = 0;
                      });
                  }
                },
              ),
              SizedBox(width: 5),
              IconButton(
                highlightColor: Colors.transparent,
                icon: Image.asset(
                  'images/user-3-fill.png',
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(context, MySlide(builder: (context) {
                    return AccountScreen();
                  }));
                },
              ),
              SizedBox(width: 5)
            ],
            title: TextButton(
              onPressed: () {
                getLocation();
              },
              child: locationSpinning
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Text(
                      Provider.of<Data>(context).currentLocation != null
                          ? Provider.of<Data>(context).currentLocation
                          : 'Set Location',
                      style: GoogleFonts.montserrat(
                          fontSize: 15, color: Colors.white),
                    ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Provider.of<Data>(context).categoriesAndDetails.length != 0
                        ? _CategoriesAndItems()
                        : Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              Visibility(
                visible: Provider.of<Data>(context).orderLive,
                child: AnimatedPositioned(
                  duration: Duration(milliseconds: 700),
                  bottom: orderContainerHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.grey[600],
                    child: _OrderStatusStream(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<Data>(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoredb
          .collection(provider.user.email)
          .doc('currentOrder')
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        String _currentStatusmessage;
        bool _ordered = false;
        bool _accepted = false;
        bool _cooking = false;
        bool _outForDelivery = false;
        bool _delivered = false;

        var data = snapshot.data.data();
        Map<String, dynamic> values = data;
        values.forEach((key, value) {
          if (key.toString() == 'ordered') if (value.toString() == 'yes') {
            print('ordered');
            _ordered = true;
          }
          if (key.toString() == 'accepted') if (value.toString() == 'yes') {
            print('accepted');
            _accepted = true;
          }
          if (key.toString() == 'cooking') if (value.toString() == 'yes') {
            print('cooking');
            _cooking = true;
          }
          if (key.toString() == 'outForDelivery') if (value.toString() ==
              'yes') {
            print('outfordelivery');
            _outForDelivery = true;
          }
          if (key.toString() == 'delivered') if (value.toString() == 'yes') {
            Provider.of<Data>(context, listen: false).setOrderLive(false);
            _delivered = true;
            _firestoredb
                .collection(provider.user.email)
                .doc('currentOrder')
                .delete();
          }
        });

        if (_ordered) {
          _currentStatusmessage =
              'Waiting for restaurant to confirm your order !';

          if (_accepted) {
            _currentStatusmessage = 'Restaurant has accepted your order.';

            if (_cooking) {
              _currentStatusmessage = 'Your delicious food is cooking !';
            }
            if (_outForDelivery) {
              _currentStatusmessage =
                  'Your food is out for delivery and will reach your soon !';
            }
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _delivered
                    ? Image.asset('assets/images/delivered.jpg')
                    : _outForDelivery
                        ? Image.asset('assets/images/delivery.jpg')
                        : _cooking
                            ? Image.asset('assets/images/cooking.jpg')
                            : _accepted
                                ? Image.asset('assets/images/accepted.jpg')
                                : _ordered
                                    ? Image.asset('assets/images/ordered.jpg')
                                    : null,

                // _currentStatus == 'ordered'
                //     ? Image.asset('assets/images/ordered.jpg')
                //     : _currentStatus == 'accepted'
                //         ? Image.asset('assets/images/accepted.jpg')
                //         : _currentStatus == 'cooking'
                //             ? Image.asset('assets/images/cooking.jpg')
                //             : _currentStatus == 'outForDelivery'
                //                 ? Image.asset('assets/images/delivery.jpg')
                //                 : null,
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Text(_currentStatusmessage,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 16)),
              ),
            )
          ],
        );
      },
    );
  }
}

class _CategoriesAndItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> _cat = Provider.of<Data>(context).categories;
    return Column(
      children: [
        for (int i = 0; i < _cat.length; i++)
          _CategoriesContainerWidget(category: _cat[i], index: i),
      ],
    );
  }
}

class _CategoriesContainerWidget extends StatelessWidget {
  final String category;
  final int index;
  _CategoriesContainerWidget({this.category, this.index});
  @override
  Widget build(BuildContext context) {
    List<CategoriesAndDetails> _categoriesAndDetails =
        Provider.of<Data>(context).categoriesAndDetails;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                category,
                style: GoogleFonts.montserrat(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int j = 0;
                      j < _categoriesAndDetails[index].details.length;
                      j++)
                    _ItemContainerWidget(
                      item: _categoriesAndDetails[index].details[j],
                      primaryIndex: index,
                      secondaryIndex: j,
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ItemContainerWidget extends StatelessWidget {
  final Details item;
  final primaryIndex;
  final secondaryIndex;
  _ItemContainerWidget({this.item, this.primaryIndex, this.secondaryIndex});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.7,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: item.url,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: height * 0.22,
                width: width * 0.7,
                child: Image.network(
                  '${item.url}',
                  fit: item.name == 'Drinks' ? BoxFit.cover : BoxFit.fitWidth,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Hero(
                tag: item.name,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    item.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Hero(
                tag: '${item.name}${item.type}',
                child: Image.asset(
                  'images/${item.type}.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            item.ingredients,
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Hero(
                tag: '${item.name}rating',
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: RatingBar(
                    initialRating: double.parse(item.rating),
                    minRating: 1.0,
                    itemSize: 20,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    glow: false,
                    itemCount: 5,
                    glowRadius: 0.0,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 10,
                    ),
                    onRatingUpdate: (l) {},
                  ),
                ),
              ),
              Hero(
                tag: '${item.name}ratingvalue',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '${double.parse(item.rating)}',
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ),
              Text(
                '   ( ${item.reviewers} )',
              ),
              Spacer(),
              Stack(
                children: [
                  SizedBox(
                    width: 100,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<Data>(context, listen: false)
                            .setIndexes(primaryIndex, secondaryIndex);
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page: ViewItemScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'ADD',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: 3,
                    child: Text(
                      '+',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//  floatingActionButton: Container(
//               margin: EdgeInsets.symmetric(vertical: 20),
//               width: 120.0,
//               height: 55.0,
//               child: new RawMaterialButton(
//                 fillColor: Colors.blue[700],
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 elevation: 0.0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Image.asset(
//                       'images/fork.png',
//                       color: Colors.white,
//                       scale: 2.2,
//                     ),
//                     SizedBox(
//                       width: 6,
//                     ),
//                     Text(
//                       'Menu',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold),
//                     )
//                   ],
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     popUpMenuVisibility = popUpMenuVisibility ? false : true;
//                   });
//                 },
//               )),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,

// class ItemContainer extends StatefulWidget {
//   final image;
//   final name;
//   final String price;
//   final String ingredients;
//   final context1;

//   ItemContainer(
//       {this.image, this.price, this.ingredients, this.name, this.context1});

//   @override
//   _ItemContainerState createState() => _ItemContainerState();
// }

// class _ItemContainerState extends State<ItemContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Card(
//         elevation: 10,
//         child: Stack(
//           children: <Widget>[
//             Container(
//               height: 150,
//               padding: EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 5),
//                     width: 150,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Image.asset(
//                           'images/veg.png',
//                           scale: 2.5,
//                         ),
//                         Text(
//                           widget.name,
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 25,
//                           ),
//                         ),
//                         Text(
//                           '${String.fromCharCodes(Runes('\u0024'))}${widget.price}',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 20,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           child: Text(
//                             widget.ingredients,
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       padding: EdgeInsets.only(right: 20),
//                       height: 110,
//                       width: 130,
//                       decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage(widget.image),
//                               fit: BoxFit.cover)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
// Positioned(
//   bottom: 5,
//   left: 259,
//   right: 14,
//   child: Card(
//     elevation: 10,
//     child: Stack(
//       children: <Widget>[
//         Center(
//           child: Container(
//               height: 36,
//               width: 100,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: FlatButton(
//                 onPressed: () {
//                   List<Items> k =
//                       Provider.of<Data>(context, listen: false)
//                           .selectedItems;
//                   if (k.length == 0) {
//                     print('null daw');
//                     showModalBottomSheet(
//                         isDismissible: false,
//                         enableDrag: false,
//                         shape: CircleBorder(),
//                         context: context,
//                         builder: (builder) {
//                           return BuildBottomSheet(
//                             name: widget.name,
//                             cost: double.parse(widget.price),
//                             count: 1,
//                           );
//                         });
//                   } else {
//                     print('not null daw');
//                     int c = 0;
//                     for (int i = 0; i < k.length; i++) {
//                       if (k[i].name == widget.name) {
//                         showModalBottomSheet(
//                           shape: CircleBorder(),
//                           context: context,
//                           builder: (builder) {
//                             return BuildBottomSheet(
//                               name: widget.name,
//                               cost: double.parse(widget.price),
//                               addons: k[i].addOns,
//                               count: k[i].count,
//                             );
//                           },
//                         );
//                       } else {
//                         c = c + 1;
//                         if (c == k.length) {
//                           showModalBottomSheet(
//                               shape: CircleBorder(),
//                               context: context,
//                               builder: (builder) {
//                                 return BuildBottomSheet(
//                                   name: widget.name,
//                                   cost: double.parse(widget.price),
//                                   count: 1,
//                                 );
//                               });
//                         }
//                       }
//                     }
//                   }
//                 },
//                 color: Colors.white,
//                 child: Center(
//                   child: Text(
//                     'ADD',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Montserrat',
//                     ),
//                   ),
//                 ),
//               )),
//         ),
//         Positioned(
//           top: 0,
//           left: 93,
//           right: 10,
//           child: Text(
//             '+',
//             style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.green,
//                 fontFamily: 'Montserrat'),
//           ),
//         )
//       ],
//     ),
//   ),
// )
//           ],
//         ),
//       ),
//     );
//   }
// }

//              Positioned(
//                bottom: 0,
//                left: 0,
//                right: 0,
//                child: Hero(
//                  tag:'bottomNavBar',
//                  child: Container(
//                    height: 70,
//                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(10),
//                      color: Colors.indigo,
//                    ),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceAround,
//                      children: <Widget>[
//                        IconButton(
//                            icon: Image.asset(
//                              'images/home-2-fill.png',
//                              color: Colors.white,
//                            ),
//                            iconSize: 30,
//                            onPressed: () {}),
//                        IconButton(
//                            icon: Image.asset(
//                              'images/shopping-cart-line.png',
//                              color: Colors.white,
//                            ),
//                            onPressed: () {
//                              Navigator.push(
//                                  context, MaterialPageRoute(builder: (context){
//                                    return CartScreen();
//                              }));
//                            }),
//                        IconButton(
//                            icon: Image.asset(
//                              'images/user-3-line.png',
//                              color: Colors.white,
//                            ),
//                            onPressed: () {
//                              Navigator.push(
//                                  context, MaterialPageRoute(builder: (context){
//                                return AccountScreen();
//                              }));
//                            }),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
