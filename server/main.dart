library server;

import 'dart:async';
import 'dart:convert';
import 'package:postgresql/postgresql.dart';
import "../server_libs/server/library.dart";
import "package:dbcrypt/dbcrypt.dart" as dbCrypt;
import "../lib/constants/constants.dart";

part 'src/problem.dart';
part 'src/user.dart';
part 'src/solution.dart';
part "src/model.dart";
part 'src/controllers/user.dart';
part 'src/controllers/loaders.dart';
part 'src/controllers/state.dart';

Model model;
bool _changed = false;

String uri =
    'postgres://category.thilisar.cz:categorization@sql3.pipni.cz:5432/category.thilisar.cz';
//'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

void main(){
  model = new Model();
  loadServer();
  loadData().then((_){
    serve(9999);
  });
  _loadControllers();
  _saver();
}

void _saver(){
  if(_changed){
    Future<Connection> connection = connect(uri);
    connection.then((conn){
      conn.execute("""
    insert into "content" (content)
     values (@content)
    """,{
          "content": JSON.encode(model.toJson())
      });
    });
  }
  _changed = false;
  new Future.delayed(const Duration(seconds:1)).then((_){
    _saver();
  });
}

Future loadData(){
  Completer completer = new Completer();
  Future<Connection> connection = connect(uri);
  connection.then((conn) {
    conn.query("""
              select * from "content" order by inserted desc limit 1
          """).toList().then((List<Row> rows) {
     if(!rows.isEmpty){
       model.fromJson(JSON.decode(rows.first.toMap()["content"]));
     }
     conn.close();
     completer.complete(null);
    })
    .catchError((err){
      print('Query error: $err');
      conn.close();
    });
  });
  connection.catchError((e){
    print("connection error $e");
  });

  return completer.future;
}

