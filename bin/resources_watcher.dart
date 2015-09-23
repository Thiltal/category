library watcher;

import "dart:io";
import "dart:async";
import "dart:convert";
import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as Path;

bool changed = false;
Map structure;
Map config;
int counter = 0;
List<String> classes;

void main(){
  Directory dir = new Directory("resources");
  dir.watch(recursive:true).listen((e){
    changed = true;
  });
  check();
  config = JSON.decode(new File("resources/config.json").readAsStringSync());
}

void check(){
  if(changed){
    changed = false;
    generate();
    print("generate");
  }
  new Future.delayed(const Duration(seconds:1)).then((_)=> check());
}

void generate(){
  structure = getFolder("resources");
  File outFile = new File("resources/module.json")
    ..createSync(recursive:true);
  outFile.writeAsStringSync(JSON.encode(structure));

  File outFile2 = new File("web/resources/module.json")
    ..createSync(recursive:true);
  outFile2.writeAsStringSync(JSON.encode(structure));

  new Future.delayed(const Duration(milliseconds: 100)).then((_){
    changed = false;
  });
  print("out file written");
  createStructureClass(structure);
}

void createStructureClass(Map structure){
  counter = 0;
  classes = [];
  String out = "part of ${config["library"]};\n";
  createMapClass("GeneratedResources", structure);
  for(String s in classes){
    out += "$s\n";
  }
  File outFile = new File("lib/resources.dart")
    ..createSync(recursive:true);
  outFile.writeAsStringSync(out);
}

String createMapClass(String name, Map map){
  print("create class $name");
  String out = "class $name{\n";
  String fromJson = "";
  String toJson = "";
  map.forEach((k, v){
    String className;
    if(v is Map){
      className = "Xr${counter++}$k";
      createMapClass(className, v);
      out += "$className $k; \n";
      fromJson += "$k = new $className()..fromJson(json['$k']); \n";
      toJson += "out['$k'] = $k.toJson();\n";
    }else{
      out += "${getType(v)} $k; \n";
      fromJson += "$k = json['$k']; \n";
      toJson += "out['$k'] = $k;\n";
    }
  });
  out += "Map toJson(){\nMap out = {};\n$toJson\nreturn out;\n}\n";
  out += "void fromJson(Map json){\n$fromJson}\n}\n";

  classes.add(out);
  return out;
}

String getType(Object value){
  if(value is Map)return "Map";
  if(value is String)return "String";
  return value.runtimeType.toString();
}

Map getFolder(String path){
  print("getFolder $path");
  Map out = {};
  Directory dir = new Directory(path);

  for(FileSystemEntity f in dir.listSync()){
    if(f.path.contains("module"))continue;
    if(f.path.contains("config"))continue;
    if(FileSystemEntity.isFileSync(f.path)){
      print("is file ${f.path}");
      File file = new File(f.path);
      out[Path.basenameWithoutExtension(f.path)] = parseFile(file);
    }else if(FileSystemEntity.isDirectorySync(f.path)){
      print("is directory ${f.path}");
      out[Path.basenameWithoutExtension(f.path)] = getFolder(f.path);
    }
  }
  return out;
}

dynamic parseFile(File file){
  String ext = Path.extension(file.path);
  if(ext == ".json"){
    String content;
    try{
      content = file.readAsStringSync();
    }catch(e){
      print(e);
      return "{'error':'invalidJson'}";
    }
    var json;
      try{
        json = JSON.decode(content);
    }catch(e){
      return "{'error':'invalidJson'}";
    }
    return json;
  }else if(ext == ".jpg" || ext == ".png" || ext == ".jpeg" || ext == ".gif"){
      return "data:image/${ext.replaceAll(".","")};base64,${crypto.CryptoUtils.bytesToBase64(file.readAsBytesSync())}";
  }
  String out;
  try{
    out = file.readAsStringSync();
  }catch(e){
    out = "read_error";
  }
  return out;
}