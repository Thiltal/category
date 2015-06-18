part of server;

class Solution {
  User user;
  // user ID is for data transfer
  int userId;
  Problem problem;
  int problemId;
  List<Join> solution;
  int startTime;
  int endTime;

  Solution(this.user, this.problem);

  void fromData(Map data) {
    startTime = data["startTime"];
    endTime = data["endTime"];
    List<Map> joinsData = data["joins"];
    solution = [];
    for (Map m in joinsData) {
      solution.add(new Join()
          ..parent = m["parent"]
          ..child = m["child"]);
    }
  }

//  Stream<int> save() {
//    StreamController controller = new StreamController();
//    Stream<int> out = controller.stream;
//    connect(uri).then((conn) {
//      Map out = toJson();
//      try {
//        conn.execute("INSERT INTO \"Solution\"(id_user, id_problem, solution, start_time, end_time) VALUES (@user_id, @problem_id, @solution, @start_time, @end_time)",
//            out).then((int code) {
//          controller.add(code);
//          controller.close();
//        }).then((int code){
//          print("probelm saved with code $code");
//          conn.close();
//        });
//      } catch (e) {
//        conn.close();
//        controller.add(404);
//        controller.close();
//      }
//    });
//
//    return out;
//  }

  Map toJson() {
    Map out = {};
    if(user!=null){
      out["id_user"] = user.id;      
    }else{
      out["id_user"] = userId;            
    }
    if(problem !=null){
      out["problem_id"] = problem.id;      
    }else{
      out["problem_id"] = -1;
    }
    out["start_time"] = startTime;
    out["end_time"] = endTime;
    out["solution"] = JSON.encode(joinsToJson());
    return out;
  }

  List joinsToJson() {
    List out = [];
    for (Join j in solution) {
      out.add(j.toJson());
    }
    return out;
  }
  
  fromJson(Map json) {
    startTime = json["start_time"];
       endTime = json["end_time"];
       userId = json["id_user"];
       
       List<Map> joinsData = JSON.decode(json["solution"]);
       solution = [];
       for (Map m in joinsData) {
         solution.add(new Join()
             ..parent = m["parent"]
             ..child = m["child"]);
       }
  }
}

class Join {
  String parent;
  String child;

  Map toJson() {
    Map out = {};
    out["parent"] = parent;
    out["child"] = child;
    return out;
  }
}
