import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/login_page.dart';

class CommonThings {
  static Size size; //Size Screen
}

class MyAddPage extends StatefulWidget {
  final String id;
  MyAddPage({this.id}); //Constructor

  @override
  _MyAddPageState createState() => _MyAddPageState();
}

class _MyAddPageState extends State<MyAddPage> {
  //declarando variables...
  File _foto;
  String urlFoto;
  bool _isInAsyncCall = false;
  String recipes;
  Auth auth = Auth();

  TextEditingController recipeInputController;
  TextEditingController nameInputController;
  TextEditingController imageInputController;

  String id;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  String name;
  String uid;
  String recipe;

  //Creando un metodo que obtiene la imagen desde la galeria o de la camara

  final imagePicker = new ImagePicker();

  Future captureImage(SelectSource opcion)async{
     //File image;
    //PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.camera);

   /* opcion == SelectSource.camara 
    ? _image = (await picker.getImage(source: ImageSource.camera)) as File
    : _image = (await picker.getImage(source: ImageSource.gallery)) as File;*/
    //
    //
    // Aqui el codigo para Acceder ala camara y ala Galeria esta depreciado tener CUIDADO
    //si nos da EEROR DEBEMOS solucionar pero con GIDHUB  y StackOverflow
    File image;

    opcion == SelectSource.camara
        ? image = await ImagePicker.pickImage(source: ImageSource.camera)
        : image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _foto = image;
    });

    /*opcion == SelectSource.camara
    ? pickedFile = await imagePicker.getImage(source: ImageSource.camera)
    : pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    setState(() {
      //_foto = File(pickedFile.path);
      
    });*/
  }

  getImage(){

    AlertDialog alerta = new AlertDialog(
      content: Text('Selecione de donde desea carturar la imagen'),
      title: Text('Selccionar imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            captureImage(SelectSource.camara);
            Navigator.of(context, rootNavigator: true).pop();
          }, 
          child: Row(
            children: <Widget>[
              Text('camara',),
              Icon(Icons.camera_alt),
            ],
          ),
        ),
        FlatButton(
          onPressed: (){
            //seleccion = SelectSource.galeria
            captureImage(SelectSource.galeria);
            Navigator.of(context, rootNavigator: true).pop();
          }, 
          child: Row(
            children: <Widget>[
              Text('Galeria'),
              Icon(Icons.image),
            ],
          ),
        ),
      ],
    );
    showDialog(context: context, child: alerta);
  }
  //creamos un metodo de divider
  Widget divider(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Container(
        width: 0.8,
        color:  Colors.black54,
      ),
    );
  }
  //creamos un metodo para hacer las validaciones con validator
  bool _validarlo(){
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //now create a method send and create recipe in cloud Firestore
  void _enviar(){
    if (_validarlo()) {
      setState(() {
        _isInAsyncCall = true;
      });
      auth.currentUser().then((value) {
        setState(() {
          uid = value;
        });
        if (_foto != null) {
          final StorageReference  fireStoreRef = FirebaseStorage.instance
          .ref()
          .child('colrecipes')
          .child(uid)
          .child('uid')
          .child('recipe')
          .child('$name.jpg');
          
          final StorageUploadTask task = fireStoreRef.putFile(
            _foto, StorageMetadata(contentType: 'image/jpeg')
          );
          task.onComplete.then((value){
            value.ref.getDownloadURL().then((value){
              setState(() {
                urlFoto =  value.toString();
                Firestore.instance.collection('colrecipes').add({
                  'uid'  : uid,
                  'name' : name,
                  'image': urlFoto,
                  'recipe': recipe,
                }).then((value) => Navigator.pop(context)).catchError(
                  (onError) => print('Error al registrar usuario en la bd')
                );
                _isInAsyncCall = false;
              });
            });
          });
        }else{
          Firestore.instance.collection('colrecipes').add({
            'uid'    :uid,
            'name'   :name,
            'image'  :urlFoto,
            'recipe' : recipe,
          }).then((value) => Navigator.pop(context)).catchError(
            (onError) => print('Error al registrar usuario en la bd')
          );
          _isInAsyncCall = false;
        }
      }).catchError((onError) => _isInAsyncCall = false);
      //
    }else{
      print('objeto no valido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Page'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall, 
        opacity: 0.5,
        dismissible: false,
        progressIndicator: CircularProgressIndicator(),
        color: Colors.blueGrey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left:10.0, right:15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        onTap: getImage,
                      ),
                      margin: EdgeInsets.only(top: 20.0),
                      height: 120.0,
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.black),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image:AssetImage('assets/images/azucar.gif') 
                        ),
                        /*_foto == null 
                        ? Image.asset('assets/images/azucar.gif')
                        : FileImage(_foto),*/

                      ),
                    ),
                  ],
                ),
                Text('Click para cambiar foto'),
                Padding(padding: EdgeInsets.only(top:10.0)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'name',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  //compara las dos formas q hicimos con validator con Return
                  validator: (value)  => value.isEmpty ? 'Please enter some text' : null,
                  
                  onSaved: (value) => name = value.trim(),
                ),
                TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'recipe',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  //compara las dos formas q hicimos con validator con ternario
                  validator: (value) => value.isEmpty 
                  ? 'Please enter some recipe'
                  : null,
                  onSaved: (value) => recipe = value,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: _enviar,
                      child: Text('Create', style: TextStyle(color: Colors.white)),
                      color: Colors.green,
                    ),
                  ],
                ),
                
              ],
            ),

          ),
        ),
      ),
    );
  }
}