
import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/root_page.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RootPage(auth: Auth(),),
    );
  }
}