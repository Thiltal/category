part of server;

class Problem{
  int id;
  String properties;
  String description;
  String taglist;
  
  Problem(this.id, this.properties, this.description, this.taglist);
  
  String toString()=>"$id $properties $description $taglist";
}