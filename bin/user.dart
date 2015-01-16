part of server;

class User {
  int id;
  int age;
  String nick;
  String password;
  String email;
  String gender;
  String education;
  String work;

  User(this.id);

  Stream<int> save() {
    StreamController controller = new StreamController();
    Stream<int> out = controller.stream;
    connect(uri).then((conn) {
      try{
      conn.execute("""
          INSERT INTO "User"(
            id, age, nick, password, email, gender, education, work)
          VALUES (@id, @age, @nick, @password, @email, @gender, @education, @work)
     """, toJson()).then((int code) {
        controller.add(code);
        controller.close();
      });
      conn.close();
      }catch(e){
        controller.add(404);
        controller.close();
        conn.close();
      }
    });
    
    return out;
  }

  void fromJson(Map json) {
    if(json["age"] is int){
      age = json["age"];
    }else{
      age = int.parse(json["age"], onError: (_)=>0);      
    }
    nick = json["nick"];
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
    out["nick"] = nick;
    out["password"] = password;
    out["email"] = email;
    out["gender"] = gender;
    out["work"] = work;
    out["education"] = education;
    return out;
  }
}
