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
//import 'package:postgresql/pool.dart';

part 'src/problem.dart';
part 'src/user.dart';
part 'src/solution.dart';

List<Problem> problems = [];
List<User> users = [];
//Pool pool;
Router myRouter;
int nextUserId = 1;

String uri =
'https://drive.google.com/file/d/0B4fjt_EsjP7UOTE0ZmhqSzJrWjQ/view?usp=sharing';
//'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

void main() {

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'web');



  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');


//  SimpleSessionStore store = new SimpleSessionStore();
  shelf.Middleware middle = sessionMiddleware(new SimpleSessionStore());

  myRouter = router()..get("/db", (shelf.Request request) {
//    StreamController controller = new StreamController();
//    Stream<List<int>> out = controller.stream;
//    writeDbRow(controller, request);
    return new shelf.Response.ok("db");
  }, middleware: middle);

  shelf.Handler handler = new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

}