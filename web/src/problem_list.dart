part of categoryApp;

class ProblemList{
  List<Problem> problems = [];
  Element cont;
  
  ProblemList(this.cont){
    HttpRequest xhr = new HttpRequest();
      xhr
          ..open('POST', "/get_problems")
          ..onLoad.listen((ProgressEvent event) {
            Map data = JSON.decode(xhr.responseText);
            List<Map> problemList = JSON.decode(data["problems"]);
            for(Map m in problemList){
              problems.add(new Problem()..fromJson(m));
            }
            render();
          })
          ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
          ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
          ..send('{"getProblems": true}');
  }
  
  void render(){
    String out = "";
    for(Problem p in problems){
      out+="""
        <div id="problem${p.id}" class="problemRow">${p.description}</div>
""";
    }
    
    cont.innerHtml = out;
    ElementList problemList = cont.querySelectorAll(".problemRow");
    
    for(Element e in problemList){
     e.onClick.listen((e){
       int id = int.parse((e.target.id as String).replaceAll("problem",""));
       categoryApp.jumpToMap(id);
     }); 
    }
  }
}

class Problem{
  int id;
  String properties;
  String description;
  String taglist;
  
  Problem();
  
  String toString()=>"$id $properties $description $taglist";
  
  void fromJson(Map json){
    id = json["id"];
    description = json["description"];
    if(json.containsKey("properties")){
      properties = json["properties"];      
    }
    if(json.containsKey("taglist")){
      taglist = json["taglist"];      
    }
  }
  
  Map toJson(){
    Map out = {};
    out["id"] = id;
    out["description"] = description;
    if(properties!=null){
      out["properties"] = properties;      
    }
    if(taglist!=null){
      out["taglist"] = taglist;      
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