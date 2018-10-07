abstract class GUIControl {
  
  abstract PGraphics display(int w);
  abstract int getHeight();
  
  boolean clicked(int x, int y) {
    // Quite dusty here...
    return false;
  }
  
}






class ColorControl extends GUIControl {
  color c = #198F6A;
  
  PGraphics display(int w) {
    int h = getHeight();
    PGraphics result = createGraphics(w, h);
    result.beginDraw();
    result.fill(c);
    result.rect(0, 0, w - 1, h - 1);
    result.endDraw();
    return result;
  }
  
  int getHeight() {
    return 24;
  }
  
  boolean clicked(int x, int y) {
    c = color(random(0, 360), 1.0, 1.0);
    return true;
  }
}
