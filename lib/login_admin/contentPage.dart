
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
  
  Future<InicioPage>admin()async{
    return InicioPage();
  }

  Future<InicioPage>recetas(String id)async{
    print('Content page $id');
    return InicioPage(id: id);
  }

  Future<ListMyRecipe>myrecipe(String id)async{
    print('listando mis recetas $id');
    return ListMyRecipe(id: id);
  }

}