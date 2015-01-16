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
import 'package:postgresql/pool.dart';

part 'problem.dart';
part 'user.dart';
part 'solution.dart';

List<Problem> problems = [];
List<User> users = [];
//Pool pool;
Router myRouter;
int nextUserId = 1;

String uri =
    'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

void main() {

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'web');

//  pool = new Pool(uri, minConnections: 1, maxConnections: 10,
//      idleTimeout: const Duration(seconds:100),
//      maxLifetime: const Duration(seconds:300),
//      leakDetectionThreshold:const Duration(seconds:300));
//  pool.messages.listen(print);
//  pool.start().then((_) {
//    pool.connect().then((conn) {
//      conn.query("""
//              select max(id) from "User"
//          """).toList().then((List<Row> rows) {
//        nextUserId = rows.first.toList().first.toInt() + 1;
//      }).then((event) {
//
//        return conn.close();
//      }) // Return connection to pool
//      .catchError((err) => print('Query error: $err'));
//      conn.close();
//    });
//  });

  connect(uri).then((conn) {
    conn.query("""
              select max(id) from "User"
          """).toList().then((List<Row> rows) {
      nextUserId = rows.first.toList().first.toInt() + 1;
    }).then((event) {

      return conn.close();
    }) // Return connection to pool
    .catchError((err) => print('Query error: $err'));
    conn.close();
  });

  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');


//  SimpleSessionStore store = new SimpleSessionStore();
  shelf.Middleware middle = sessionMiddleware(new SimpleSessionStore());

  myRouter = router()..get("/db", (shelf.Request request) {
        StreamController controller = new StreamController();
        Stream<List<int>> out = controller.stream;
        writeDbRow(controller, request);
        return new shelf.Response.ok(out);
      }, middleware: middle);

  myRouter.post("/save_user", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    request.readAsString().then((String data) {
      User newUser = new User(nextUserId++);
      newUser.fromJson(JSON.decode(data));
      newUser.save();
      users.add(newUser);
      Map mySession = session(request);
      mySession.putIfAbsent("logged", () => newUser.id);
      controller.add(const Utf8Codec().encode(JSON.encode(newUser.toJson())));
      controller.close();
    });
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);

  myRouter.post("/login", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    login(controller, request);
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);

  myRouter.post("/app_state", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    appState(controller, request);
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);

  myRouter.post("/get_problems", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    getProblems(controller, request);
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);

  myRouter.post("/get_problem", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    getProblem(controller, request);
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);

  myRouter.post("/solve_problem", (shelf.Request request) {
    StreamController controller = new StreamController();
    Stream<List<int>> out = controller.stream;
    solveProblem(controller, request);
    var headers = <String, String>{
      HttpHeaders.CONTENT_TYPE: "text/json"
    };
    return new shelf.Response.ok(out, headers: headers);
  }, middleware: middle);


  shelf.Handler handler = new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

}

void solveProblem(StreamController controller, shelf.Request request) {
  request.readAsString().then((String data) {
    Map solutionData = JSON.decode(data);
    var map = session(request);
    if (map.containsKey('logged')) {
      User actual = getUserById(map["logged"]);
      if (actual != null) {
        Solution solution = new Solution(actual, getProblemById(solutionData["mapId"]));
        solution.fromData(solutionData);
        solution.save();
        connect(uri).then((conn) {
          try {
            conn.query("select * from \"Solution\"").toList().then((List<Row> rows) {
              List out = [];
              List<Map> solutions = [];
              for (Row row in rows) {
                solutions.add(row.toMap());
              }
              controller.add(const Utf8Codec().encode(JSON.encode({
                "solutions": solutions
              })));
              controller.close();
              conn.close();
            });
          } catch (e) {
            closeAndPrintError("error in solution query", conn, controller);
          }
        });
      } else {
        closeAndPrintError("user not logged in", null, controller);
      }
    } else {
      closeAndPrintError("user not logged in", null, controller);
    }

  });
}

