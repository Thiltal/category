part of server;

class Problem{
  int id;
  String properties;
  String description;
  String taglist;
  
  Problem();
  
  String toString()=>"$id $properties $description $taglist";
  
  void fromJson(Map json){
    id = json["id"];
    properties = json["properties"];
    description = json["description"];
    taglist = json["taglist"];
  }
  
  Map toJson(){
    Map out = {};
    out["id"] = id;
    out["properties"] = properties;
    out["description"] = description;
    out["taglist"] = taglist;
    return out;
  }
  
  Map toSimpleJson(){
    return {
      "id": id,
      "description": description
    };
  }
}