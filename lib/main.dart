import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_complete_guide/utils/notifications_api.dart';
import './screens/signin_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(),
    );
  }
}
