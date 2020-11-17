import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/components/data.dart';

final firestore = FirebaseFirestore.instance;
final Color containerColor = Color(0xFF161616);

class AcceptedOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Data>(context).acceptingOrders) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Scrollbar(
            child: Center(
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  border: Border.all(width: 2.5, color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Currently Not Accepting Orders',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else
      return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Scrollbar(
            child: _CurrentOrderStream(),
          ),
        ),
      );
  }
}

class _CurrentOrderStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    String date = "${now.day}-${now.month}-${now.year}";
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('orders')
          .doc(date)
          .collection('orders')
          .where('status',
              whereIn: ['accepted', 'cooking', 'outForDelivery']).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        List<_CurrentOrderCard> currentOrderCardWidget = [];
        final messages = snapshot.data.docs;
        for (var i in messages) {
          String _orderString = i['order'].toString().replaceAll('[', '');
          String _countString = i['count'].toString().replaceAll('[', '');

          _countString = _countString.toString().replaceAll(']', '');
          _orderString = _orderString.toString().replaceAll(']', '');

          List orderList = _orderString.split(',');
          List countList = _countString.split(',');
          String order = '';
          for (int j = 1; j <= countList.length; j++) {
            if (j != countList.length) {
              order = order + countList[j - 1] + 'x ' + orderList[j - 1] + ', ';
            } else {
              order = order + countList[j - 1] + 'x' + orderList[j - 1];
            }
          }

          currentOrderCardWidget.add(_CurrentOrderCard(
            name: i['name'],
            address: i['deliveryAddress'],
            email: i['email'],
            order: order,
            mobileNumber: i['mobileNumber'],
            date: date,
            docID: i.id,
            status: i['status'],
          ));
        }
        return ListView(
          children: currentOrderCardWidget,
        );
      },
    );
  }
}

class _CurrentOrderCard extends StatelessWidget {
  final name;
  final mobileNumber;
  final address;
  final order;
  final email;
  final count;
  final date;
  final docID;
  final status;
  _CurrentOrderCard(
      {this.name,
      this.order,
      this.mobileNumber,
      this.address,
      this.email,
      this.count,
      this.date,
      this.docID,
      this.status});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: containerColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  'Order',
                  style: GoogleFonts.montserrat(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(order, style: GoogleFonts.montserrat(fontSize: 12)),
            SizedBox(height: 10),
            Text('Delivery Details',
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Address',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(address, style: GoogleFonts.montserrat(fontSize: 12)),
            SizedBox(height: 5),
            Text('Phone number',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(mobileNumber, style: GoogleFonts.montserrat(fontSize: 12)),
            SizedBox(height: 15),
            Divider(thickness: 2),
            SizedBox(height: 5),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith((states) => Colors.red),
                ),
                onPressed: status != 'delivered'
                    ? () {
                        String st;
                        if (status == 'accepted')
                          st = 'cooking';
                        else if (status == 'cooking')
                          st = 'outForDelivery';
                        else if (status == 'outForDelivery') st = 'delivered';
                        firestore
                            .collection('orders')
                            .doc(date)
                            .collection('orders')
                            .doc(docID)
                            .update({'status': st});
                        firestore
                            .collection(email)
                            .doc('currentOrder')
                            .update({st: 'yes'});
                      }
                    : null,
                child: Text('Update Status'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
