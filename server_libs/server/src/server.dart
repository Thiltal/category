part of server_common;

Router _myRouter;
shelf.Middleware _middle;
shelf.Handler _handler;
//UserProvider _userProvider;

/// id or login must be null (one of them filled)
//typedef UserBase UserProvider(int id, String login);

typedef RequestContext ContextProvider();

void serve(int port){
  io.serve(_handler, InternetAddress.ANY_IP_V4, port).then((server){
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

void loadServer(){
//  _userProvider = userProvider;
  _myRouter = router();
  _handler = new shelf.Cascade().add(_myRouter.handler).handler;
  _middle = sessionMiddleware(new SimpleSessionStore());
}

//void _saveToSession(RequestContext context, String key, dynamic value) {
//  Session mySession = session(context.request);
//  mySession[key] = value;
//}

Function _createInnerRoute(String method, ContextProvider controller, bool shouldLogged,
                          bool shouldData, List<String> dataItems, Map<String, String> headers){
  Function dataChecker = _checkData(method, shouldData, dataItems);

  if(method == "GET"){
    return (shelf.Request request){
      StreamController innerController = new StreamController();
      Stream<List<int>> out = innerController.stream;
      Session mySession = session(request);
      dynamic user = mySession[RequestContext.LOGGED_USER];
      if(shouldLogged && user == null){
        innerController
          ..add(const Utf8Codec().encode(resOutString("Not logged", false)))
          ..close();
        return new shelf.Response.ok(out, headers: headers);
      }
      Map<String, String> dataOut;
      if(request.url.hasQuery){
        dataOut = request.url.queryParameters;
      }
      dataOut = dataChecker(dataOut);
      if(dataOut != null && dataOut["suc"] == false){
        innerController
          ..add(const Utf8Codec().encode(JSON.encode(dataOut)))
          ..close();
        return new shelf.Response.ok(out, headers: headers);
      }
      RequestContext context = controller();
      context
        ..method = method
        ..request = request
        ..user = user
        ..session = mySession
        ..out = innerController;
      context.process(dataOut);
      return new shelf.Response.ok(out, headers: headers);
    };
  }else{
    return (shelf.Request request){
      StreamController innerController = new StreamController();
      Stream<List<int>> out = innerController.stream;
      Session mySession = session(request);
      dynamic user = mySession[RequestContext.LOGGED_USER];
      if(user == null && shouldLogged){
        innerController
          ..add(const Utf8Codec().encode(resOutString("Not logged", false)))
          ..close();
        return new shelf.Response.ok(out, headers: headers);
      }
      request.readAsString().then((String data){
        Object dataOut;
        dataOut = dataChecker(data);
        if(dataOut != null && dataOut is Map && dataOut["suc"] == false){
          innerController
            ..add(const Utf8Codec().encode(JSON.encode(dataOut)))
            ..close();
          return;
        }
        RequestContext context = controller();
        context
          ..method = method
          ..request = request
          ..user = user
          ..session = mySession
          ..out = innerController;
        context.process(dataOut);
      });
      return new shelf.Response.ok(out, headers: headers);
    };
  }
}

Function _checkData(String method, bool shouldData, List<String> dataItems){
  if(method == "GET"){
    if(!shouldData){
      return (Map<String, String> data){
        return data;
      };
    }
    if(dataItems != null && dataItems.length > 0){
      return (Map<String, String> data){
        if(data == null || data.length == 0){
          return resOut("Missing " + dataItems[0] + " parameter", false);
        }
        for(String key in dataItems){
          if(!data.containsKey(key)){
            return resOut("Missing " + key + " parameter", false);
          }
          if(data[key] == null){
            return resOut("Parameter " + key + " must not be null", false);
          }
        }
        return data;
      };
    }else{
      return (Map<String, dynamic> data){
        if(data == null || data.length == 0){
          return resOut("Missing some data", false);
        }
        return data;
      };
    }
  }else{
    if(!shouldData){
      return (String data){
        if(!data.startsWith("[") && !data.startsWith("{")){
          return resOut("Post does not contain JSON", false);
        }
        return JSON.decode(data);
      };
    }
    if(dataItems != null && dataItems.length > 0){
      return (String data){
        if(!data.startsWith("{")){
          return resOut("Post does not contain JSON map", false);
        }
        Map<String, dynamic> map = JSON.decode(data);
        for(String key in dataItems){
          if(!map.containsKey(key)){
            return resOut("Missing " + key + " parameter", false);
          }
        }
        return map;
      };
    }else{
      return (String data){
        if(data.length < 7 || !data.startsWith("[") || data.startsWith("{")){
          return resOut("Post does not contain JSON", false);
        }
        return JSON.decode(data);
      };
    }
  }
  return (){
  };
}

void route(String path, ContextProvider controller, {bool logged: false,
String method: "GET", bool data: false, List<String> dataItems: null, Map<String, String> headers:const <String, String>{HttpHeaders.CONTENT_TYPE: "text/json"}}){
  if(dataItems != null && dataItems.length > 0){
    data = true;
  }
  if(method == "GET"){
    _myRouter.get(
        path, _createInnerRoute(method, controller, logged, data, dataItems, headers),
        middleware: _middle);
  }else if(method == "POST"){
    _myRouter.post(
        path, _createInnerRoute(method, controller, logged, data, dataItems, headers),
        middleware: _middle);
  }else if(method == "PUT"){
    _myRouter.put(
        path, _createInnerRoute(method, controller, logged, data, dataItems, headers),
        middleware: _middle);
  }else if(method == "DELETE"){
    _myRouter.delete(
        path, _createInnerRoute(method, controller, logged, data, dataItems, headers),
        middleware: _middle);
  }
}


Map<String, dynamic> resOut(String resp, bool isSucc){
  return {"resp": resp, "suc": isSucc};
}

String resOutString(String resp, bool isSucc){
  return JSON.encode(resOut(resp, isSucc));
}
