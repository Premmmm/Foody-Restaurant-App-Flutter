import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/components/details.dart';
import 'package:restaurant_app/components/items.dart';

class ViewItemScreen extends StatefulWidget {
  @override
  _ViewItemScreenState createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    checkItemCount();
  }

  void checkItemCount() {
    var provider = Provider.of<Data>(context, listen: false);
    final int primaryIndex = provider.primaryIndex;
    final int secondaryIndex = provider.secondaryIndex;
    final item =
        provider.categoriesAndDetails[primaryIndex].details[secondaryIndex];
    List<Items> _selectedItems = provider.selectedItems;
    if (_selectedItems.length != 0) {
      for (int i = 0; i < _selectedItems.length; i++) {
        if (_selectedItems[i].name == item.name) {
          setState(() {
            itemCount = _selectedItems[i].count;
          });
          break;
        }
      }
    }
  }

  void addItemsToCart(Details _item, int _count) {
    List<Items> k = Provider.of<Data>(context, listen: false).selectedItems;

    if (_count == 0) {
      Provider.of<Data>(context, listen: false).removeItemFromCart(_item.name);
    } else {
      if (k.length == 0) {
        Provider.of<Data>(context, listen: false).addItemToCart(_item.name,
            double.parse(_item.price), _count, _item.url, _item.type);
        Provider.of<Data>(context, listen: false).setCartFull();
      } else {
        int c = 0;
        for (int i = 0; i < k.length; i++) {
          if (k[i].name == _item.name) {
            Provider.of<Data>(context, listen: false).updateItemFromCart(
                _item.name,
                double.parse(_item.price),
                _item.url,
                _count,
                i,
                _item.type);
          } else {
            c = c + 1;
          }
        }
        if (c == k.length) {
          Provider.of<Data>(context, listen: false).addItemToCart(_item.name,
              double.parse(_item.price), _count, _item.url, _item.type);
          Provider.of<Data>(context, listen: false).setCartFull();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<Data>(context, listen: false);
    final int primaryIndex = provider.primaryIndex;
    final int secondaryIndex = provider.secondaryIndex;
    final item =
        provider.categoriesAndDetails[primaryIndex].details[secondaryIndex];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF13161D),
      body: Stack(
        children: [
          _BackgroundColorContainer(),
          Positioned(
            top: height * 0.06,
            left: width * 0.07,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.55,
                  child: Hero(
                    tag: item.name,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        item.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Hero(
                      tag: '${item.name}rating',
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: RatingBar(
                          initialRating: double.parse(item.rating),
                          minRating: 1,
                          itemSize: 20,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          glowRadius: 0.0,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 10,
                          ),
                          onRatingUpdate: null,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Hero(
                      tag: '${item.name}ratingvalue',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          '${item.rating}',
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.063,
            right: 20,
            child: Hero(
              tag: '${item.name}${item.type}',
              child: Image.asset(
                'images/${item.type}.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          Positioned(
            top: height * 0.13,
            left: width * 0.36,
            child: Hero(
              tag: item.url,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: Colors.indigo[300],
                    width: 4.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(item.url),
                  radius: 120,
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.45,
            left: 30,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INGREDIENTS',
                    style: GoogleFonts.montserrat(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: width - 60,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(item.ingredients,
                          style: GoogleFonts.montserrat(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: height * 0.55,
            left: 30,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TYPE',
                    style: GoogleFonts.montserrat(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          item.type.toUpperCase(),
                          style: GoogleFonts.montserrat(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'images/${item.type}.png',
                        width: 25,
                        height: 25,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: height * 0.65,
            left: 30,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COST',
                    style: GoogleFonts.montserrat(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: width - 60,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        '\$ ${item.price}',
                        style: GoogleFonts.montserrat(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: width * 0.30,
            right: width * 0.30,
            child: Container(
              width: width * 0.25,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (itemCount != 0) {
                          itemCount -= 1;
                          addItemsToCart(item, itemCount);
                        }
                      });
                    },
                    child: Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  Text('$itemCount'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        itemCount += 1;
                        addItemsToCart(item, itemCount);
                      });
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )

          // Positioned(
          //     bottom: 5,
          //     left: 259,
          //     right: 14,
          //     child: Card(
          //       elevation: 10,
          //       child: Stack(
          //         children: <Widget>[
          //           Center(
          //             child: Container(
          //                 height: 36,
          //                 width: 100,
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //                 child: FlatButton(
          //                   onPressed: () {
          //                     List<Items> k =
          //                         Provider.of<Data>(context, listen: false)
          //                             .selectedItems;
          //                     if (k.length == 0) {
          //                       print('null daw');
          //                       showModalBottomSheet(
          //                           isDismissible: false,
          //                           enableDrag: false,
          //                           shape: CircleBorder(),
          //                           context: context,
          //                           builder: (builder) {
          //                             return BuildBottomSheet(
          //                               name: widget.name,
          //                               cost: double.parse(widget.price),
          //                               count: 1,
          //                             );
          //                           });
          //                     } else {
          //                       print('not null daw');
          //                       int c = 0;
          //                       for (int i = 0; i < k.length; i++) {
          //                         if (k[i].name == widget.name) {
          //                           showModalBottomSheet(
          //                             shape: CircleBorder(),
          //                             context: context,
          //                             builder: (builder) {
          //                               return BuildBottomSheet(
          //                                 name: widget.name,
          //                                 cost: double.parse(widget.price),
          //                                 addons: k[i].addOns,
          //                                 count: k[i].count,
          //                               );
          //                             },
          //                           );
          //                         } else {
          //                           c = c + 1;
          //                           if (c == k.length) {
          //                             showModalBottomSheet(
          //                                 shape: CircleBorder(),
          //                                 context: context,
          //                                 builder: (builder) {
          //                                   return BuildBottomSheet(
          //                                     name: widget.name,
          //                                     cost: double.parse(widget.price),
          //                                     count: 1,
          //                                   );
          //                                 });
          //                           }
          //                         }
          //                       }
          //                     }
          //                   },
          //                   color: Colors.white,
          //                   child: Center(
          //                     child: Text(
          //                       'ADD',
          //                       style: TextStyle(
          //                         color: Colors.green,
          //                         fontSize: 15,
          //                         fontWeight: FontWeight.bold,
          //                         fontFamily: 'Montserrat',
          //                       ),
          //                     ),
          //                   ),
          //                 )),
          //           ),
          //           Positioned(
          //             top: 0,
          //             left: 93,
          //             right: 10,
          //             child: Text(
          //               '+',
          //               style: TextStyle(
          //                   fontSize: 14,
          //                   color: Colors.green,
          //                   fontFamily: 'Montserrat'),
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }
}

class _BackgroundColorContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height * 0.75,
        decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(70))),
      ),
    );
  }
}
