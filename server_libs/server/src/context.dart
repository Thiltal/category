part of server_common;

abstract class RequestContext {
  static const String LOGGED_USER = "loggedUser";

  // for future implementation of session timeout
  static const String LAST_ACTIVITY = "lastActivity";
  String method = "POST";
  shelf.Request request;
  StreamController out;
  dynamic user;
  Map data;
  String message="";
  Session session;
  bool success = true;

  void process(Map<String, String> data){
    this.data = data;
    onBeforeValidation();
    validate();
    execute();
  }


  void onBeforeValidation(){}
  void validate(){}
  void execute();

  void write(dynamic data) {
    if (data is! String) {
      data = JSON.encode(data);
    }
    out.add(const Utf8Codec().encode(data));
  }

  void close() {
    out.close();
  }

  bool respond(String resMessage, bool isSuccess) {
    message += resMessage;
    success = success && isSuccess;
    if(out!=null){  // only because of tests
      write({"resp": message, "suc": success});
      close();
    }
    return success;
  }
  bool get closed => out.isClosed;

}