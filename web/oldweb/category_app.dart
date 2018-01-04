part of categoryApp;


class CategoryApp {
  Element newUser;
  NewUserForm userForm;
  ProblemList problemList;
  Feedback feedbackClass;
  Element login;
  LoginForm loginForm;
  Element loadingScreen;
  Element welcome;
  Element map;
  Element feedback;
  Element problemListElement;

  CategoryApp() {
    newUser = querySelector("#new_user");
    userForm = new NewUserForm(newUser);
    login = querySelector("#login");
    loginForm = new LoginForm(login);
    loadingScreen = querySelector("#loadingScreen");
    welcome = querySelector("#welcome");
    map = querySelector("#map");
    feedback = querySelector("#feedback");
    problemListElement = querySelector("#problemList");


    Function resizeLoadingScreen = (_) {
      loadingScreen.style
          ..width = "${window.innerWidth}px"
          ..height = "${window.innerHeight}px";
    };
    window.onResize.listen(resizeLoadingScreen);
    resizeLoadingScreen(null);

    hideAll();


    querySelector("#login_button").onClick.listen((_) {
      if (login.style.display != "none") {
        login.style.display = "none";
      } else {
        login.style.display = "block";
        newUser.style.display = "none";
      }
    });
    querySelector("#new_account").onClick.listen((_) {
      if (newUser.style.display != "none") {
        newUser.style.display = "none";
      } else {
        newUser.style.display = "block";
        login.style.display = "none";
      }
    });
  }

  void jumpToProblemList() {
    hideAll();
    problemListElement.style.display = "block";
    problemList = new ProblemList(problemListElement);
  }

  void jumpToLogin() {
    hideAll();
    loginForm.clear();
    welcome.style.display = "block";
  }

  void jumpToMap(int mapId) {
    hideAll();
    map.style.display = "block";
    sm = new SolveMap(mapId);
  }

  void jumpToFeedback(Map statistics) {
    hideAll();
    feedback.style.display = "block";
    feedbackClass = new Feedback(feedback, statistics);
  }

  void hideAll() {
    login.style.display = "none";
    newUser.style.display = "none";
    welcome.style.display = "none";
    map.style.display = "none";
    feedback.style.display = "none";
    loadingScreen.style.display = "none";
    problemListElement.style.display = "none";
  }

}
