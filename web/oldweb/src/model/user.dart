part of categoryApp;

class User{
  int id;
  String login;
  String email="";
  bool logged = false;

  void fromJson(Map json) {
    id = json["id"];
    login = json["login"];
    email = json["email"];
  }
}