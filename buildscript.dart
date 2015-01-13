import 'dart:io';
import 'dart:async';

void main(List<String> args) {
  File js = new File("web/index.dart.js");
  File js2 = new File("web/index.dart.js.map");
  File js3 = new File("web/index.dart.precompiled.js");
  Future.wait([js.exists().then((exist) {
      if (exist) {
        js.delete();
      }
    }), js2.exists().then((exist) {
      if (exist) {
        js2.delete();
      }
    }), js3.exists().then((exist) {
      if (exist) {
        js3.delete();
      }
    })]).then((result){
    Process.run(
        "c:/dart/editor/dart-sdk/bin/dart2js.bat",
        [
            "--out=web/index.dart.js",
            "--minify",
            "--trust-type-annotations",
            "--trust-primitives",
            "web/index.dart"]).then((ProcessResult result) {
      print(result.stdout);
    });    
  });

}
