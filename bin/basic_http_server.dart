import 'dart:io';
import 'dart:async' show runZoned;
import 'package:path/path.dart' show join, dirname;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'dart:async';
import 'package:sqljocky/sqljocky.dart';

void main() {

  runZoned((){
    HttpServer
         .bind(InternetAddress.ANY_IP_V4, 9999)
         .then((server) {
           server.listen((HttpRequest request) {
             String path = request.requestedUri.path;
             if(path=="/x"){
               request.response.write('hi');
               request.response.close();
             }else if(path == "/db"){
               var pool = new ConnectionPool(host: 'sql13.pipni.cz', port: 3306, user: 'cat.thilisar.cz',password: "category", db: 'cat_thilisar_cz', max: 5);
                     var result = pool.query("select * from Problem");
                       result.then((Results data) {
                         data.first.then((Row row) {
                           request.response.write(row.toString());
                           request.response.close();
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


