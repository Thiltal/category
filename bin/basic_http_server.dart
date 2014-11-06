import 'dart:io';
import 'dart:async' show runZoned;
import 'package:path/path.dart' show join, dirname;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'dart:async';
import 'package:postgresql/postgresql.dart';

void main() {

  runZoned((){
    var portEnv = Platform.environment['PORT'];
    var port = portEnv == null ? 9999 : int.parse(portEnv);
    HttpServer
         .bind(InternetAddress.ANY_IP_V4, port)
         .then((server) {
           server.listen((HttpRequest request) {
             String path = request.requestedUri.path;
             if(path=="/x"){
               request.response.write('hi');
               request.response.close();
             }else if(path == "/db"){
               var uri = 'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';
               connect(uri).then((conn) {
                 conn.query('select * from problem').toList().then((rows) {
                   print("selected $rows");
                     for (var row in rows) {
                         request.response.write(row.toString());
                         request.response.close();
                     }
                 });
               });
             }else{
               String pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'build/web');
               var handler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');
               io.handleRequest(request, handler);
             }
           });
         });
  },onError: (e){
    print("error $e");
  });
}


