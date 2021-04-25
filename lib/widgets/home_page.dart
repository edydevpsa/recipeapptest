import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/widgets/food_body.dart';
import 'package:recipesapp/widgets/foot_top.dart';

class HomePageRecipes extends StatefulWidget {
  @override
  _HomePageRecipesState createState() => _HomePageRecipesState();
}

class _HomePageRecipesState extends State<HomePageRecipes> {
  String userID;
  //Auth auth = new Auth();

  @override
  void initState() {
    setState(() {
      Auth().currentUser().then((value) {
        userID = value;
        print('el futuro cheft $userID');
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                'Favorite', style: TextStyle(
                  color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500,
                )
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: FoodTop(),//food_top.dart // FoodTop()
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                'World recipes', style: TextStyle(
                  color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500,
                )
              ),
            ),
          ),
          Expanded(
            child: FoodBody(),
          ),
        ],
      ),
    );
  }
}