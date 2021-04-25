import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/menu_page.dart';
import 'package:recipesapp/model/user_model.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignIn;

  LoginPage({this.auth, this.onSignIn}); //Constructor

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType{login, registro}
enum SelectSource{camara, galeria} //servira para hacer acceder ala camara y galeria

class _LoginPageState extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  //declaramos los variables
  String _email;
  String _password;
  String _nombre;
  String _telefono;
  String _itemCiudad;
  String _direccion;
  String _urlFoto = '';
  String usuario;
  bool _obscureText = true;
  FormType _formType = FormType.login;
  List<DropdownMenuItem<String>> _ciudaditem ;//lista de ciudades desde Firestore

  @override
  void initState() {
    setState(() {
      _ciudaditem = getCiudadItems();
      _itemCiudad = _ciudaditem[0].value;
    });
    super.initState();
  }

  getData()async{
    return await Firestore.instance.collection('ciudades').getDocuments();
  }

  //DropdownList desde Firestore
  List<DropdownMenuItem<String>>getCiudadItems(){
    List<DropdownMenuItem<String>>items = List();
    QuerySnapshot dataCiudades;
    getData().then((data){
      dataCiudades = data;
      dataCiudades.documents.forEach((element) {print('${element.documentID} ${element['nombre']}');
        items.add(DropdownMenuItem(
          value: element.documentID,
          child: Text(element['nombre']),
        ));
      });
    }).catchError((error) => print('hay error '+ error));

    items.add(DropdownMenuItem(
      value: '0',
      child: Text('- selecciones -'),
    ));
    
    return items;
  }

  bool _validarGuardar(){
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //crearemos un metodo para validar y enviar...
  Future<void>_validarEnviar() async{
    if (_validarGuardar()){
      try {
        String userId = await widget.auth.signInEmailPassword(_email, _password);
        print('usuario logueado: $userId');
        widget.onSignIn();
        HomePage(auth: widget.auth,);//menu_page.dart la clase homepage(auth, onSignedOut);
        Navigator.pop(context);
      } catch (e) {
        print('error...$e'); //Mira instanciando invocamos a AlertDialog() y showDialog()
        AlertDialog alerta = new AlertDialog(
          content: Text('Error en la Autenticacion'),
          title: Text('Error'),
          actions: <Widget>[],
        );
        showDialog(context: context, child: alerta);
      }
    }
  }

  //ahora creamos un metodo para validar y registrar
  void _validarRegistrar() async{
    if (_validarGuardar()) {
      try {
        Usuario usuario = Usuario( //model/user:model.dart
          nombre: _nombre,
          ciudad: _itemCiudad,
          direccion: _direccion,
          email: _email,
          password: _password,
          telefono: _telefono,
          foto: _urlFoto,
        );
        String userId = await widget.auth.signUpEmailPassword(usuario);
        print('Usuario loggeado: $userId');
        widget.onSignIn();
        HomePage(auth: widget.auth,); //menu_page.dart/ class HomePage()
        Navigator.pop(context);
      } catch (e) {
        print('Error...$e');
        AlertDialog alerta = new AlertDialog(
          content: Text('Error en el registro'),
          title: Text('Error'),
          actions: <Widget>[],
        );
        showDialog(context: context, child: alerta);
      }
    }
  }

  //Metodo para ir al registro
  void _irRegistro(){
    setState(() {
      formKey.currentState.reset();
      _formType = FormType.registro;
    });
  }
  //Metodo para ir al Login
  void _irLogin(){
    setState(() {
      formKey.currentState.reset();
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Text(
                    'Recetas Mundiales \n Mis recetas', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17.0),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 15.0,)),
                ] + buildInputs() + 
                buildSubmitButtons()
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [ //q nos retorne una Lista o Array
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            icon: Icon(Icons.email),
          ),
          validator: (value) => value.isEmpty ? 'El campo email esta vacio' : null,
          onSaved: (value) => _email = value.trim(),
        ),
        Padding(padding:EdgeInsets.all(8.0) ),
        TextFormField(
          keyboardType: TextInputType.text,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            icon: Icon(Icons.vpn_key),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText =  !_obscureText;
                });
              },
              child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: (value) => value.isEmpty 
          ? 'El campo esta vacio debe tener\nalmenos 6 caracteres' : null,
          onSaved: (value) => _password = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
      ];
    } else {
      return [
        Row(mainAxisAlignment: MainAxisAlignment.center,),
        Text('Registro de usuario', style: TextStyle(color: Colors.black),),
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Nombre', 
            icon: Icon(Icons.account_circle),
          ),
          validator: (value) => value.isEmpty ? 'Nombre esta vacio' : null,
          onSaved: (value) => _nombre = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        TextFormField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Celular',
            icon: Icon(Icons.phone),
          ),
          validator: (value) => value.isEmpty ? 'El campo telefono esta vacio' : null,
          onSaved: (value) => _telefono = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        DropdownButtonFormField(
          validator: (value) => value == '0' ? 'debe seleccionar una ciudad' : null,
          decoration: InputDecoration(
            labelText: 'Ciudad',
            icon: Icon(Icons.location_on),
          ),
          value: _itemCiudad,
          items: _ciudaditem, 
          onChanged: (value){
            setState(() {
              _itemCiudad = value;
            });
          },//seleccionar ciudadItem
          onSaved: (value) => _itemCiudad = value,
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Direccion',
            icon: Icon(Icons.person_pin),
          ),
          validator: (value) => value.isEmpty ? 'El campo Dirccion esta vacio' : null,
          onSaved: (value) => _direccion = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: ' Email',
            icon: Icon(Icons.alternate_email),
          ),
          validator: (value) => value.isEmpty ? 'El campo email esta vacio' : null,
          onSaved: (value) => _email = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        TextFormField(
          obscureText: _obscureText, //password
          decoration: InputDecoration(
            labelText: 'contraseña',
            icon: Icon(Icons.vpn_key, color: Colors.blue),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = ! _obscureText;
                });
              },
              child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: (value) => value.isEmpty 
          ? 'El campo password debe tener\nal menos 6 caracteres' : null,
          onSaved: (value) => _password = value.trim(),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          onPressed: _validarEnviar, //Atencion aqui
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Ingresar', style: TextStyle(color: Colors.white, fontSize: 15.0),),
              Padding(padding: EdgeInsets.only(left: 10.0)),
              Icon(Icons.check_circle, color: Colors.white,),
            ],
          ),
          color: Colors.orangeAccent,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          elevation: 8.0,
        ),
        FlatButton(
          onPressed:_irRegistro, 
          child: Text('Crear cuenta', style: TextStyle(fontSize: 20.0, color: Colors.grey)),
        ),
      ];
    } else {
      return [
        RaisedButton(
          onPressed: _validarRegistrar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Registrar cuenta', style: TextStyle(color: Colors.white, fontSize: 15.0),),
              Padding(padding: EdgeInsets.only(left: 10.0)),
              Icon(Icons.add_circle, color: Colors.white,),
            ],
          ),
          color: Colors.orangeAccent,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          elevation: 8.0,
        ),
        FlatButton(
          onPressed: _irLogin, 
          child: Text('ya tienes una cuenta?', style: TextStyle(fontSize: 20.0, color: Colors.grey),),
        ),
      ];
    }
  }
}