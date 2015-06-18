library server;

import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' show join, dirname;
import '../shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_simple_session/shelf_simple_session.dart';
import 'dart:async';
import 'dart:convert';
import 'package:postgresql/postgresql.dart';

part 'src/problem.dart';
part 'src/user.dart';
part 'src/solution.dart';

Problems problems = new Problems();
Users users = new Users();
Router myRouter;
shelf.Middleware middle;

typedef DHandler(RequestContext context);

String uri = 'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

void main(){
  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);


  io.serve((shelf.Request request){
    print(request.url);
    return new shelf.Response.ok("ahoj");
  }, InternetAddress.ANY_IP_V4, port).then((server){
    server.autoCompress = true;
    print('Serving at http://${server.address.host}:${server.port}');
  });
  load();
}

void run(){
  print("run");
  new Timer.periodic(const Duration(minutes:5), (_){
    save();
  });
}

Map allData(){
  Map data = {};
  data["problems"] = problems.toJson();
  data["users"] = users.toJson();
  data["lastUserId"] = Users.lastUserId;
  data["lastProblemId"] = Problems.lastProblemId;
  return data;
}

void save(){
//  if(!users.changed && !problems.changed)return;
  Map data = allData();
  connect(uri).then((conn){
    print("saving ${"update \"Data\" set data='${JSON.encode(data)}'"}");
    conn.execute("update \"Data\" set data='${JSON.encode(data)}'").whenComplete((){
      conn.close();
    }).catchError((err)=> print('Query error: $err'));
  }, onError: (e){
    print("could not be saved to database");
    new File("backup.json").writeAsString(JSON.encode(data));
  });
}


void load(){
  String data;
  print("load");
  connect(uri).then((conn){
    print("db connected");
    conn.query('select * from "Data"').toList().then((List<Row> rows) {
      print("data");
      data = rows.first.toList().first;
    }).then((event){
      try{
        Map d = JSON.decode(data);
        problems.fromJson(d["problems"]);
        users.fromJson(d["users"]);
        Problems.lastProblemId = d["lastProblemId"];
        Users.lastUserId = d["lastUserId"];
      }catch(e){
        /* do nothing */
      }
      run();
    });
  }, onError: (e){
    print("data are not from database");
    File backup = new File("backup.json");
    if(backup.existsSync()){
      Map d = JSON.decode(backup.readAsStringSync());
      problems.fromJson(d["problems"]);
      users.fromJson(d["users"]);
      Problems.lastProblemId = d["lastProblemId"];
      Users.lastUserId = d["lastUserId"];
    }else{
      Problems.lastProblemId = 0;
      Users.lastUserId = 0;
    }
  });
}

void appState(RequestContext context){
  context.write({"logged": context.user!=null, "problemId": 1});
  context.close();
}

void saveUser(RequestContext context){
  User newUser = new User();
  newUser.id = Users.lastUserId++;
  newUser.fromJson(context.data);
  users.list.add(newUser);
  Map mySession = session(context.request);
  mySession["loggedUser"]= newUser;
  context.write(newUser.toJson());
  save();
  context.close();
}

void login(RequestContext context){
  Map user = context.data;
  User u = users.getUserByNick(user["nick"]);
  if(u!=null && u.password == user["password"]){
    Map mySession = session(context.request);
    mySession["loggedUser"] = u;
    context.write({"user": u.toJson(), "logged": true});
  }else{
    context.write({"logged": false});
  }
  context.close();
}


void route(String path, DHandler controller){
  myRouter.post(path, (shelf.Request request){
    StreamController innerController = new StreamController();
    Stream<List<int>> out = innerController.stream;
    request.readAsString().then((String data){
      dynamic dataOut;
      if(data[0]=="{" || data[0]=="["){
        dataOut = JSON.decode(data);
      }else{
        dataOut=data;
      }
      User user;
      Map mySession = session(request);
      if(mySession.containsKey("loggedUser")){
        user = mySession["loggedUser"];
      }
      controller(new RequestContext()
        ..data = dataOut
        ..request = request
        ..user = user
        ..out = innerController);
    });

    var headers = <String, String>{HttpHeaders.CONTENT_TYPE: "text/json"};
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);
}

getProblems(RequestContext context){
  context.write({
    "problems": JSON.encode(problems.toJson())
  });
  context.close();
}

solveProblem(RequestContext context){
  if(context.user!=null){
    Solution solution = new Solution(context.user, problems.getProblemById(context.data["mapId"]));
    solution.fromData(context.data);
    solution.problem.solutions.add(solution);
    context.close();
  }
}

logout(RequestContext context){
  Map mySession = session(context.request);
  mySession["loggedUser"] = null;
  context.close();
}

class RequestContext{
  shelf.Request request;
  StreamController out;
  User user;
  dynamic data;

  void write(dynamic data){
    if(data is !String){
      data = JSON.encode(data);
    }
    out.add(const Utf8Codec().encode(data));
  }
  void close(){
    out.close();
  }
}