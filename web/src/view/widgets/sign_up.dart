part of categoryApp;

class SignUpWidget extends Widget {
  InputElement age;
  InputElement login;
  InputElement password;
  InputElement email;
  SelectElement gender;
  SelectElement education;
  SelectElement work;
  ButtonElement send;

  SignUpWidget(){
    template = mustache.parse(resources.templates.sign_up);
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
    age = target.querySelector("#new_user_age");
    login = target.querySelector("#new_user_login");
    password = target.querySelector("#new_user_password");
    email = target.querySelector("#new_user_email");
//      gender = target.querySelector("#new_user_gender");
//      education = target.querySelector("#new_user_education");
//      work = target.querySelector("#new_user_work");
    send = target.querySelector("#register_new_user");
    send.onClick.listen((_){
      HttpRequest xhr = new HttpRequest();
      xhr
        ..open('POST', CONTROLLER_CREATE_USER)
        ..onLoad.listen((ProgressEvent event){
//        categoryApp.jumpToProblemList();
      })
        ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
        ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
        ..send(JSON.encode(toJson()));
    });
  }

  Map toJson(){
    Map out = {};
    out["age"] = age.value;
    out["login"] = login.value;
    out["password"] = password.value;
    out["email"] = email.value;
//    out["gender"] = gender.value;
//    out["work"] = work.value;
//    out["education"] = education.value;
    return out;
  }


}