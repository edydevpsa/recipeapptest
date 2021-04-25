import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/model/recipe_model.dart';
import 'package:recipesapp/pages/admin/view_recipe.dart';

class FoodBody extends StatefulWidget {
  @override
  _FoodBodyState createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody> {

  String userID;
  //Widget content
  @override
  void initState() {
    Auth().currentUser().then((value) {
      userID = value;
      print('print userID de FoodBody $userID');
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: StreamBuilder(
        stream: Firestore.instance.collection('colrecipes').snapshots(),
  
        builder:( BuildContext context, AsyncSnapshot<QuerySnapshot>snapshot){
          if (!snapshot.hasData) {
            return Text('Loading...');
          } else {
            if (snapshot.data.documents.length == 0) {
              
            }else{
              return Container(
                child: ListView(
                  children: snapshot.data.documents.map((document){
                    return Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 2.0, left: 2.0, right: 2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              onTap: () {
                                Recipe recipe = new Recipe(
                                  name: document['name'].toString(),
                                  image: document['image'].toString(),
                                  recipe: document['recipe'].toString(),
                                );
                                Navigator.push(
                                  context, MaterialPageRoute(
                                    builder: (context){
                                      return ViewRecipe(
                                        recipe: recipe,
                                        idRecipe: document.documentID,
                                        uid: userID,
                                      );
                                    }
                                  )
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: FadeInImage(
                                        width: 340.0,
                                        height: 220.0,
                                        placeholder: AssetImage(
                                          'assets/images/azucar.gif'
                                        ), 
                                        //el tostring NO DEBERIA ESTAR
                                        image: NetworkImage(document['image'].toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  //Borde para poner en la foto estrellas y titulos
                                  Positioned(
                                    left: 10.0,
                                    bottom: 10.0,
                                    child: Container(
                                      height: 40.0,
                                      width: 325.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 20.0,
                                    right: 10.0,
                                    bottom: 10.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              document['name'].toString(), style: 
                                              TextStyle(
                                                color: Colors.white, fontSize: 18.0, 
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
          }
          return Container();
        },
      ),
    );
  }
}