void getProblems(StreamController controller, shelf.Request request) {
  connect(uri).then((conn) {
    try {
      conn.query("select * from \"Problem\"").toList().then((List<Row> rows) {
        List out = [];
        problems = [];
        for (Row row in rows) {
          problems.add(new Problem()..fromJson(row.toMap()));
        }

        for (Problem p in problems) {
          out.add(p.toSimpleJson());
        }
        controller.add(const Utf8Codec().encode(JSON.encode({
          "problems": JSON.encode(out)
        })));
        controller.close();
        conn.close();
      });
    } catch (e) {
      closeAndPrintError("error in problem query", conn, controller);
    }
  });
}

shelf.Handler middle(shelf.Handler innerHandler) {
  sessionMiddleware(new SimpleSessionStore())(innerHandler);
  shelf.logRequests()(innerHandler);
  return innerHandler;
}

void writeDbRow(StreamController controller, shelf.Request request) {
  var map = session(request);
  var c = map['counter'];
  int counter = (c == null ? 0 : c) + 1;
  //store counter in the session
  map['counter'] = counter;
  connect(uri).then((conn) {
    conn.query('select * from problem').toList().then((List<Row> rows) {
      controller.add(const Utf8Codec().encode(rows.first.toString() + " " + counter.toString()));
      controller.close();
    });
    conn.close();
  });
}

void login(StreamController controller, shelf.Request request) {
  request.readAsString().then((String data) {
    Map user = JSON.decode(data);
    connect(uri).then((conn) {
      try {
        conn.query("select * from \"User\" where nick = @nick and password=@password", {
          "nick": user["nick"],
          "password": user["password"]
        }).toList().then((List<Row> rows) {
          if (rows.length > 0) {
            Map userData = rows.first.toMap();
            int id = userData["id"];
            User user = getUserById(id);
            if (user == null) {
              user = new User(id);
              user.fromJson(userData);
              users.add(user);
            }
            print("logged ${user.id} ${user.nick}");
            Map mySession = session(request);
            mySession.putIfAbsent("logged", () => user.id);
            var map = session(request);
            bool logged = map.containsKey('logged');

            controller.add(const Utf8Codec().encode(JSON.encode({

              "user": user.toJson(),
              "logged": logged
            })));
          } else {
            controller.add(const Utf8Codec().encode(JSON.encode({
              "userNotFound": true
            })));
          }
          controller.close();
          conn.close();
        });
      } catch (e) {
        closeAndPrintError("error in login query", conn, controller);
      }
    });
  });
}

void appState(StreamController controller, shelf.Request request) {
  var map = session(request);
  bool logged = map.containsKey('logged');
  print("app state logged $logged");
  controller.add(const Utf8Codec().encode(JSON.encode({
    "logged": logged,
    "problemId": 1
  })));
  controller.close();
}

User getUserById(int id) {
  for (User u in users) {
    if (u.id == id) {
      return u;
    }
  }
  return null;
}
Problem getProblemById(int id) {
  for (Problem p in problems) {
    if (p.id == id) {
      return p;
    }
  }
  return null;
}

void getProblem(StreamController controller, shelf.Request request) {
  request.readAsString().then((String data) {
    Map mapData = JSON.decode(data);
    connect(uri).then((conn) {
      try {
        conn.query("select * from \"Problem\"").toList().then((List<Row> rows) {

          problems = [];
          for (Row row in rows) {
            problems.add(new Problem()..fromJson(row.toMap()));
          }

          Problem theChosenOne = getProblemById(mapData["mapId"]);

          controller.add(const Utf8Codec().encode(JSON.encode({
            "problem": theChosenOne
          })));
          controller.close();
          conn.close();
        });
      } catch (e) {
        closeAndPrintError("Error in problem query", conn, controller);
      }
    });
  });
}

void closeAndPrintError(String error, Connection conn, StreamController controller) {
  controller.add(const Utf8Codec().encode(JSON.encode({
    "error": error
  })));
  controller.close();
  if (conn != null) {
    conn.close();
  }
}
