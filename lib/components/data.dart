import 'package:flutter/cupertino.dart';
import 'package:restaurant_app/components/details.dart';
import 'package:restaurant_app/components/items.dart';

class Data extends ChangeNotifier {
  String userEmail;
  String currentLocation;
  String userName;
  String address;
  String phoneNumber;
  int primaryIndex = 0;
  int secondaryIndex = 0;
  bool orderLive = false;
  List<String> categories;
  String photoUrl;
  bool cartEmpty = true;
  bool acceptingOrders = false;
  List<Items> selectedItems = [];
  List<CategoriesAndDetails> categoriesAndDetails = [];

  void setAcceptingOrders(bool status) {
    acceptingOrders = status;
    notifyListeners();
  }

  void setOrderLive(bool isLive) {
    orderLive = isLive;
    notifyListeners();
  }

  void setIndexes(int priIndex, int secIndex) {
    primaryIndex = priIndex;
    secondaryIndex = secIndex;
  }

  void setCategoriesAndDetails(List<CategoriesAndDetails> _c) {
    categoriesAndDetails = _c;
    notifyListeners();
  }

  void setCategories(List<String> _categories) {
    categories = _categories;
    notifyListeners();
  }

  void setCartEmpty() {
    cartEmpty = true;
    notifyListeners();
  }

  void setCartFull() {
    cartEmpty = false;
    notifyListeners();
  }

  void setPhotoUrl(String _url) {
    photoUrl = _url;
    notifyListeners();
  }

  void setUserEmail(String _email) {
    userEmail = _email;
    notifyListeners();
  }

  void setAddress(String _newAddress) {
    address = _newAddress;
    notifyListeners();
  }

  void setCurrentLocation(String _location) {
    currentLocation = _location;
    notifyListeners();
  }

  void setPhoneNumber(String _num) {
    phoneNumber = _num;
    notifyListeners();
  }

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void addItemToCart(
      String name, double cost, int count, String url, String type) {
    print(name);
    print(cost);
    selectedItems.add(Items(
      name: name,
      cost: cost * count,
      count: count,
      url: url,
      type: type,
    ));
    notifyListeners();
  }

  void updateItemFromCart(
      String name, double cost, String url, int count, int index, String type) {
    selectedItems[index] = Items(
        name: name, cost: cost * count, count: count, url: url, type: type);

    notifyListeners();
  }

  void removeItemFromCart(String name) {
    if (selectedItems.length != 0) {
      for (var i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i].name == name) {
          selectedItems.removeAt(i);
          notifyListeners();
          break;
        }
      }
    }
    if (selectedItems.length == 0) {
      setCartEmpty();
    }
  }

  void setOrderToNull() {
    selectedItems = [];
    cartEmpty = true;
    notifyListeners();
  }

  void setEveryThingToNull() {
    userEmail = null;
    address = null;
    phoneNumber = null;
    cartEmpty = true;
    userName = null;
    categories = [];
    photoUrl = null;
    selectedItems = [];
    notifyListeners();
  }
}
