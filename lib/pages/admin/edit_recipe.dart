import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/model/recipe_model.dart';

class EditRecipe extends StatefulWidget {
  final String idRecipe;
  final String uid;
  final Recipe recipe;

  EditRecipe({this.recipe, this.idRecipe, this.uid}); //constructor

  @override
  _EditRecipeState createState() => _EditRecipeState();
}

enum SelectSource{camara, galeria}

class _EditRecipeState extends State<EditRecipe> {

  final formKey = GlobalKey<FormState>();
  String _name;
  String _recipe;
  File _image;
  String urlFoto = '';
  Auth auth = Auth();
  bool _isInAsyncCall = false;
  String usuario;

  BoxDecoration box = new BoxDecoration(
    border: Border.all(width: 1.0, color: Colors.black),
    shape: BoxShape.circle,
    image: DecorationImage(
      image: AssetImage('assets/images/azucar.gif'),
      fit: BoxFit.fill,
    ),
  );

  @override
  void initState() {
    setState(() {
      this._name = widget.recipe.name;
      this._recipe = widget.recipe.recipe;
      captureImage(null, widget.recipe.image);
    });
    print('uid recetas' + widget.idRecipe);
    super.initState();
  }

  static var httpClient = new HttpClient();

  Future<File>_downloadFile(String url, String filename)async{

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes= await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);

    return file;
  }

  Future captureImage(SelectSource opcion, String url)async{
    File image;
    if (url == null) {
      print('imagen');
      opcion == SelectSource.camara 
      ? image = await img.ImagePicker.pickImage(source: img.ImageSource.camera)
      : image = await img.ImagePicker.pickImage(source: img.ImageSource.gallery);

      setState(() {
        _image = image;
        box = BoxDecoration(
          border:  Border.all(width: 1.0, color: Colors.black),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(_image),
            fit: BoxFit.fill
          ),
        );
      });
    } else {
      print('descarga la imagen');
      _downloadFile(url, widget.recipe.name).then((value){
        _image = value;
        setState(() {
          box = BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
            shape: BoxShape.circle,
            image: DecorationImage(
              image: FileImage(_image)
            ),
            //imagereceta = FileImage(_foto)
          );
        });
      });
    }
  }

  Future getImage()async{
    AlertDialog alerta = AlertDialog(
      content:  Text('Seleccione para capturar la imagen'),
      title: Text('seleccione Imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            //seleccion= SlectSource.camara
            captureImage(SelectSource.camara, null);
            Navigator.of(context, rootNavigator: true).pop();
          }, 
          child: Row(
            children: <Widget>[
              Text('Camara',),
              Icon(Icons.camera)
            ],
          ) ,
        ),
        FlatButton(
          onPressed: (){
            captureImage( SelectSource.galeria,null);
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
  bool _validar(){
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _enviar(){//enviar la informacion a Firestore
    if (_validar()) {
      setState(() {
        _isInAsyncCall = true;
      });
      auth.currentUser().then((value){
        setState(() {
          usuario = value;
        });
        if (_image != null) {
          final StorageReference fireStoreRef = FirebaseStorage
          .instance.ref().child('colrecipes').child('$_name.jpg');

          final StorageUploadTask task = fireStoreRef
          .putFile(_image, StorageMetadata(contentType: 'image/jpeg'));

          task.onComplete.then((value) {
            setState(() {
              urlFoto = value.toString();
              Firestore.instance
              .collection('colrecipes')
              .document(widget.idRecipe)
              .updateData({
                'name'  : _name,
                'image' : urlFoto,
                'recipe': _recipe,
              }).then((value) {
                Navigator.of(context).pop();
              }).catchError((onError) => print('Error al editar la receta en la bd'));

              _isInAsyncCall = false;
            });
          });
        } else {
          Firestore.instance.collection('colrecipes')
          .add({
            'name'  : _name,
            'image' : urlFoto,
            'recipe': _recipe
          }).then((value) => Navigator.of(context).pop()).catchError(
            (onError) => print('Error al editar el usuario en la bd')
          );
          _isInAsyncCall = false;
        }
      }).catchError((onError) => _isInAsyncCall = false);
    } else {
      print('objeto no valido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Edit'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall, 
        opacity: 0.5,
        dismissible: false,
        progressIndicator: CircularProgressIndicator(),
        color: Colors.blueGrey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left:10.0, right: 15.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        onDoubleTap: getImage,
                      ),
                      margin: EdgeInsets.only(top:20.0),
                      height: 120.0,
                      width: 120.0,
                      decoration: box,
                    ),
                  ],
                ),
                Text('double click para cambiar la imagen'),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  keyboardType: TextInputType.text,
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) => value.isEmpty ? 'el campo nombre esta vacio': null,
                  onSaved: (value) => _name = value.trim(),
                ),
                Padding(padding: EdgeInsets.only(top: 50.0)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _enviar,
        child: Icon(Icons.edit),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 20.0,
        color: Colors.blue,
        child: ButtonBar(),
      ),
    );
  }
}