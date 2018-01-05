part of category_model;

class Issue {
  String uid;
  String name;
  String createdByUid;
  bool solvedByLoggedUser = false;
  List<String> nodes = [];

  void fromMap(Map data) {
    uid = data["uid"];
    name = data["name"];
    createdByUid = data["createdByUid"];
    nodes = data["nodes"];
  }

  Map toMap() {
    Map out = {};
    out["uid"] = uid;
    out["name"] = name;
    out["createdByUid"] = createdByUid;
    out["nodes"] = nodes;
    return out;
  }
}
