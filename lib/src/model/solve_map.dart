part of category_model;

class SolveMap {
  Issue issue;
  CanvasElement _canvas;
  MapCanvas canvas;
  List<CatNode> nodes = [];
  Gravity gravity;
  int id;
  List<Function> onFrames = [];
  int _startTime;
  static Random random = new Random(333);
  static int getRandomInt(int max) {
    return random.nextInt(max);
  }

  SolveMap(this.issue, this._canvas) {
    issue.nodes.forEach((node){
      nodes.add(new CatNode(node, this));
    });
    canvas = new MapCanvas(_canvas, this, window.innerWidth, window.innerHeight - 100);
    gravity = new Gravity(this);
    gravity.start();
    _startTime = new DateTime.now().millisecondsSinceEpoch;
    onFrame(null);
  }

  Solution getSolution() {
    Solution solution = new Solution();
    for (var n in nodes) {
      solution.nodes.add(n.label);
      if (n.parentNode != null) {
        solution.joins.add("${n.parentNode.label}>${n.label}");
      }
    }
    return solution;
  }

  void onFrame(double frame) {
    for (Function f in onFrames) {
      f();
    }
    window.requestAnimationFrame(onFrame);
  }

  Rect borders() {
    int x = 1500;
    int y = 1500;
//    int x = canvas.canvasWidth;
//    int y = canvas.canvasHeight;
    int xx = 0;
    int yy = 0;

    for (CatNode n in nodes) {
      if (x > n.x) x = n.x;
      if (y > n.y) y = n.y;
      if (xx < n.x) xx = n.x;
      if (yy < n.y) yy = n.y;
    }
    return new Rect(x, y, xx - x + nodes.first.cont.width,
        yy - y + nodes.first.cont.height);
  }

  void repaint() {}

  void removeChild(CatNode toRemove) {
    for (CatNode node in nodes) {
      if (node.children.remove(toRemove)) ;
    }
  }
}
