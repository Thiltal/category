library categoryApp;

import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

part "category_app.dart";
part "src/problem_list.dart";
part "src/solve_map.dart";
part "src/feedback.dart";
part 'src/model/cat_node.dart';
part 'src/model/gravity.dart';
part 'src/view/canvas.dart';

CategoryApp categoryApp;
SolveMap sm;
MapCanvas canvas;

main() {
  categoryApp = new CategoryApp();
  HttpRequest xhr = new HttpRequest();
  xhr
      ..open('POST', "/app_state")
      ..onLoad.listen((ProgressEvent event) {
    
        Map state = JSON.decode(xhr.responseText);
        if(state.containsKey("logged")&& state["logged"]){
          categoryApp.jumpToProblemList();
        }else{
          categoryApp.jumpToLogin();
        }
        
      })
      ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
      ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
      ..send('{"appStateRequested": true}');


}

class LoginForm {
  InputElement nick;
  InputElement password;
  ButtonElement send;
  LoginForm(Element cont) {
    nick = cont.querySelector("#login_nick");
    password = cont.querySelector("#login_password");
    send = cont.querySelector("#send_login");
    Function doLogin =(_) {
      send.innerHtml = "Login in progres...";
      send.classes.add("loadingInProgress");
      HttpRequest xhr = new HttpRequest();
      xhr
          ..open('POST', "/login")
          ..onLoad.listen((ProgressEvent event) {
            Map data = JSON.decode(xhr.responseText);
            if(data.containsKey("logged") && data["logged"]){
              categoryApp.jumpToProblemList();
            }else{
              window.alert("bad login");
            }
          })
          ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
          ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
          ..send(JSON.encode(toJson()));
    };
    send.onClick.listen(doLogin);
    nick.onKeyDown.listen((e){
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

  Map toJson() {
    Map out = {};
    out["nick"] = nick.value;
    out["password"] = password.value;
    return out;
  }
  
  void clear(){
    send.innerHtml = "Login";
    send.classes.remove("loadingInProgress");
  }
}


class NewUserForm {
  InputElement age;
  InputElement nick;
  InputElement password;
  InputElement email;
  SelectElement gender;
  SelectElement education;
  SelectElement work;
  ButtonElement send;

  NewUserForm(Element cont) {
    age = cont.querySelector("#new_user_age");
    nick = cont.querySelector("#new_user_nick");
    password = cont.querySelector("#new_user_password");
    email = cont.querySelector("#new_user_email");
    gender = cont.querySelector("#new_user_gender");
    education = cont.querySelector("#new_user_education");
    work = cont.querySelector("#new_user_work");
    send = cont.querySelector("#register_new_user");
    send.onClick.listen((_) {
      HttpRequest xhr = new HttpRequest();
      xhr
          ..open('POST', "/save_user")
          ..onLoad.listen((ProgressEvent event) {
            categoryApp.jumpToProblemList();
          })
          ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
          ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
          ..send(JSON.encode(toJson()));
    });
  }

  Map toJson() {
    Map out = {};
    out["age"] = age.value;
    out["nick"] = nick.value;
    out["password"] = password.value;
    out["email"] = email.value;
    out["gender"] = gender.value;
    out["work"] = work.value;
    out["education"] = education.value;
    return out;
  }

}


Random random = new Random(333);
int getRandomInt(int max) {
  return random.nextInt(max);
}


typedef OnFrame();

