part of categoryApp;


class View {
  Element root;
  List<Widget> widgets = [];
  PlatformWidget platformWidget;
  NavStateWidget navStateWidget;
  View(this.root) {
    init();
  }

  void init() {
    platformWidget = new PlatformWidget();
    platformWidget.target = root;
    widgets.add(platformWidget);

    navStateWidget = new NavStateWidget();
    navStateWidget.target = querySelector(".navbar-right");
    widgets.add(navStateWidget);

    repaint(null);
  }

  void repaint(_) {
    for (Widget w in widgets) {
      w.repaint();
    }
    window.requestAnimationFrame(repaint);
  }
}