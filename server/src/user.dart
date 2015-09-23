part of server;

class Users{
  bool changed = false;
  List<User> list = [];
  static int lastUserId = 0;

  void fromJson(List json){
    for(Map user in json){
      list.add(new User()..fromJson(user));
    }
  }

  List toJson(){
    List out = [];
    for(User u in list){
      out.add(u.toJson());
    }
    return out;
  }

  User getUserById(int id) {
    for (User u in list) {
      if (u.id == id) {
        return u;
      }
    }
    return null;
  }
  User getUserByLogin(String nick) {
    for (User u in list) {
      if (u.login == nick) {
        return u;
      }
    }
    return null;
  }

  User createUser(Map data, RequestContext context){
    User user = new User()..fromJson(data);
    user.password = User.encryptPassword(user.password);
    user.id = Users.lastUserId++;
    list.add(user);
    _changed = true;
    return user;
  }
}

class User {
  int id;
  int age;
  String login;
  String password;
  String email;
  String gender;
  String education;
  String work;

  User();

  void fromJson(Map json) {
    id = json["id"];
    if(json["age"] is int){
      age = json["age"];
    }else{
      age = int.parse(json["age"], onError: (_)=>0);      
    }
    login = json["login"];
    password = json["password"];
    email = json["email"];
    gender = json["gender"];
    education = json["education"];
    work = json["work"];
  }

  Map toJson() {
    Map out = {};
    out["id"] = id;
    out["age"] = age;
    out["login"] = login;
    out["password"] = password;
    out["email"] = email;
    out["gender"] = gender;
    out["work"] = work;
    out["education"] = education;
    return out;
  }

  static String encryptPassword(String plain){
    return new dbCrypt.DBCrypt().hashpw(plain, new dbCrypt.DBCrypt().gensalt());
  }

  toClientJson(){
    Map out = {};
    out["id"] = id;
    out["login"] = login;
    out["email"] = email;
    return out;
  }
}
