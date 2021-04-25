import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/login_page.dart';

class IntroScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignIn;

  IntroScreen({this.auth, this.onSignIn}) ;
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

enum AuthStatus{notSignIn, signIn} //aqui tbn creamos variables con enum

class _IntroScreenState extends State<IntroScreen> {

  // ignore: unused_field
  AuthStatus _authStatus = AuthStatus.notSignIn;
  List<Slide>slides = new List();

  @override
  void initState() {
    widget.auth.currentUser().then((value){
      setState(() {
        print(value);
        _authStatus = value == 'no_login'? AuthStatus.notSignIn : AuthStatus.signIn;
      });
    });

    //one Page Slide
    slides.add(
      Slide(
        title: 'Ingredientes',
        maxLineTitle: 2,
        styleTitle: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w500),
        description: 'Crea tus propias recetas',
        styleDescription: TextStyle(color: Colors.white, fontSize: 20.0, ),
        marginDescription: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
        centerWidget: Text('Deslice para ir a la siguiente pantalla',),
        backgroundImage: 'assets/images/huevos.gif',
        onCenterItemPress: (){},
      ),
    );
    //two page
    slides.add(
      Slide(
        title: 'Recetas Mundiales',
        styleTitle: TextStyle(color: Colors.blueAccent, fontSize: 30.0, fontWeight: FontWeight.w500),
        description: 'Waffles, Postres, Tortas, comida Thailandesa, Arabe, Peruana, Mexicana y mas ',
        styleDescription: TextStyle(color: Colors.white, fontSize: 20.0,),
        backgroundImage: 'assets/images/azucar.gif',

      ),
    );
    //three page
    slides.add(
      Slide(
        title: 'Receta pizza Italiana',
        styleTitle: TextStyle(color: Colors.blueAccent, fontSize: 30.0, fontWeight: FontWeight.w500),
        description: 'Ordena todo antes de iniciar la preparacion, vamos adelante',
        styleDescription: TextStyle(color: Colors.white, fontSize: 20.0,),
        backgroundImage: 'assets/images/pizzacaliente.gif',
        maxLineTextDescription: 3,
      ),
    );
    super.initState();
  }

  void oneDonePress(){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => LoginPage(auth: widget.auth, onSignIn: widget.onSignIn),
    )
    );
  }
  //botones de Navegacion
  Widget renderNextBtn(){
    return Icon(Icons.navigate_next, color: Colors.white, size: 35.0,);
  }

  Widget renderDoneBtn(){
    return Icon(Icons.done, color: Colors.white,);
  }

  Widget renderSkipBtn(){
    return Icon(Icons.skip_next, color: Colors.white,);
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,

      //skip buttom
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: Colors.orangeAccent,
      highlightColorSkipBtn: Color(0xFF000000),

      //Next buttom
      renderNextBtn: this.renderNextBtn(),

      //Done buttom
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.oneDonePress,
      colorDoneBtn: Colors.blueAccent,
      highlightColorDoneBtn: Color(0xFF69303),

      //Dot indicator
      colorDot: Colors.white,
      colorActiveDot: Colors.orangeAccent,
      sizeDot: 13.0,

      //Show or hide status bar
      shouldHideStatusBar: true,
      backgroundColorAllSlides: Colors.grey,
    );
  }
}