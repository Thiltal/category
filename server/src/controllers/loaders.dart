part of server;

_loadControllers(){
  route(CONTROLLER_CREATE_USER, ()=>new CreateUserRequestContext(), method: "POST", data: true, dataItems: ["login", "password"]);
  route("/api/test", ()=>new TestRequestContext(), method: "GET");
  route(CONTROLLER_LOGIN, ()=>new LoginRequestContext(), method: "POST", data: true, dataItems: ["login", "password"]);
  route(CONTROLLER_LOGOUT, ()=>new LogoutRequestContext(), method: "GET");
  route(CONTROLLER_STATE, ()=>new StateRequestContext(), method: "GET");
}


class TestRequestContext extends RequestContext{
  @override
  validate(){}
  @override
  void execute(){
    write("test");
    close();
  }

}