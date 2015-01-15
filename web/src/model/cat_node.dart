part of categoryApp;

class CatNode {
  String label;
  Rect cont;
  Rect parentPin;
  Rect childPin;
  int get x =>cont.x;
  int get y =>cont.y;
  set x(val){
    cont.x = val;
  }
  set y(val){
    cont.y = val;
  }
  
  int get pivotX=> x+cont.width~/2;
  int get pivotY=> y+cont.height~/2;
  
  
  CatNode parentNode;
  List<CatNode> children = [];
  
  int hierarchyHeight;
  
  bool moving = false;
  
  bool pinChildVisible = false;
  bool pinParentVisible = false;
  
  bool isParentPinActive = false;
  bool isChildPinActive = false;

  int parentMatchArea;
  int childMatchArea;
  int get largerArea => max(parentMatchArea, childMatchArea);
  
 
  CatNode(this.label){
    int x = getRandomInt(window.innerWidth - 100);
    int y = getRandomInt(window.innerHeight - 100);
    cont = new Rect(x, y, 100, 30);
    
    parentPin = new Rect(x-15, y+25, 50, 20);
    childPin = new Rect(x+25, y+25, 50, 20);

  }
  
  void recalc(){
    parentPin..x = x+25 ..y=y-15;
    childPin..x = x+25 ..y=y+25;
  }

  /// this node is moving 
  int getArea(Rect a) {
    Rect b = cont;
    num x11 = a.x;
    num y11 = a.y;
    num x12 = a.right;
    num y12 = a.bottom;
    num x21 = b.x;
    num y21 = b.y;
    num x22 = b.right;
    num y22 = b.bottom;

    num x_overlap = max(0, min(x12, x22) - max(x11, x21));
    num y_overlap = max(0, min(y12, y22) - max(y11, y21));
    
    return (x_overlap*y_overlap).toInt();

  }
  
  List<CatNode> getAllChildrens(){
    List out = [];
    for(CatNode n in children){
      out.add(n);
      out.addAll(n.getAllChildrens());
    }
    return out;
  }

  void addAsChild(CatNode target){
    parentNode = target;
    sm.removeFromChildrens(this);
    target.children.add(this);
  }
  
  void addAsParent(CatNode target){
    target.parentNode = this;
    sm.removeFromChildrens(target);
    children.add(target);
  }
  
  void putOn(CatNode target) {
    if(target.isChildPinActive){
      addAsChild(target);  
    }else if(target.isParentPinActive){
      addAsParent(target);  
    }
  }
}

class Rect{
  int x;
  int y;
  int get right=> x+width;
  int get bottom=>y+height;
  int width;
  int height;
  Rect(this.x, this.y, this.width, this.height);
}