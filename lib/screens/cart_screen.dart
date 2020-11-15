import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/addressBottomSheet.dart';
import 'package:restaurant_app/components/data.dart';
import 'package:restaurant_app/components/items.dart';
import 'package:restaurant_app/login_credentials/login_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';

final _firestoredb = FirebaseFirestore.instance;

final Color containerColor = Color(0xFF161616);
final Color itemContainerColor = Color(0xAA161616);

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

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<OrderCard> orders = [];
  List<bool> isVisible = [];
  double itemTotal = 0.0;
  double deliveryCharge = 20.0;
  double tax = 25.0;
  double toPay = 0.0;
  bool isSpinning = false, isOrdering = false;
  double orderContainerLength = 0.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSpinning = true;
    });
    getCustomerDetails();
    getItems();
  }

  Future<void> getCustomerDetails() async {
    List parentNames = [];

    _firestoredb
        .collection(Provider.of<Data>(context, listen: false).userEmail)
        .doc('contactCredentials')
        .get()
        .then(
      (DocumentSnapshot snapshot) {
        if (snapshot.data() != null) {
          Map<dynamic, dynamic> values = snapshot.data();
          values.forEach((key, value1) {
            parentNames.add(key.toString());
            if (key.toString() == 'mobileNumber') {
              Provider.of<Data>(context, listen: false)
                  .setPhoneNumber(value1.toString());
            } else if (key.toString() == 'name') {
              Provider.of<Data>(context, listen: false)
                  .setUserName(value1.toString());
            }
          });
          if (parentNames.contains('address')) {
            values.forEach((key, value2) {
              if (key.toString() == 'address') {
                Provider.of<Data>(context, listen: false)
                    .setAddress(value2.toString());
              }
            });
          } else {
            print('no address daww');
          }
        }
      },
    );
  }

  void getItems() {
    List<Items> k = Provider.of<Data>(context, listen: false).selectedItems;
    if (k.length != 0) {
      for (int i = 0; i < k.length; i++) {
        itemTotal = itemTotal + k[i].cost;
        orders.add(OrderCard(
          name: k[i].name,
          cost: k[i].cost,
          count: k[i].count,
          url: k[i].url,
          type: k[i].type,
        ));
      }

      setPricing(
        itemtotal: itemTotal,
        deliverycharge: deliveryCharge,
        taxx: tax,
      );

      setState(() {
        orderContainerLength = orders.length * 95.toDouble();
        isVisible = List.filled(orders.length, true);
        orders = orders;
      });
    }
    setState(() {
      isSpinning = false;
    });
  }

  void setPricing({double itemtotal, double deliverycharge, double taxx}) {
    setState(() {
      itemTotal = itemtotal;
      toPay = itemtotal + deliverycharge + taxx;
    });
  }

  Future<void> setOrder() async {
    setState(() {
      isOrdering = true;
    });
    List<String> _itemName = [];
    List<String> _itemCount = [];
    List<String> _itemType = [];
    List<String> _itemUrl = [];
    var provider = Provider.of<Data>(context, listen: false);

    DateTime now = new DateTime.now();
    String date = "${now.day}-${now.month}-${now.year}";
    List<Items> _items = provider.selectedItems;
    for (int i = 0; i < _items.length; i++) {
      _itemName.add(_items[i].name);
      _itemCount.add(_items[i].count.toString());
      _itemType.add(_items[i].type);
      _itemUrl.add(_items[i].url);
    }

    await _firestoredb
        .collection('orders')
        .doc('$date')
        .collection('orders')
        .doc()
        .set({
          'email': provider.userEmail.toString(),
          'order': '$_itemName',
          'time': DateTime.now().toString(),
          'count': '$_itemCount',
          'type': '$_itemType',
          'url': '$_itemUrl',
          'total': '$toPay',
          'name': provider.userName,
          'mobileNumber': provider.phoneNumber,
          'deliveryAddress': provider.address,
          'status': 'waiting'
        })
        .then((value) => print('Order Set Successfully'))
        .catchError((error) => print('Ordering error $error'));
    await _firestoredb.collection(provider.userEmail).doc('currentOrder').set({
      'ordered': 'yes',
      'accepted': 'not yet',
      'cooking': 'not yet',
      'outForDelivery': 'not yet',
      'delivered': 'not yet',
    });
    provider.setOrderLive(true);
    provider.setOrderToNull();
    setState(() {
      isOrdering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Data>(context).orderLive) {
      return Scaffold(
        backgroundColor: Color(0xAA121212),
        appBar: AppBar(
          elevation: 10,
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF13161D),
          title: Row(
            children: <Widget>[
              Text(
                'Order Status',
                style: GoogleFonts.montserrat(fontSize: 25),
              ),
              SizedBox(
                width: 13,
              ),
              Image.asset(
                'images/plate.png',
                width: 28,
                height: 28,
              ),
            ],
          ),
        ),
        body: _OrderUpdateStream(),
      );
    } else {
      if (Provider.of<Data>(context).cartEmpty ||
          orders.length == null ||
          orders.length == 0) {
        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            elevation: 10,
            backgroundColor: Color(0xFF13161D),
            automaticallyImplyLeading: false,
            title: Row(
              children: <Widget>[
                Text(
                  'Your Cart',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  width: 10,
                ),
                Image.asset(
                  Provider.of<Data>(context).cartEmpty
                      ? 'images/shopping-cart-line.png'
                      : 'images/shopping-cart-fill.png',
                  color: Colors.white,
                ),
              ],
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  'Good food is always cooking',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Colors.white30)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Your cart is empty',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                      ),
                      Image.asset(
                        'images/shopping-cart-line.png',
                        color: Colors.white,
                        // scale: 1.2,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Color(0xAA121212),
          appBar: AppBar(
            elevation: 10,
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFF13161D),
            title: Row(
              children: <Widget>[
                Text(
                  'Your Cart',
                  style: GoogleFonts.montserrat(fontSize: 25),
                ),
                SizedBox(
                  width: 10,
                ),
                Image.asset(
                  Provider.of<Data>(context).cartEmpty
                      ? 'images/shopping-cart-line.png'
                      : 'images/shopping-cart-fill.png',
                  color: Colors.white,
                ),
              ],
            ),
          ),
          body: ModalProgressHUD(
            inAsyncCall: isSpinning,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: <Widget>[
                  ListView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: containerColor,
                        ),
                        constraints:
                            BoxConstraints.expand(height: orderContainerLength),
                        child: Center(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(
                                parent: NeverScrollableScrollPhysics()),
                            itemBuilder: (context, index) {
                              return Visibility(
                                visible: isVisible[index],
                                child: Stack(
                                  children: <Widget>[
                                    orders[index],
                                    Positioned(
                                      top: 8,
                                      left: MediaQuery.of(context).size.width -
                                          70,
                                      right: 2,
                                      child: GestureDetector(
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            orderContainerLength =
                                                orderContainerLength - 95;
                                          });
                                          Provider.of<Data>(context,
                                                  listen: false)
                                              .removeItemFromCart(
                                                  orders[index].name);

                                          setPricing(
                                              itemtotal: (itemTotal -
                                                  orders[index].cost),
                                              deliverycharge: deliveryCharge,
                                              taxx: tax);
                                          setState(() {
                                            isVisible[index] = false;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            itemCount: orders.length,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: containerColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                'Bill Details',
                                style: GoogleFonts.montserrat(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Item Total'),
                                  Text(
                                      '${String.fromCharCodes(Runes('\u0024'))} $itemTotal')
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Delivery Fee',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                  Text(
                                      '${String.fromCharCodes(Runes('\u0024'))} $deliveryCharge')
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Taxes and charges',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                  Text(
                                      '${String.fromCharCodes(Runes('\u0024'))} $tax')
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'To Pay',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '${String.fromCharCodes(Runes('\u0024'))} $toPay',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: containerColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery details',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Vibration.vibrate(duration: 20);
                                      showModalBottomSheet(
                                        enableDrag: true,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (builder) {
                                          return AddressBottomSheet();
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 15),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Address',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                child: Text(
                                  Provider.of<Data>(context).address != 'null'
                                      ? Provider.of<Data>(context).address
                                      : '',
                                  style: GoogleFonts.montserrat(fontSize: 12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 2,
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Phone No',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                  Provider.of<Data>(context).phoneNumber ==
                                          'null'
                                      ? ''
                                      : Provider.of<Data>(context).phoneNumber,
                                  style: GoogleFonts.montserrat(fontSize: 12)),
                            ),
                            Visibility(
                              visible:
                                  Provider.of<Data>(context).address == null
                                      ? true
                                      : false,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: FlatButton(
                                  onPressed: () {
                                    Vibration.vibrate(duration: 20);
                                    showModalBottomSheet(
                                        enableDrag: true,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (builder) {
                                          return AddressBottomSheet();
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.add),
                                      Text(
                                        'Add Address',
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 90,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          String _addressP =
                              Provider.of<Data>(context, listen: false).address;
                          String _numberP =
                              Provider.of<Data>(context, listen: false)
                                  .phoneNumber;
                          if (_addressP != '' &&
                              _numberP != '' &&
                              _addressP != null &&
                              _numberP != null) {
                            setOrder();
                          }
                        },
                        child: Center(
                          child: isOrdering
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Text(
                                  'PLACE  ORDER',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}

class _OrderUpdateStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<Data>(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: fireStoreDataBase
          .collection(provider.userEmail)
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

        String ordered;
        String accepted;
        String cooking;
        String outForDelivery;
        String delivered;

        var data = snapshot.data.data();
        Map<String, dynamic> values = data;
        values.forEach((key, value) {
          if (key.toString() == 'ordered')
            ordered = value.toString();
          else if (key.toString() == 'cooking')
            cooking = value.toString();
          else if (key.toString() == 'accepted')
            accepted = value.toString();
          else if (key.toString() == 'outForDelivery')
            outForDelivery = value.toString();
          else if (key.toString() == 'delivered') delivered = value.toString();
        });

        if (delivered == 'yes') {
          Provider.of<Data>(context, listen: false).setOrderLive(false);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 15,
                  ),
                ),
                title: Text(
                  'Ordered',
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: accepted == 'yes'
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 15,
                        )
                      : null,
                ),
                title: Text(
                  accepted == 'yes'
                      ? 'Accepted'
                      : 'Waiting for restaurant to accept your order',
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: cooking == 'yes'
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 15,
                        )
                      : null,
                ),
                title: Text(
                  cooking == 'yes'
                      ? 'Yur food is ready'
                      : accepted == 'yes'
                          ? 'Your delicious food is cooking'
                          : '',
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: outForDelivery == 'yes'
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 15,
                        )
                      : null,
                ),
                title: Text(
                  outForDelivery == 'yes' ? 'OUT FOR DELIVERY' : '',
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final name;
  final cost;
  final count;
  final type;
  final String url;

  OrderCard({this.name, this.cost, this.count, this.url, this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 10,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              height: 80,
              color: itemContainerColor,
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(url,
                            fit: BoxFit.cover, width: 55, height: 55),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Image.asset(
                                'images/$type.png',
                                scale: 3,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  '$name ',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 10),
                            child: Text(
                              'No: $count',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: MediaQuery.of(context).size.width * 0.05,
              child: Text(
                '${String.fromCharCodes(Runes('\u0024'))} $cost',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
