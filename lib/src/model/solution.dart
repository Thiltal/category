part of category_model;

class Solution {
  String uid;
  String issueUid;
  List<String> nodes = [];
  List<String> joins = [];
  String solverUid;

  Map toMap(){
    Map out = {};
    out['uid'] = uid;
    out['issueUid'] = issueUid;
    out['nodes'] = nodes;
    out['joins'] = joins;
    out['solverUid'] = solverUid;
    return out;
  }

  void fromMap(Map data){
    uid = data['uid'];
    issueUid = data['issueUid'];
    nodes = data['nodes'];
    joins = data['joins'];
    solverUid = data['solverUid'];
  }
}
