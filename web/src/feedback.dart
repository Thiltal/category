part of categoryApp;

class Feedback {
  List<Solution> solutions;
  Element cont;
  Feedback(this.cont,Map solutionsData){
    List<Map> data = solutionsData["solutions"];
    solutions = [];
    for(Map m in data){
      solutions.add(new Solution()..fromJson(m));
    }
    render();
  }
  
  
  double conformityLevel(Solution your){
    int total = 0;
    int match = 0;
    for(Solution s in solutions){
      if(s!=your){
        for(Join j in s.solution){
          for(Solution s2 in solutions){
            if(s2!=your && s2!=s){
              bool matches = false;
              for(Join j2 in s2.solution){
                if(j.parent==j2.parent && j.child==j2.child){
                  matches = true;
                }
              }
              total++;
              if(matches){
                match++;
              }
            }
          }
        }
      }
    }
    return match/total*100;
  }
  
  void render(){
    int maxTime=0;
    int sumTime = 0;
    
    for(Solution s in solutions){
       if(s.time>maxTime){
         maxTime = s.time;
       }
       sumTime+=s.time;
    }
    String out = """
        <h1>Solution feedback</h1>
        <span>Number of solutions: ${solutions.length}</span><br>
        <span>Conformity level: ${conformityLevel(solutions.last).toStringAsFixed(2)}</span><br>
        <span>Your solution time: ${solutions.last.time}</span><br>
        <span>Average time: ${sumTime~/solutions.length}</span><br>
        <span>Maximal time: $maxTime</span><br>        
        <button id="anotherIssue">Another issue</button>
    """;
    cont.innerHtml = out;
    cont.querySelector("#anotherIssue").onClick.listen((_){
      window.location.reload();
    });
  }

}

class Solution {
  int userId;
  Problem problem;
  List<Join> solution;
  int startTime;
  int endTime;
  int get time=>(endTime-startTime)~/1000;

  void fromJson(Map json) {
    startTime = json["start_time"];
    endTime = json["end_time"];
    userId = json["user_id"];
    List<Map> joinsData = JSON.decode(json["solution"]);
    solution = [];
    for (Map m in joinsData) {
      solution.add(new Join()
          ..parent = m["parent"]
          ..child = m["child"]);
    }
  }

  Map toJson() {
    Map out = {};
    out["problemId"] = problem.id;
    out["startTime"] = startTime;
    out["endTime"] = endTime;
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
