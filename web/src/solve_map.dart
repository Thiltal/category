part of categoryApp;

class SolveMap {
  List<CatNode> nodes = [];
  List<OnFrame> onFrames = [];
  Gravity gravity;
  int id;

  static Random random = new Random(333);
  static int getRandomInt(int max) {
    return random.nextInt(max);
  }

  SolveMap(int mapId) {
    id = mapId;
    HttpRequest xhr = new HttpRequest();
    xhr
        ..open('POST', "/get_problem")
        ..onLoad.listen((ProgressEvent event) {
          initCanvas();
          Map data = JSON.decode(xhr.responseText);
          Map problem = data["problem"];
          Problem actual = new Problem()..fromJson(problem);
          List<String> nodes = actual.properties.split(",");
          for (String s in nodes) {
            this.nodes.add(new CatNode(s));
          }
          gravity = new Gravity();
          gravity.start();
          _startTime = new DateTime.now().millisecondsSinceEpoch;
          onFrame(null);

        })
        ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
        ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
        ..send('{"mapId": $mapId}');
  }

  void initCanvas() {
    CanvasElement _canvas = querySelector("#mapCanvas");
    _canvas.width = window.innerWidth;
    _canvas.height = window.innerHeight;
    document.body.style
        ..width = "${window.innerWidth}px"
        ..height = "${window.innerHeight}px";
    canvas = new MapCanvas(_canvas);
    querySelector("#sendMapSolution").onClick.listen((e) {
      saveState();
    });
  }

  Map nodesToJson() {
    List all = [];
    List joins = [];
    for (var n in nodes) {
      all.add(n.label);
      if (n.parentNode != null) {
        joins.add({
          "parent": n.parentNode.label,
          "child": n.label
        });
      }
    }
    return {
      "all": all,
      "joins": joins
    };
  }

  void saveState() {
    Map json = nodesToJson();
    json["startTime"] = _startTime;
    json["endTime"] = new DateTime.now().millisecondsSinceEpoch;
    json["mapId"] = id;
    String out = JSON.encode(json);
    print(out);
    HttpRequest xhr = new HttpRequest();
    xhr
        ..open('POST', "/solve_problem")
        ..onLoad.listen((ProgressEvent event) {
          categoryApp.jumpToFeedback(JSON.decode(xhr.responseText));
        })
        ..setRequestHeader("X-Requested-With", "XMLHttpRequest")
        ..setRequestHeader("Content-Type", "text/json; charset=UTF-8")
        ..send(out);
  }
  int _startTime;
//  int _frames = 0;
  void onFrame(double frame) {
    for (OnFrame f in onFrames) {
      f();
    }
    window.requestAnimationFrame(onFrame);
  }

  Rect borders() {
    int x = 1500;
    int y = 1500;
    int xx = 0;
    int yy = 0;

    for (CatNode n in nodes) {
      if (x > n.x) x = n.x;
      if (y > n.y) y = n.y;
      if (xx < n.x) xx = n.x;
      if (yy < n.y) yy = n.y;
    }
    return new Rect(x, y, xx - x + nodes.first.cont.width, yy - y + nodes.first.cont.height);
  }



  void repaint() {
  }

  void removeFromChildrens(CatNode toRemove) {
    for (CatNode node in nodes) {
      if (node.children.remove(toRemove)) ;
    }
  }
}
