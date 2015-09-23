part of server;


class CreateUserRequestContext extends RequestContext {
  String email;

  @override
  validate(){
    email = data["email"];
    if(email != null && email != ""){
      if(!isEmail(email)){
        write({"error": "email", "message": "incorrect email"});
        close();
      }
    }
  }

  @override
  void execute(){
    User user = model.users.createUser(data, this);
    if(user != null){
      session[RequestContext.LOGGED_USER] = user;
    }
    _changed = true;
    write(user.toClientJson());
    close();
  }

  static String encryptPassword(String plain){
    return new dbCrypt.DBCrypt().hashpw(plain, new dbCrypt.DBCrypt().gensalt());
  }

  bool isEmail(String email){

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }
}

class LoginRequestContext extends RequestContext {
  @override
  void execute(){
    String login = data["login"];
    String password = data["password"];
    User user = model.users.getUserByLogin(login);
    if(user == null){
      write({"login": false, "message": "user not exist"});
      close();
    }
    if(new dbCrypt.DBCrypt().checkpw(password, user.password)){
      session[RequestContext.LOGGED_USER] = user;
      write({
        "login": true,
        "message": "login successfull",
        "user": user.toClientJson()
      });
      close();
    }else{
      write({"login": false, "message": "login failed"});
      close();
    }
  }
}

class LogoutRequestContext extends RequestContext {

  @override
  void execute(){
    session.remove(RequestContext.LOGGED_USER);
    write({"logout": true, "message": "logout successfull"});
    close();
  }
}