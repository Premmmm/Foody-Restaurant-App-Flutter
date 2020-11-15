// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:restaurant_app/components/items.dart';
// import 'data_provider_restaurant_app.dart';
// import 'package:vibration/vibration.dart';

// List<Items> selectedItems = [];


// class BuildBottomSheet extends StatefulWidget {
//   final name;
//   final double cost;
//   final addons;
//   final count;
//   BuildBottomSheet({this.name, this.cost, this.addons, this.count});
//   @override
//   _BuildBottomSheetState createState() => _BuildBottomSheetState();
// }

// class _BuildBottomSheetState extends State<BuildBottomSheet> {
//   bool cheeseValue = false;
//   bool mayoValue = false;
//   List addOns = [];
//   double extrasCost = 0.0;
//   int count = 1;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       if (widget.addons != null && widget.addons.length != 0) {
//         for (var i in widget.addons) {
//           if (i == 'Mayo') {
//             mayoValue = true;
//             extrasCost = extrasCost + 2;
//             addOns.add('Mayo');
//           }
//           if (i == 'Cheese') {
//             extrasCost = extrasCost + 1;
//             cheeseValue = true;
//             addOns.add('Cheese');
//           }
//         }
//       }
//       if (widget.count != null || count != 0) {
//         count = widget.count;
//       }
//     });
//   }

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

//   void addItemToCart() {
//     List<Items> k = Provider.of<Data>(context, listen: false).selectedItems;
//     if (k.length == 0) {
//       Provider.of<Data>(context, listen: false)
//           .addItemToCart(widget.name, widget.cost, extrasCost, count, addOns);
//       Provider.of<Data>(context, listen: false).setCartFull();
//       Navigator.pop(context);
//       showToast('Item added to cart');
//     } else {
//       int c = 0;
//       for (int i = 0; i < k.length; i++) {
//         if (k[i].name == widget.name) {
//           Provider.of<Data>(context, listen: false).updateItemFromCart(
//               widget.name, widget.cost, extrasCost, count, addOns, i);
//           Navigator.pop(context);

//           showToast('Item added to cart');
//         } else {
//           c = c + 1;
//         }
//       }
//       if (c == k.length) {
//         Provider.of<Data>(context, listen: false)
//             .addItemToCart(widget.name, widget.cost, extrasCost, count, addOns);
//         Provider.of<Data>(context, listen: false).setCartFull();
//         Navigator.pop(context);
//         showToast('Item added to cart');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Expanded(
//             child: Stack(
//               children: <Widget>[
//                 ListView(
//                   children: <Widget>[
//                     Container(
//                       decoration: BoxDecoration(
//                           color: Colors.blue[100],
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(25.0),
//                               topRight: Radius.circular(25.0))),
//                       padding: EdgeInsets.only(left: 15),
//                       height: 70,
//                       child: Center(
//                           child: Text(
//                         widget.name,
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 15, left: 15),
//                       child: Text(
//                         'Extras',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('Cheese'),
//                       leading: Checkbox(
//                           activeColor: Colors.green[500],
//                           value: cheeseValue,
//                           onChanged: (value) {
//                             setState(() {
//                               cheeseValue = value;
//                               if (value == true) {
//                                 if (addOns.contains('Cheese') == false) {
//                                   addOns.add('Cheese');
//                                 }
//                                 extrasCost = extrasCost + 1;
//                               } else if (value == false) {
//                                 addOns.remove('Cheese');
//                                 extrasCost = extrasCost - 1;
//                               }
//                               print(extrasCost);
//                             });
//                           }),
//                       subtitle:
//                           Text('${String.fromCharCodes(Runes('\u0024'))}1'),
//                     ),
//                     ListTile(
//                       title: Text('Mayo'),
//                       leading: Checkbox(
//                           activeColor: Colors.green[500],
//                           value: mayoValue,
//                           onChanged: (value) {
//                             setState(() {
//                               mayoValue = value;
//                               if (value == true) {
//                                 if (addOns.contains('Mayo') == false) {
//                                   addOns.add('Mayo');
//                                 }
//                                 extrasCost = extrasCost + 2;
//                               } else if (value == false) {
//                                 addOns.remove('Mayo');
//                                 extrasCost = extrasCost - 2;
//                               }
//                               print(extrasCost);
//                             });
//                           }),
//                       subtitle:
//                           Text('${String.fromCharCodes(Runes('\u0024'))}2'),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   bottom: 100,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       height: 55,
//                       width: 115,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey, width: 3),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           GestureDetector(
//                             child: Image.asset(
//                               'images/subtract.png',
//                               color: Colors.green,
//                               width: 30,height: 30,
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 Vibration.vibrate(duration: 20);
//                                 if (count != 1) {
//                                   count = count - 1;
//                                 }
//                               });

