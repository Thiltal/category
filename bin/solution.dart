part of server;

class Solution{
  User user;
  Problem problem;
  List<Join> solution;
  int startTime;
  int endTime;
  
  Solution(this.user, this.problem);
  
  void fromData(Map data){
    startTime = data["startTime"];
    endTime = data["endTime"];
    List<Map> joinsData = data["joins"];
    solution = [];
    for(Map m in joinsData){
      solution.add(new Join()..parent=m["parent"]..child=m["child"]);
    }
  }
  
  Stream<int> save() {
     StreamController controller = new StreamController();
     Stream<int> out = controller.stream;
     pool.connect().then((conn) {
       conn.execute("""
     INSERT INTO "Solution"(
            id_user, id_problem, solution, start_time, end_time)
    VALUES (@userId, @problemId, @solution, @startTime, @endTime)
     """, toJson()).then((int code) {
         controller.add(code);
         controller.close();
       });
       conn.close();
     });
     
     return out;
   }
  
  Map toJson(){
    Map out = {};
    out["userId"] = user.id;
    out["problemId"] = problem.id;
    out["startTime"] = startTime;
    out["endTime"] = endTime;
    out["solution"] = JSON.encode(joinsToJson());
    return out;
  }
  
  List joinsToJson() {
    List out = [];
    for(Join j in solution){
      out.add(j.toJson());
    }
    return out;
  }
}

class Join{
  String parent;
  String child;
  
  Map toJson() {
    Map out = {};
    out["parent"] = parent;
    out["child"] = child;
    return out;
  }
}