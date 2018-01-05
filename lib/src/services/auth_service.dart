import 'dart:async';

import 'package:angular/core.dart';
import 'package:category/src/model/model.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/src/firestore.dart';

/// Mock service emulating access to a to-do list stored on a server.
@Injectable()
class AuthService {
  firebase.User user;
  User userData = new User();
  DocumentReference loggedUserDocument;
  bool userLoaded = false;

  AuthService() {
    firebase.auth().onAuthStateChanged.listen((firebase.User user) {
      this.user = user;
      if (loggedUserDocument != null) {
        return;
      }
      loggedUserDocument =
          firebase.firestore().collection('users').doc(user.uid);
      loggedUserDocument.onSnapshot.listen((DocumentSnapshot userSnapshot) {
        if (!userSnapshot.exists) {
          userData = new User()..fromFirebaseUser(user);
          loggedUserDocument.set(userData.toMap());
        } else {
          userData.fromMap(userSnapshot.data());
        }
        userLoaded = true;
      });
    });
  }

  Future<Null> login() async {
    firebase.UserCredential credentials = await firebase
        .auth()
        .signInWithPopup(new firebase.GoogleAuthProvider());
    this.user = credentials.user;
  }

  void saveUsedData() {
    loggedUserDocument.update(data: userData.toMap());
  }
}