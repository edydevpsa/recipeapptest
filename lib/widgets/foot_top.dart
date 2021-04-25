import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/model/recipe_model.dart';
import 'package:recipesapp/pages/admin/view_recipe.dart';

class FoodTop extends StatefulWidget {
  @override
  _FoodTopState createState() => _FoodTopState();
}

class _FoodTopState extends State<FoodTop> {
  String userID;
  //Widget content;

  @override
  void initState() {
    setState(() {
      Auth().currentUser().then((value) {
        userID = value;
        print('print userID $userID');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var heights = MediaQuery.of(context).size.height * 0.15;// set height to 40% of the screen height

    return Container(
      height: heights,
      width: double.infinity,
      color: Colors.black26,
      child: StreamBuilder(
        stream: Firestore.instance.collection('colrecipes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>snapshot){
          if (!snapshot.hasData) {
            return Text('Loading...');
          } else {
            if (snapshot.data.documents.length == 0) {
              
            }else{
              return Container(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: snapshot.data.documents.map((document) {
                    return Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Recipe recipe = new Recipe(
                              name: document['name'].toString(),
                              image: document['image'].toString(),
                              recipe: document['recipe'].toString(),
                            );
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) {
                                  return ViewRecipe(
                                    recipe: recipe,
                                    idRecipe: document.documentID,
                                    uid: userID,
                                  );
                                }
                              )
                            );
                          },
                          child: Container(
                            height: 100.0,
                            margin: EdgeInsets.only(right:20.0),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: FadeInImage(
                                        width: 65.0,
                                        height: 65.0,
                                        placeholder: AssetImage('assets/images/azucar.gif'), 
                                        //IGUAL EL toString() NO DEBERIA ESTAR
                                        image: NetworkImage(document['image'].toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 2.0,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          document['name'].toString(),style: TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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