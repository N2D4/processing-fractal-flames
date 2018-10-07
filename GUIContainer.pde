class GUIContainer {
  
  public final static int margin = 12;
  
  GUIControl elements[];
  
  GUIContainer(GUIControl controls[]) {
    elements = controls;
  }
  
  
  PGraphics display(int w) {PGraphics result = createGraphics(w, getHeight());
    result.beginDraw();
    int cursor = 0;
    for (GUIControl element : elements) {
      result.image(element.display(w), 0, cursor);
      cursor += margin + element.getHeight();
    }
    result.endDraw();
    return result;
  }
  
  boolean clicked(int x, int y) {
    int cursor = 0;
    for (int i = 0; i < elements.length; i++) {
      if (y >= cursor) {
        int origCursor = cursor;
        cursor += elements[i].getHeight();
        if (y < cursor) {
          return elements[i].clicked(x, y - origCursor);
        }
      } else {
        return false;                                  // zwischen zwei Steuerelementen
      }
      cursor += margin;
    }
    return false;
  }
  
  
  int getHeight() {
    int result = (elements.length - 1) * margin;
    
    for (GUIControl element : elements) {
      result += element.getHeight();
    }
    
    return result;
  }
}
