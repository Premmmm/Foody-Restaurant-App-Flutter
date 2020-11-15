import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final name;
  final phoneNumber;
  final address;
  final order;
  final addons;
  final email;

  OrderDetailsScreen(
      {this.name,
      this.email,
      this.addons,
      this.address,
      this.phoneNumber,
      this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onPressed: () {},
                        color: Colors.red,
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              Text('Decline',
                                  style:
                                      TextStyle(fontSize: 18, color: Colors.white)),
                              SizedBox(width: 5,),
                              Icon(Icons.clear,color: Colors.white,size: 22,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onPressed: () {},
                        color: Colors.green[600],
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Accept',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 5,),
                              Icon(Icons.check,color: Colors.white,size: 22,)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
