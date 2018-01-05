part of category_model;


class Gravity {
  bool _running = false;
  static const int GRAVITY_RANGE_SQUARE = 1000000;
  int _maxHierarchyLevel = 1;
  int _frameTime = 50;
  SolveMap sm;

  Gravity(this.sm) {
    _frame(null);
  }

  void start() {
    _running = true;
  }

  void _frame(_) {
    if (!_running) {
      new Future.delayed(new Duration(milliseconds: _frameTime)).then(_frame);
      return;
    }

    _recalcHierarchy();

    num centerX = window.innerWidth / 2;
    num centerY = window.innerHeight / 2;

//    num outSum = 0;

    List<NodeGravityContainer> nodes = [];
    for (var n in sm.nodes) {
      nodes.add(new NodeGravityContainer(n));
    }

    for (var n in nodes) {
      for (var m in nodes) {
        if (m == n) continue;
        CatNode nn = n.node;
        CatNode mm = m.node;

        // repulsion
        var square = pow(nn.x - mm.x, 2) + pow(nn.y - mm.y, 2);
        if (square > GRAVITY_RANGE_SQUARE) continue;
        num distance = sqrt(square);
        var repulsion = 1500 - distance;
        if (repulsion < 10) repulsion = 10;
        if (distance == 0) distance = 10;

        num measure = -(repulsion / pow(distance, 1.5)) / 30;
        n.vectors.add(new Point((mm.x - nn.x) * measure / 2, (mm.y - nn.y) * measure));

        // attraction to central point
        num strength = 0.002;
        n.vectors.add(new Point((centerX - nn.x) * strength, (centerY - nn.y) * strength));

        // attraction of top for top hierarchy level

        n.vectors.add(
            new Point(
                0,
                (((_maxHierarchyLevel - n.node.hierarchyHeight + 1) * (window.innerHeight / (_maxHierarchyLevel + 1))) - nn.y) / 50));

      }
      num outX = 0;
      num outY = 0;

      for (Point p in n.vectors) {
        outX += p.x;
        outY += p.y;
      }

      n.node.x += outX.toInt();
      if (n.node.x > window.innerWidth - 100) {
        n.node.x = window.innerWidth - 100;
      }
      if (n.node.x < 0) {
        n.node.x = 0;
      }
      n.node.y += outY.toInt();
      if (n.node.y > window.innerHeight - 100) {
        n.node.y = window.innerHeight - 100;
      }
      if (n.node.y < 0) {
        n.node.y = 0;
      }
    }

    new Future.delayed(new Duration(milliseconds: _frameTime)).then(_frame);
  }

  void stop() {
    _running = false;
  }

  void _recalcHierarchy() {
    for (var node in sm.nodes) {
      if (node.children.length == 0) {
        node.hierarchyHeight = 1;
      } else {
        node.hierarchyHeight = null;
      }
    }
    int found = 1;
    while (found != 0) {
      found = 0;
      for (CatNode node in sm.nodes) {
        if (node.hierarchyHeight == null) {
          int max = 0;
          bool hierarchyKnown = true;
          for (var child in node.children) {
            if (child.hierarchyHeight != null) {
              if (child.hierarchyHeight > max) {
                max = child.hierarchyHeight;
              }
            } else {
              found++;
              hierarchyKnown = false;
            }
          }
          if (hierarchyKnown) {
            node.hierarchyHeight = max + 1;
            _maxHierarchyLevel = max + 1;
            for (var ch in node.children) {
              ch.hierarchyHeight = max;
            }
          }
        }
      }
    }

  }

}

class NodeGravityContainer {
  CatNode node;
  List<Point> vectors = [];

  NodeGravityContainer(this.node);
}
