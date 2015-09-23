part of server;

class StateRequestContext extends RequestContext {
  String email;

  @override
  validate(){
  }

  @override
  void execute(){
    User user = session[RequestContext.LOGGED_USER];
    if(user != null){
      write({
        "user" : user.toClientJson(),
        "logged": true
      });
    }else{
      write({
        "logged": false
      });
    }
    close();
  }
}