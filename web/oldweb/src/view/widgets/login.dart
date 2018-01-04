part of categoryApp;

class LoginWidget extends Widget {
  InputElement login;
  InputElement password;
  ButtonElement send;

  LoginWidget(){
    template = mustache.parse(resources.templates.login);
  }


  Map toJson(){
    Map out = {};
    out["login"] = login.value;
    out["password"] = password.value;
    return out;
  }

  void clear(){
    send.innerHtml = "Login";
    send.classes.remove("loadingInProgress");
  }

  @override
  void destroy(){
    // do nothing
  }

  @override
  Map out(){
    return {};
  }

  @override
  void setChildrenTargets(){
  }

  @override
  void tideFunctionality(){
    login = target.querySelector("#login_login");
    password = target.querySelector("#login_password");
    send = target.querySelector("#send_login");
    Function doLogin = (_){
      send.innerHtml = "Login in progres...";
      send.classes.add("loadingInProgress");
      HttpRequest xhr = new HttpRequest();
      xhr
        ..open('POST', CONTROLLER_LOGIN)
        ..onLoad.listen((ProgressEvent event){
        Map data = JSON.decode(xhr.responseText);
        if(data.containsKey("message") && data["message"]=="login successfull"){
          view.platformWidget.goToProblemList();
          user.logged = true;
          user.fromJson(data["user"]);
          view.navStateWidget.requestRepaint();
        }else{
          window.alert("bad login");
        }
      })
        ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
        ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
        ..send(JSON.encode(toJson()));
    };
    send.onClick.listen(doLogin);
    login.onKeyDown.listen((e){
      if(e.keyCode == KeyCode.ENTER){
        doLogin(e);
      }
    });
    password.onKeyDown.listen((e){
      if(e.keyCode == KeyCode.ENTER){
        doLogin(e);
      }
    });
  }

}