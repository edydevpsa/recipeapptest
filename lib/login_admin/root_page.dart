import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/menu_page.dart';
import 'package:recipesapp/login_admin/sliders_page.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  RootPage({this.auth}); //Constructor

  //@override   QUE PASARA si activamos el 'override'
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus{notSignIn, signIn} //creamos variables con enum

class _RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignIn;

  @override
  void initState() {
    widget.auth.currentUser().then((value){
      setState(() {
        print(value);
        _authStatus = value == 'no_login' ? AuthStatus.notSignIn : AuthStatus.signIn;
      });
    });
    super.initState();
  }

  // ignore: unused_element
  void _signIn(){
    setState(() {
      _authStatus = AuthStatus.signIn;
    });
  }

  // ignore: unused_element
  void _signOut(){
    setState(() {
      _authStatus = AuthStatus.notSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget _widget;

    switch (_authStatus) {
      //Aqui si esta loggeado le lleva ala HomePage caso contrario le lleva al login mas registro
      case AuthStatus.notSignIn:
        return IntroScreen(auth: widget.auth, onSignIn: _signIn,);
        break;
      case AuthStatus.signIn:
        return HomePage(auth: widget.auth, onSignedOut: _signOut,);  
      break;
    }
    return _widget;
  }
}