//a(){
//
//  connect(uri).then((conn) {
//    conn.query("""
//              INSERT INTO "User"(
//            id, age, nick, password, email, gender, education, work)
//          VALUES (6, 25, 'aaa', 'aaa',  'aaa',  'aaa',  'aaa',  'aaa') RETURNING id;
//          """).toList().then((List<Row> rows) {
//      nextUserId = rows.first.toList().first.toInt() + 1;
//    }).then((event) {
//
//      return conn.close();
//    }) // Return connection to pool
//    .catchError((err) => print('Query error: $err'));
//    conn.close();
//  });
//
//  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');
//
//
////  SimpleSessionStore store = new SimpleSessionStore();
//  shelf.Middleware middle = sessionMiddleware(new SimpleSessionStore());
//
//  myRouter = router()..get("/db", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    writeDbRow(controller, request);
//    return new shelf.Response.ok(out);
//  }, middleware: middle);
//
//  myRouter.post("/save_user", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    request.readAsString().then((String data) {
//      User newUser = new User(nextUserId++);
//      newUser.fromJson(JSON.decode(data));
//      newUser.save().listen((code){print("save user $code");});
//      users.add(newUser);
//      Map mySession = session(request);
//      mySession.putIfAbsent("logged", () => newUser.id);
//      controller.add(const Utf8Codec().encode(JSON.encode(newUser.toJson())));
//      controller.close();
//    });
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/login", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    login(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/app_state", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    appState(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/get_problems", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    getProblems(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/get_problem", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    getProblem(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/solve_problem", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    solveProblem(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//  myRouter.post("/logout", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    logout(controller, request);
//    var headers = <String, String>{
//      HttpHeaders.CONTENT_TYPE: "text/json"
//    };
//    return new shelf.Response.ok(out, headers: headers);
//  }, middleware: middle);
//
//
//  shelf.Handler handler = new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
//  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
//    print('Serving at http://${server.address.host}:${server.port}');
//  });
//
//}
//
//
//void logout(StreamController controller, shelf.Request request) {
//  Map mySession = session(request);
//  mySession.remove("logged");
//  controller.add(const Utf8Codec().encode(JSON.encode({
//    "logout": true
//  })));
//  controller.close();
//}
//
//void solveProblem(StreamController controller, shelf.Request request) {
//  request.readAsString().then((String data) {
//    Map solutionData = JSON.decode(data);
//    var map = session(request);
//    if (map.containsKey('logged')) {
//      User actual = getUserById(map["logged"]);
//      if (actual != null) {
//        Solution solution = new Solution(actual, getProblemById(solutionData["mapId"]));
//        solution.fromData(solutionData);
//        connect(uri).then((conn) {
//          try {
//            conn.query("select * from \"Solution\" where id_problem=@problemId",{"problemId":solutionData["mapId"]}).toList().then((List<Row> rows) {
//              List out = [];
//              List<Map> solutions = [];
//              for (Row row in rows) {
//                solutions.add((new Solution(null, null)..fromJson(row.toMap())).toJson());
//              }
//              solutions.add(solution.toJson());
//              controller.add(const Utf8Codec().encode(JSON.encode({
//                "solutions": solutions
//              })));
//              controller.close();
//              conn.close();
//            });
//          } catch (e) {
//            closeAndPrintError("error in solution query", conn, controller);
//          }
//        });
//        new Future.delayed(const Duration(milliseconds:300)).then((_){
//          solution.save();
//        });
//      } else {
//        closeAndPrintError("user not logged in", null, controller);
//      }
//    } else {
//      closeAndPrintError("user not logged in", null, controller);
//    }
//
//  });
//}
//
//void getProblems(StreamController controller, shelf.Request request) {
//  connect(uri).then((conn) {
//    try {
//      conn.query("select * from \"Problem\"").toList().then((List<Row> rows) {
//        List out = [];
//        problems = [];
//        for (Row row in rows) {
//          problems.add(new Problem()..fromJson(row.toMap()));
//        }
//
//        for (Problem p in problems) {
//          out.add(p.toSimpleJson());
//        }
//        controller.add(const Utf8Codec().encode(JSON.encode({
//          "problems": JSON.encode(out)
//        })));
//        controller.close();
//        conn.close();
//      });
//    } catch (e) {
//      closeAndPrintError("error in problem query", conn, controller);
//    }
//  });
//}
//
//shelf.Handler middle(shelf.Handler innerHandler) {
//  sessionMiddleware(new SimpleSessionStore())(innerHandler);
//  shelf.logRequests()(innerHandler);
//  return innerHandler;
//}
//
//void writeDbRow(StreamController controller, shelf.Request request) {
//  var map = session(request);
//  var c = map['counter'];
//  int counter = (c == null ? 0 : c) + 1;
//  //store counter in the session
//  map['counter'] = counter;
//  connect(uri).then((conn) {
//    conn.query('select * from problem').toList().then((List<Row> rows) {
//      controller.add(const Utf8Codec().encode(rows.first.toString() + " " + counter.toString()));
//      controller.close();
//    });
//    conn.close();
//  });
//}
//
//void login(StreamController controller, shelf.Request request) {
//  request.readAsString().then((String data) {
//    Map user = JSON.decode(data);
//    connect(uri).then((conn) {
//      try {
//        conn.query("select * from \"User\" where nick = @nick and password=@password", {
//          "nick": user["nick"],
//          "password": user["password"]
//        }).toList().then((List<Row> rows) {
//          if (rows.length > 0) {
//            Map userData = rows.first.toMap();
//            int id = userData["id"];
//            User user = getUserById(id);
//            if (user == null) {
//              user = new User(id);
//              user.fromJson(userData);
//              users.add(user);
//            }
//            print("logged ${user.id} ${user.nick}");
//            Map mySession = session(request);
//            mySession.putIfAbsent("logged", () => user.id);
//            var map = session(request);
//            bool logged = map.containsKey('logged');
//
//            controller.add(const Utf8Codec().encode(JSON.encode({
//
//              "user": user.toJson(),
//              "logged": logged
//            })));
//          } else {
//            controller.add(const Utf8Codec().encode(JSON.encode({
//              "userNotFound": true
//            })));
//          }
//          controller.close();
//          conn.close();
//        });
//      } catch (e) {
//        closeAndPrintError("error in login query", conn, controller);
//      }
//    });
//  });
//}
//
//void appState(StreamController controller, shelf.Request request) {
//  var map = session(request);
//  bool logged = map.containsKey('logged');
//  print("app state logged $logged");
//  controller.add(const Utf8Codec().encode(JSON.encode({
//    "logged": logged,
//    "problemId": 1
//  })));
//  controller.close();
//}
//
//User getUserById(int id) {
//  for (User u in users) {
//    if (u.id == id) {
//      return u;
//    }
//  }
//  return null;
//}
//Problem getProblemById(int id) {
//  for (Problem p in problems) {
//    if (p.id == id) {
//      return p;
//    }
//  }
//  return null;
//}
//
//void getProblem(StreamController controller, shelf.Request request) {
//  request.readAsString().then((String data) {
//    Map mapData = JSON.decode(data);
//    connect(uri).then((conn) {
//      try {
//        conn.query("select * from \"Problem\"").toList().then((List<Row> rows) {
//
//          problems = [];
//          for (Row row in rows) {
//            problems.add(new Problem()..fromJson(row.toMap()));
//          }
//
//          Problem theChosenOne = getProblemById(mapData["mapId"]);
//
//          controller.add(const Utf8Codec().encode(JSON.encode({
//            "problem": theChosenOne
//          })));
//          controller.close();
//          conn.close();
//        });
//      } catch (e) {
//        closeAndPrintError("Error in problem query", conn, controller);
//      }
//    });
//  });
//}
//
//void closeAndPrintError(String error, Connection conn, StreamController controller) {
//  controller.add(const Utf8Codec().encode(JSON.encode({
//    "error": error
//  })));
//  controller.close();
//  if (conn != null) {
//    conn.close();
//  }
//}
