part of server;

class Problems{
  bool changed = false;
  List<Problem> list = [];
  static int lastProblemId = 0;

  void fromJson(List json){
    for(Map problem in json){
      list.add(new Problem()..fromJson(problem));
    }
  }

  List toJson(){
    List out = [];
    for(Problem p in list){
      out.add(p.toJson());
    }
    return out;
  }


  Problem getProblemById(int id) {
    for (Problem p in list) {
      if (p.id == id) {
        return p;
      }
    }
    return null;
  }
}

class Problem{
  int id;
  String properties;
  String description;
  String tagList;
  List<Solution> solutions = [];
  
  Problem();
  
  String toString()=>"$id $properties $description $tagList";
  
  void fromJson(Map json){
    id = json["id"];
    properties = json["properties"];
    description = json["description"];
    tagList = json["taglist"];
    solutions = [];
    for(Map s in json["solutions"]){
      solutions.add(new Solution(model.getUserById(s["id_user"]), this)..fromJson(s));
    }
  }
  
  Map toJson(){
    Map out = {};
    out["id"] = id;
    out["properties"] = properties;
    out["description"] = description;
    out["taglist"] = tagList;
    out["solutions"] = [];
    for(Solution s in solutions){
      out["solutions"].add(s.toJson());
    }
    return out;
  }
  
  Map toSimpleJson(){
    return {
      "id": id,
      "description": description
    };
  }
}