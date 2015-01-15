part of categoryApp;

class MapCanvas {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CatNode _hover;
  /// which on hover end
  CatNode targetedNode;
  int _moveStartX;
  int _moveStartY;
  int _nodeStartX;
  int _nodeStartY;
  CanvasElement background;

  MapCanvas(this.canvas) {
    ctx = canvas.context2D;
    sm.onFrames.add(repaint);
    canvas.onMouseDown.listen(_hoverStart);
    canvas.onMouseMove.listen(_hoverMove);
    canvas.onMouseUp.listen(_hoverEnd);
    canvas.onMouseOut.listen(_hoverEnd);
    background = new CanvasElement(width: window.innerWidth, height: window.innerHeight);
    var bgctx = background.context2D;
    bgctx.fillStyle = "white";
    bgctx.fillRect(0, 0, window.innerWidth, window.innerHeight);
  }

  int _cycles = 0;
  void repaint() {

    if (_cycles++ % 60 == 0) {
      int width = window.innerWidth;
      int height = window.innerHeight;
      ctx.clearRect(0, 0, width, height);
    }else{
      Rect borders = sm.borders();
      ctx.clearRect(borders.x - 80, borders.y - 80, borders.width + 160, borders.height + 160);      
    }


    for (CatNode n in sm.nodes) {
      if (n.parentNode != null) {
        paintLine(n);
      }
    }
    for (CatNode n in sm.nodes) {
      paintNode(n);
    }
  }

  void paintLine(CatNode node) {
    ctx.beginPath();
    ctx.moveTo(node.pivotX, node.pivotY);
    ctx.lineTo(node.parentNode.pivotX, node.parentNode.pivotY);
    ctx.stroke();
    ctx.closePath();
  }

  void paintNode(CatNode node) {
    node.recalc();
    ctx.fillStyle = "white";
    ctx.fillRect(node.x, node.y, node.cont.width, node.cont.height);
    ctx.strokeStyle = "black";
    ctx.strokeRect(node.x, node.y, node.cont.width, node.cont.height);
    ctx.fillStyle = "black";
    ctx.font = "14px Arial";
    ctx.fillText(node.label, node.x + 10, node.y + 17);
    if (node.isChildPinActive) {
      Rect child = node.childPin;
      ctx.fillStyle = "yellow";
      ctx.fillRect(child.x, child.y, child.width, child.height);
    }
    if (node.isParentPinActive) {
      Rect parent = node.parentPin;
      ctx.fillStyle = "yellow";
      ctx.fillRect(parent.x, parent.y, parent.width, parent.height);
    }

    if (node.pinChildVisible) {
      Rect child = node.childPin;
      ctx.strokeRect(child.x, child.y, child.width, child.height);
    }
    if (node.pinParentVisible) {
      Rect parent = node.parentPin;
      ctx.strokeRect(parent.x, parent.y, parent.width, parent.height);
    }
  }


  void _hoverStart(MouseEvent e) {
    e.preventDefault();
    Point page = e.page;
    int x = page.x.toInt();
    int y = page.y.toInt();
    _hover = _findNode(x, y);
    if (_hover != null) {


      sm.gravity.stop();
      _moveStartX = e.page.x.toInt();
      _moveStartY = e.page.y.toInt();
      _nodeStartX = _hover.x;
      _nodeStartY = _hover.y;
      _hover.moving = true;
    }
  }

  void _hoverMove(MouseEvent e) {
    Point page = e.page;
    int x = page.x.toInt();
    int y = page.y.toInt();
    if (_hover == null) {
      var mouseOn = _findNode(x, y);
      if(mouseOn!=null){
        canvas.style.cursor="pointer";
      }else{
        canvas.style.cursor="";
      }
      return;
    }
    _hover.x = (x - _moveStartX) + _nodeStartX;
    _hover.y = (y - _moveStartY) + _nodeStartY;

    List<CatNode> targetNodes = [];
    for (CatNode n in sm.nodes) {

      if (n == _hover) {
        n.pinChildVisible = false;
        n.pinParentVisible = false;
        continue;
      }


      n.parentMatchArea = _hover.getArea(n.parentPin);
      n.isParentPinActive = false;

      n.childMatchArea = _hover.getArea(n.childPin);
      n.isChildPinActive = false;


      targetNodes.add(n);


      num distance = sqrt(pow(_hover.x - n.x, 2) + pow(_hover.y - n.y, 2));
      if (distance < 200) {
        n.pinChildVisible = true;
        n.pinParentVisible = true;
      } else {
        n.pinChildVisible = false;
        n.pinParentVisible = false;
      }

    }
    targetNodes.sort((a, b) => (a.largerArea - b.largerArea).toInt());
    if (targetNodes.last.largerArea != 0) {
      targetedNode = targetNodes.last;
      if (targetedNode.parentMatchArea > targetedNode.childMatchArea) {
        targetedNode.isParentPinActive = true;
      } else {
        targetedNode.isChildPinActive = true;
        e;
      }
    } else {
      targetedNode = null;
    }
  }

  void _hoverEnd(_) {
    if (_hover != null && targetedNode != null) {
      _hover.putOn(targetedNode);
      targetedNode
          ..isChildPinActive = false
          ..isParentPinActive = false;
    }
    for (CatNode node in sm.nodes) {
      node
          ..pinChildVisible = false
          ..pinParentVisible = false;
    }
    _hover = null;
    sm.gravity.start();
  }

  CatNode _findNode(int x, int y) {
    for (CatNode n in sm.nodes) {
      if (x > n.x && y > n.y && x < n.cont.right && y < n.cont.bottom) {
        return n;
      }
    }
    return null;
  }
}
