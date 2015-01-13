library server;

import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' show join, dirname;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_simple_session/shelf_simple_session.dart';
import 'dart:async';
import 'dart:convert';
import 'package:postgresql/postgresql.dart';

part 'problem.dart';

List<Problem> problems = [];

String uri =
    'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

void main() {

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  var pathToBuild = join(dirname(Platform.script.toFilePath()),
  '..', 'web');
  
  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');


  var myRouter = router()..get("/db", (shelf.Request request) {
        StreamController controller = new StreamController();
        Stream<List<int>> out = controller.stream;
        writeDbRow(controller, request);
        return new shelf.Response.ok(out);
      }, middleware: sessionMiddleware(new SimpleSessionStore()));

  shelf.Handler handler = new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
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
      controller.add(const Utf8Codec().encode(rows.first.toString() +" "+ counter.toString()));
      controller.close();
    });
  });
}