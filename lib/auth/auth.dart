

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipesapp/model/user_model.dart';

abstract class BaseAuth{
  Future<String> signInEmailPassword(String email, String password);
  Future<String>signUpEmailPassword(Usuario usuario);//jalamos la clase usuario del ussr_model.dart
  Future<void>signOut();
  Future<String>currentUser();
  Future<FirebaseUser>infoUser();
} 

class Auth implements BaseAuth{

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //OJO:los overrides estan sobre escribiendo si da error podemos borrarlo

  @override
  Future<String> signInEmailPassword(String email, String password) async{
    
    AuthResult user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    return user.user.uid;
    //throw UnimplementedError();
  }

  @override
  Future<String> signUpEmailPassword(Usuario usuarioModel) async{

    AuthResult user = await _firebaseAuth.createUserWithEmailAndPassword(
      email: usuarioModel.email, password: usuarioModel.password
    );

    UserUpdateInfo usuario = UserUpdateInfo();
    usuario.displayName = usuarioModel.nombre;
    await user.user.updateProfile(usuario);
    await user.user.sendEmailVerification().then((value) => print('Email de verification enviado'))
     .catchError((onError) => print('Error de verificacion: $onError'));
    
    await Firestore.instance.collection('usuarios').document('${user.user.uid}').setData({
      'nombre'  : usuarioModel.nombre,
      'telefono': usuarioModel.telefono,
      'email'   : usuarioModel.email,
      'ciudad'  : usuarioModel.ciudad,
      'direccion': usuarioModel.direccion,
    }).then((value) => print('usuario registrado en la bd'))
      .catchError((onError) => print('Error al registrar usuario en la bd'));

    return user.user.uid;
    //throw UnimplementedError();

  }

  @override
  Future<void> signOut() async{

    return _firebaseAuth.signOut();
    //throw UnimplementedError('Error in signOut()');
  }

  @override
  Future<String> currentUser()async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    String userId = user != null ? user.uid : 'no login';

    return userId;
    //throw UnimplementedError();
  }

  @override
  Future<FirebaseUser> infoUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    String userId = user != null ? user.uid : 'No se puede recuperar usuario';
    print('recuperando usuario + $userId');
    //throw UnimplementedError();

    return user;
  }
}