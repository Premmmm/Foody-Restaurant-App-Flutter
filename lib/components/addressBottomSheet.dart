import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreDatabase = FirebaseFirestore.instance;

class AddressBottomSheet extends StatefulWidget {
  @override
  _AddressBottomSheetState createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  bool islocationSpinning = false;
  bool isSaveSpinning = false;
  bool addressView = false, numberView = false;
  String address = '', number = '';

  @override
  void initState() {
    super.initState();
    getOldAddressAndNumber();
  }

  void getOldAddressAndNumber() {
    String oldAddress = Provider.of<Data>(context, listen: false).address;
    String oldNumber = Provider.of<Data>(context, listen: false).phoneNumber;
    print('$oldAddress $oldNumber');
    if (oldAddress != 'null' && oldNumber != 'null') {
      setState(() {
        address = oldAddress;
        number = oldNumber;
      });
    }
  }

  void getAddress() async {
    setState(() {
      islocationSpinning = true;
    });
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    print(position.latitude);
    print(position.longitude);
    final coordinates = Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print(addresses);
    var first = addresses.first;
    // first.addressLine;
    setState(() {
      addressView = false;
      numberView = false;
      address = first.addressLine;
      islocationSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      height: MediaQuery.of(context).size.height - 250,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit Details',
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your address',
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Vibration.vibrate(duration: 20);
                    getAddress();
                  },
                  child: islocationSpinning
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 20,
                              color: Colors.redAccent[400],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Get address',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                )
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  numberView = false;
                  addressView = true;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 5, bottom: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.white)),
                child: addressView
                    ? TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                addressView = false;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                      )
                    : Text(
                        address,
                        style: GoogleFonts.montserrat(),
                      ),
              ),
            ),
            Text(
              'Your mobile number',
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  addressView = false;
                  numberView = true;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 15, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.white)),
                child: numberView
                    ? TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                numberView = false;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            number = value;
                          });
                        },
                      )
                    : Text(
                        number,
                        style: GoogleFonts.montserrat(),
                      ),
              ),
            ),
            Divider(
              thickness: 3,
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                autofocus: true,
                onPressed: () async {
                  setState(() {
                    isSaveSpinning = true;
                  });
                  Vibration.vibrate(duration: 15);
                  if (address != '' && number != '') {
                    Provider.of<Data>(context, listen: false)
                        .setAddress(address);
                    Provider.of<Data>(context, listen: false)
                        .setPhoneNumber(number);
                    await firestoreDatabase
                        .collection(
                            Provider.of<Data>(context, listen: false).userEmail)
                        .doc('contactCredentials')
                        .update({'address': address, 'mobileNumber': number});
                    setState(() {
                      isSaveSpinning = false;
                    });
                    Navigator.pop(context);
                  } else if (address == '') {
                    setState(() {
                      isSaveSpinning = false;
                    });
                  } else if (number == '') {
                    setState(() {
                      isSaveSpinning = false;
                    });
                  } else {
                    setState(() {
                      isSaveSpinning = false;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: isSaveSpinning
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text(
                          'Save and Proceed',
                          style: GoogleFonts.montserrat(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
