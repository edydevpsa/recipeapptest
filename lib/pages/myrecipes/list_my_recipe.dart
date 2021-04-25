import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/model/recipe_model.dart';
import 'package:recipesapp/pages/myrecipes/add_my_recipe.dart';
import 'package:recipesapp/pages/myrecipes/edit_my_recipe.dart';
import 'package:recipesapp/pages/myrecipes/view_my_recipe.dart';

class CommonThings{
  static Size size;
}

TextEditingController phoneInputController;
TextEditingController nameInputController;
String id;
final bd = Firestore.instance;
String name;

class ListMyRecipe extends StatefulWidget {
  final String id;
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  ListMyRecipe({this.auth, this.onSignedOut, this.id}); //constructor

  @override
  _ListMyRecipeState createState() => _ListMyRecipeState();
}

class _ListMyRecipeState extends State<ListMyRecipe> {

  String userID;
  //Widget content
  
  @override
  void initState() {
    setState(() {
      Auth().currentUser().then((value) {
        userID = value;
        print('el userID  es $userID');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CommonThings.size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('usuarios')
        .document(widget.id).collection('mycolrecipes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (!snapshot.hasData) {
            return Text('Loading...');
          } else {
            if (snapshot.data.documents.length  == 0) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15.0),
                      shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 5.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '\nAdd my recipe.\n', style: TextStyle(
                              fontSize: 24.0, color:  Colors.blue,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            }else{
              //print("from the streamBuilder: "+ snapshot.data.documents[]);
              // print(length.toString() + " doc length");
              return ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: snapshot.data.documents.map((document){
                  return Card(
                    elevation: 5.0,
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: FadeInImage(
                              placeholder: AssetImage('assets/images/azucar.gif'), 
                              image: NetworkImage(document['image'].toString()),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  document['name'].toString().toUpperCase(),
                                  style: TextStyle(fontSize: 17.0, color: Colors.blueAccent),
                                ),
                                subtitle: Text(
                                  document['recipe'].toString().toUpperCase(),
                                  style: TextStyle(fontSize: 12.0, color:Colors.black),
                                ),
                                //editar la receta
                                onTap: () {
                                  Recipe recipe = Recipe(
                                    name: document['name'].toString(),
                                    image: document['image'].toString(),
                                    recipe: document['recipe'].toString(),
                                  );
                                  Navigator.push(
                                    context, MaterialPageRoute(
                                      builder: (context) => EditMyRecipe(
                                        recipe: recipe,
                                        idRecipe: document.documentID,
                                        uid: userID,
                                      )
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,color: Colors.redAccent), 
                          onPressed: (){
                            //eliminamos la receta personal
                            document.data.remove('key');
                            Firestore.instance.collection('usuarios/$userID/colrecipes')
                            .document(document.documentID).delete();
                            //eliminamos la foto
                            FirebaseStorage.instance.ref().child(
                            'usuarios/$userID/mycolrecipes/${document['name'].toString()}.jpg'
                            ).delete().then((value) => print('foto eliminada'));
                          }
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Colors.blueAccent), 
                          onPressed: (){
                            Recipe myrecipe = Recipe(
                              name: document['name'].toString(),
                              image: document['image'].toString(),
                              recipe: document['recipe'].toString(),
                            );
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) => ViewMyRecipe(
                                  recipe : myrecipe,
                                  idRecipe: document.documentID,
                                  uid: userID
                                ),
                              )
                            );
                          }
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.blue,

        onPressed: (){
          Route route = MaterialPageRoute(
            builder: (context) => MyAddRecipe()
          );
          Navigator.push(context, route);
        }
      ),
    );
  }
}
