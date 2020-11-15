import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/login_credentials/loading_screen.dart';
import 'components/data.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Data>(
      create: (context) => Data(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(accentColor: Colors.white),
        home: LoadingScreen(),
      ),
    );
  }
}
