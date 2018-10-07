class GUIWindow {
  public static final color backgroundTitle = #A4A4BA;
  public static final color backgroundContent = #84849A;
  public static final float transparency = 0.4;
  public static final int headerSize = 12;
  public static final color titleColor = #FFFFFF;
  public static final int horizontalPadding = 12;
  public static final int verticalPadding = 12;
  
  protected GUIContainer container;
  protected String title = "I Y - ... _ g";
  protected int w = 200;
  
  GUIWindow(String headerTitle, int windowWidth, GUIContainer c) {
    title = headerTitle;
    w = windowWidth;
    container = c;
  }
  
  PGraphics display() {
    int h = getHeight();
    PGraphics result = createGraphics(w, h);
    result.beginDraw();
    result.colorMode(HSB, 360, 1, 1, 1);
    
    // Header
    result.stroke(#000000);
    result.fill(hue(backgroundTitle), saturation(backgroundTitle), brightness(backgroundTitle), transparency);
    result.textSize(headerSize);
    result.textAlign(CENTER);
    result.rect(0, 0, w, getHeaderHeight(), 6, 6, 0, 0);
    result.fill(titleColor);
    result.text(title, w/2, 1 + result.textAscent());
    
    
    // Content
    float contentStart = headerSize + 5;
    result.fill(hue(backgroundContent), saturation(backgroundContent), brightness(backgroundContent), transparency);
    result.rect(0, contentStart, w, h - contentStart, 0, 0, 6, 6);
    result.image(container.display(w - 2*horizontalPadding), horizontalPadding, contentStart + verticalPadding);
    
    result.endDraw();
    return result;
  }
  
  boolean clicked(int x, int y) {
    int newX = x - horizontalPadding;
    int newY = y - getHeaderHeight() - verticalPadding;
    if (newX >= 0 && newY >= 0 && newX <= w - 2*horizontalPadding && newY <= container.getHeight()) {
      return container.clicked(newX, newY);
    } else {
      return false;
    }
  }
  
  GUIContainer getContainer() {
    return container;
  }
  
  int getWidth() {
    return w;
  }
  
  int getHeight() {
    return 2*verticalPadding + getHeaderHeight() + container.getHeight();
  }
  
  int getHeaderHeight() {
    return headerSize + 5;
  }
  
}
