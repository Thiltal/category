part of server;

class Model{
  Problems problems;
  Users users;
  int lastUserId;

  Model(){
    users = new Users();
    problems = new Problems();
  }

  fromJson(Map json){
    users.fromJson(json["users"]);
    print(JSON.encode(toJson()));
  }

  Map toJson(){
    Map out = {};
    out["users"] = users.toJson();
    return out;
  }

  User getUserById(id){
    return users.getUserById(id);
  }
}