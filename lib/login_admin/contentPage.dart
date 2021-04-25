
import 'package:recipesapp/pages/admin/show_recipe.dart';
import 'package:recipesapp/pages/myrecipes/list_my_recipe.dart';
import 'package:recipesapp/widgets/home_page.dart';

abstract class Content{

  Future<HomePageRecipes>lista();
  Future<InicioPage>recetas(String id);
  //Future<MapsPage>mapa();
  Future<ListMyRecipe>myrecipe(String id);
  Future<InicioPage>admin();

}

class ContentPage implements Content{

  Future<HomePageRecipes>lista()async{
    return HomePageRecipes();
  }

  /*Future<MapsPage>mapa()async{
    return MapsPage();
  }*/

  Future<InicioPage>admin()async{
    return InicioPage();
  }

  Future<InicioPage>recetas(String id)async{
    print('content page $id');
    return InicioPage(id: id);
  }

  Future<ListMyRecipe>myrecipe(String id)async{
    print('listado mis recetas $id');
    return ListMyRecipe(id: id);
  }

}