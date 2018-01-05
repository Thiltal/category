import 'package:angular/angular.dart';
import 'package:category/app_component.dart';
import 'package:firebase/firebase.dart' as firebase;

main() {
  firebase.initializeApp(
      apiKey: "AIzaSyAwn1XApNg92BsNgkRHQEIt4vJqolzS4n0",
      authDomain: "gold-fiber-733.firebaseapp.com",
      databaseURL: "https://gold-fiber-733.firebaseio.com",
      projectId: "gold-fiber-733",
      storageBucket: "");
  bootstrap(AppComponent);
}
