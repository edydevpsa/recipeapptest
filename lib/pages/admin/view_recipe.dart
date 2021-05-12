import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/model/recipe_model.dart';

class ViewRecipe extends StatefulWidget {
  final String idRecipe;
  final String uid;
  final Recipe recipe;

  ViewRecipe({this.idRecipe, this.recipe, this.uid});//consttructor

  //@override podemos desactivar si nos falla..
  _ViewRecipeState createState() => _ViewRecipeState();
}

enum SelectSource{camara, galeria}

class _ViewRecipeState extends State<ViewRecipe> {

  final formkey = GlobalKey<FormState>();
  String name;
  String recipe;
  File _image;
  String urlFoto = '';
  Auth auth = Auth();
  bool _isInAsyncCall = false;
  String usuario;

  BoxDecoration box = BoxDecoration(
    border: Border.all(width: 1.0, color: Colors.black),
    shape: BoxShape.rectangle,
    image: DecorationImage(
      image: AssetImage('assets/images/azucar.gif'),
      fit: BoxFit.fill,
    ),
  );

  @override
  void initState() {
    setState(() {
      this.name = widget.recipe.name;
      this.recipe = widget.recipe.recipe;

      captureImage(null, widget.recipe.image);
    });
    print('uid receta:' + widget.recipe.image);
    super.initState();
  }

  static var httpClient = new HttpClient();

  Future<File>_downloaderFile(String url, String filename)async{
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
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
          border: Border.all(width: 1.0, color: Colors.black),
          shape: BoxShape.rectangle,
          image: DecorationImage(
            image: FileImage(_image),
            fit: BoxFit.fill,
          ),
        );
      });
    } else {
      print('descarga la imagen');
      _downloaderFile(url, widget.recipe.name).then((value) {
        _image = value;
        setState(() {
          box = BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
            image: DecorationImage(
              image: FileImage(_image),
              fit: BoxFit.fill,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 10.0),
              ),
            ],
          );
        });
      });
    }
  }

  Future getImage()async{

    AlertDialog alerta = new AlertDialog(
      content: Text('selecciona para capturar imagen'),
      title: Text('seleccione imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            // seleccion = SelectSource.camara;
            captureImage(SelectSource.camara, null);
            Navigator.of(context, rootNavigator: true).pop();
          }, 
          child: Row(
            children: <Widget>[
              Text('Camara'),
              Icon(Icons.camera)
            ],
          ),
        ),
        FlatButton(
          onPressed: (){
            // seleccion = SelectSource.galeria;
            captureImage(SelectSource.galeria, null);
            Navigator.of(context,rootNavigator: true).pop();
          }, 
          child: Row(
            children: <Widget>[
              Text('Galeria'),
              Icon(Icons.image),
            ],
          )
        ),
      ],
    );
    showDialog(context: context, child: alerta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Recipe'),
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
            key: formkey,
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
                      margin: EdgeInsets.only(top: 10.0),
                      height: 250.0,
                      width: 250.0,
                      decoration: box,
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top:10.0)),
                TextFormField(
                  enabled: true,
                  keyboardType: TextInputType.text,
                  initialValue: name,
                  decoration: InputDecoration( labelText: 'Name'),
                  validator: (value) => value.isEmpty ? 'El campo nombre esta vacio': null,
                  onSaved: (value) => recipe = value.trim(),
                ),
                Padding(padding: EdgeInsets.only(top: 50.0)),
              ],
            ), 
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}