part of categoryApp;

class Feedback {
  List<Solution> solutions;
  Element cont;
  Feedback(this.cont, Map solutionsData) {
    List<Map> data = solutionsData["solutions"];
    if (data == null) {
      categoryApp.jumpToLogin();
      return;
    }
    solutions = [];
    for (Map m in data) {
      solutions.add(new Solution()..fromJson(m));
    }
    render();
  }


  double conformityLevel(Solution your) {
    int total = 0;
    int match = 0;
    List<double> conformities = [];
    int joins = your.solution.length;
    for (Solution s in solutions) {
      if (s == your) continue;
      // take max joins
      int subTotal;
      if (s.solution.length > joins) {
        subTotal = s.solution.length;
      } else {
        subTotal = joins;
      }
      int found = 0;
      for (Join j in s.solution) {
        for (Join j2 in your.solution) {
          if (j.match(j2)) {
            found++;
          }
        }
      }
      conformities.add(found / subTotal);
    }
    double confSum = 0.0;
    for(int a in conformities){
      confSum+=a;
    }
    
    if (conformities.length == 0) {
      return null;
    }
    double result = confSum / conformities.length * 100;
    return result;
  }

  void render() {
    int maxTime = 0;
    int sumTime = 0;

    for (Solution s in solutions) {
      if (s.time > maxTime) {
        maxTime = s.time;
      }
      sumTime += s.time;
    }
    double conformity = conformityLevel(solutions.last);
    String out = """
<div>
        <h1>Feedback</h1>
        <span class="conformity_level">Conformity level: ${conformity==null?"Your result is first one":conformity.toStringAsFixed(2)}</span><br>
        <span>Number of solutions: ${solutions.length}</span><br>
        <button id="anotherIssue">Another issue</button>
</div>
    """;
    cont.innerHtml = out;
    cont.querySelector("#anotherIssue").onClick.listen((_) {
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
  int get time => (endTime - startTime) ~/ 1000;

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

  bool match(Join j2) {
    return parent == j2.parent && child == j2.child;
  }
}
