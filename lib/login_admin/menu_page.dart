import 'package:flutter/material.dart';
import 'package:recipesapp/auth/auth.dart';
import 'package:recipesapp/login_admin/contentPage.dart';
import 'package:recipesapp/widgets/home_page.dart';

const PrimaryColor = const Color(0xFF19212B);

class HomePage extends StatefulWidget {

  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String usuario = 'usuario';
  String usuarioEmail = 'Email';
  String id;

 Content page = ContentPage();
  Widget contentPage = HomePageRecipes();

  void _signout()async{ //usaremos en el ListTile drawer salir
    try {
      widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    widget.auth.infoUser().then((value) {
      setState(() {
        usuario = value.displayName;
        usuarioEmail = value.email;
        id = value.uid;

        print('Id $id');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 30.0,
        child: Container(
          color: Color(0xFF19212B),
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  maxRadius: 10.0,
                  backgroundImage: AssetImage('assets/images/cocina.jpg'),
                ),
                accountName: Text('$usuario', style: TextStyle(color:Colors.white),), 
                accountEmail: Text('$usuarioEmail', style: TextStyle(color: Colors.white),),
                decoration: BoxDecoration(
                  color: Color(0xFF262F3D),
                  image: DecorationImage(
                    image: AssetImage('assets/images/misanplas.jpg'),
                    fit: BoxFit.scaleDown,
                  ), 
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  page.lista().then((value) {
                    print(value);
                    setState(() {
                      contentPage = value;
                    });
                  });
                },
                leading: Icon(Icons.home, color: Color(0xFF4FC3F7)),
                title: Text('Home', style: TextStyle(color: Colors.white)),
              ),
              Divider(height: 2.0, color: Colors.white,),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  page.myrecipe(id).then((value){
                    print(value);
                    setState(() {
                      contentPage = value;
                    });
                  });
                },
                leading: Icon(Icons.local_pizza, color: Color(0xFF4FC3F7),),
                title: Text('My Recipe', style: TextStyle(color: Color(0xFF4FC3F7))),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  page.admin().then((value){
                    print(value);
                    setState(() {
                      contentPage = value;
                    });
                  });
                },
                leading: Icon(Icons.contact_mail, color: Color(0xFF4FC3F7),),
                title: Text('Admin', style: TextStyle(color: Color(0xFF4FC3F7))),
              ),
              ListTile(
                /*onTap: () {
                  Navigator.pop(context);
                  page.mapa().then((value){
                    print(value);
                    setState(() {
                      contentPage = value;
                    });
                  });
                },*/
                leading: Icon(Icons.map, color: Color(0xFF4FC3F7),),
                title: Text('Mapa Tiendas', style: TextStyle(color: Color(0xFF4FC3F7))),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _signout();
                },
                leading: Icon(Icons.exit_to_app, color: Color(0xFF4FC3F7),),
                title: Text('Salir', style: TextStyle(color: Color(0xFF4FC3F7))),
              ),

            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: Text('Recetas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.grid_on), 
            onPressed: (){
              //Route route = MaterialPageRoute(builder: (context) => GridPageInicio());
              //Navigator.push(context, route);
            }
          ),
        ],
      ),
      body: contentPage,
    );
  }
}