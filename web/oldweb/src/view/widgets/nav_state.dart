part of categoryApp;

class NavStateWidget extends Widget {
  Element signUp;
  Element login;
  Element logout;

  NavStateWidget(){
    template = mustache.parse(resources.templates.state_nav);
  }

  @override
  void destroy(){
    //
  }

  @override
  Map out(){
    return {
      "logged": user.logged,
      "email": user.email
    };
  }

  @override
  void setChildrenTargets(){
    //
  }

  @override
  void tideFunctionality(){
    signUp = querySelector(".signUpNav");
    if(signUp != null){
      signUp.onClick.listen((_){
        view.platformWidget.goToSignUp();
        requestRepaint();
      });
    }

    login = querySelector(".loginNav");
    if(login != null){
      login.onClick.listen((_){
        view.platformWidget.goToLogin();
        requestRepaint();
      });
    }

    logout = querySelector(".logoutNav");
    if(logout != null){
      logout.onClick.listen((_){
        HttpRequest.getString(CONTROLLER_LOGOUT).then((String jsonString){
          Map response = JSON.decode(jsonString);
          if(response["logout"]){
            view.platformWidget.goOut();
            user = new User();
            requestRepaint();
          }
        });
      });
    }
  }
}