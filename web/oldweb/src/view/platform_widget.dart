part of categoryApp;

class PlatformWidget extends Widget {
  static const String SIGN_UP = "signUp";
  static const String LOGIN = "login";
  static const String PROBLEM_LIST = "problem_list";
  String page = "none";

  PlatformWidget(){
    template = mustache.parse(resources.templates.platform);
  }

  @override
  void destroy(){
    // do nothing
  }

  @override
  Map out(){
    return {
      "page": page
    };
  }

  @override
  void setChildrenTargets(){
    if(!children.isEmpty){
      children.first.target = target.querySelector(".platform");
    }
  }

  @override
  void tideFunctionality(){
    if(page == SIGN_UP){
      children = [new SignUpWidget()];
    }else if(page == LOGIN){
      children = [new LoginWidget()];
    }
  }

  void goToSignUp(){
    page = SIGN_UP;
    displayApplication();
    requestRepaint();
  }

  void goToLogin(){
    page = LOGIN;
    displayApplication();
    requestRepaint();
  }

  void goOut(){
    applicationDiv.style.display = "none";
    document.body.style
      ..overflow = "visible"
      ..width = ""
      ..height = "";
  }

  void goToProblemList(){
    page = PROBLEM_LIST;
    displayApplication();
    requestRepaint();
  }
}