//                               print('minus');
//                             },
//                           ),
//                           Text(
//                             '$count',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           GestureDetector(
//                             child: Image.asset(
//                               'images/add-line.png',
//                               color: Colors.green,
//                               width: 30,height: 30,
//                             ),
//                             onTap: () {
//                               Vibration.vibrate(duration: 25);
//                               setState(() {
//                                 count = count + 1;
//                               });

//                               print('plus');
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       height: 80,
//                       width: MediaQuery.of(context).size.width - 80,
//                       margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.green[500],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: FlatButton(
//                         onPressed: () {
//                           Vibration.vibrate(duration: 25);
//                           if (count != 0) {
//                             print('adding item');
//                             addItemToCart();
//                           }
//                         },
//                         child: Center(
//                           child: Text(
//                             'Place Order',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //
// //Widget buildBottomSheet(String name,double cost) {
// //  return AnimatedContainer(
// //    duration: Duration(milliseconds: 400),
// //    curve: Curves.bounceIn,
// //    height: 350.0,
// //    color: Colors.transparent,
// //    child: Container(
// //        decoration: BoxDecoration(
// //            color: Colors.white,
// //            borderRadius: BorderRadius.only(
// //                topLeft: const Radius.circular(10.0),
// //                topRight: const Radius.circular(10.0))),
// //        child: Stack(
// //          children: <Widget>[
// //            ListView(
// //              children: <Widget>[
// //                Container(
// //                  padding: EdgeInsets.only(left: 15),
// //                  height: 70,
// //                  color: Colors.blue[100],
// //                  child: Center(
// //                      child: Text(
// //                        name,
// //                        style: TextStyle(fontWeight: FontWeight.bold),
// //                      )),
// //                ),
// //                Padding(
// //                  padding: const EdgeInsets.only(top: 15, left: 15),
// //                  child: Text(
// //                    'Extras',
// //                    style:
// //                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
// //                  ),
// //                ),
// //                ListTile(
// //                  title: Text('Cheese'),
// //                  leading: Checkbox(value: cheeseValue, onChanged: (value) {
// //
// //                  }),
// //                  subtitle: Text('${String.fromCharCodes(Runes('\u0024'))}1'),
// //                ),
// //                ListTile(
// //                  title: Text('Mayo'),
// //                  leading: Checkbox(value: true, onChanged: (value) {}),
// //                  subtitle: Text('${String.fromCharCodes(Runes('\u0024'))}2'),
// //                ),
// //              ],
// //            ),
// //            Positioned(
// //              bottom: 0,
// //              left: 0,
// //              right: 0,
// //              child: Container(
// //                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
// //                decoration: BoxDecoration(
// //                  borderRadius: BorderRadius.circular(10),
// //                  color: Colors.green[500],
// //                ),
// //                child: FlatButton(
// //                    onPressed: () {
// //
// //                    },
// //                    child: Text(
// //                      'Add Item to Cart',
// //                      style: TextStyle(
// //                          color: Colors.white, fontWeight: FontWeight.bold),
// //                    )),
// //              ),
// //            )
// //          ],
// //        )),
// //  );
// //}
