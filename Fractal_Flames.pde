/** 
 * Fractal_Flames, © 2015 Konstantin Wohlwend
 * Originalalgorithmus von Scott Draves, Spotworks und Erik Reckase, Bertoud: http://flam3.com/flame.pdf
 *
 * STEUERUNG:
 * f: Zeichnen ein-/ausschalten, Infos aus-/einschalten
 * c: Berechnung ein-/ausschalten
 * r: Rendermodus starten/beenden
 * v: Rendervorschau ein-/ausschalten
 * g: Gammakorrektur ein-/ausschalten
 * +: Gammawert erhöhen
 * -: Gammawert senken
 * Leertaste: Foto aufnehmen
 * h: Bilder anzeigen            // deaktiviert
 * p: PDF-Bild aufzeichnen
 * ALT + h: PDFs anzeigen        // deaktiviert
 * w: Einstellungen anzeigen/verstecken      // Einstellungen sind zum Zeitpunkt der Abgabe noch nicht fertig
 * Page Up: Einstellungen nach oben scrollen
 * Page Down: Einstellungen nach unten scrollen
 * z: Nullpunkt zentrieren
 * Pfeiltasten horizontal: Bild wählen
 *
 */

import java.util.Random;
import java.text.SimpleDateFormat;
import java.sql.Date;
import java.lang.System;
import processing.pdf.*;

// -------- KONFIGURIERBARE VARIABLEN -------- //
public final float goalFPS = 30;
public final float criticalFPS = 25;
public final float calculationTimePerFrame = 60;                                  // Ungefähre Zeit in ms/frame, um das Fraktal zu berechnen (Ziel-Geschwindigkeit). criticalFPS wird vor dieser Variable berücksichtigt.
public final boolean autoCalculationTime = false;                                 // Verändert calculationTimePerFrame automatisch bei Lag. Kann in diesem Fall nie höher als der Anfangswert werden. Falls eine schlechte Grafikkarte installiert ist, sollte diese Option deaktiviert sein da sie nicht zwischen Grafikkartenlag und Prozessorlag unterscheiden kann.
public final int windowWidth = 1000;                                              // 0 == displayWidth == Volle Weite
public final int windowHeight = 800;                                              // 0 == displayHeight == Volle Höhe
public final int previewWidth = windowWidth;                                      // Bildqualität
public final int previewHeight = windowHeight;                                    // Bildqualität
public final int renderWidth = windowWidth * 4;                                   // Renderqualität
public final int renderHeight = windowHeight * 4;                                 // Renderqualität
public final int saveFrameWidth = renderWidth / 2;                                // Eventuelle Renderfehler werden bei hoher Weite/Höhe sichtbar
public final int saveFrameHeight = renderHeight / 2;                              // Eventuelle Renderfehler werden bei hoher Weite/Höhe sichtbar
public final int recordWidth = renderWidth / 4;                                   // Eventuelle Renderfehler werden bei hoher Weite/Höhe sichtbar
public final int recordHeight = renderHeight / 4;                                 // Eventuelle Renderfehler werden bei hoher Weite/Höhe sichtbar
public final int flameFunctionCount = 8;
public final float scrollSensibility = 1;
public final long storeExactResults = 40;                                         // Wie viele Resultate exakt gespeichert werden sollen. Benötigt extrem viel Arbeitsspeicher, aber verkleinert die Rechenauslastung beim Bewegen der Kamera.
public final color tint = #000000;                                                // Farbe der Flamme. (tint == background) heisst automatisch generiert.
public final color background = #000000;
public final int colorMode = RGB;                                                 // Farbmodus (RGB/HSB) - verändert die Farben, nicht nur, wie sie gezeichnet werden (HSB ist nur zur Rückwartskompatibiltät da). Kann auch die Form verändern.
public final boolean doFinalTransform = true;
public final boolean doFinalColorTransform = true;
public final boolean doPostTransform = true;
public final boolean globalWeights = true;                                         // Ob jede Funktion die Gewichtung der Variationen selbst generiert, oder ob alle dieselbe haben
public final byte weightType = 1;                                                  // 0 = Gewichtung zufällig zwischen 0 und 1   |   1 = Gewichtung zwischen 0 und 1, aber quadriert (mehr Extremen)   |   2 = Gewichtung zufällig, aber mit Dreiecksverteilung (weniger Extremen)
public final boolean weightsSumToOne = false;
//public final boolean doFunctionWeights = false;                                    // deaktiviert, weil es bis zur Abgabe nicht fertig wurde
//public final byte functionWeightType = 0;                                          // TODO 0 = Gewichtung zufällig zwischen 0 und 1   |   1 = Gewichtung zwischen 0 und 1, aber quadriert (näher bei 0)   |   2 = Gewichtung zufällig, aber mit Dreiecksverteilung   |   3 = Zufällig, aber summieren sich zu 1 (todo)
public final byte functionGenType = 0;                                             // 0 = zufälliger Float   |   1 = zufälliger Int   |   8 = von vordefinierten Funktionen
public final String decimalNorm = "%.3f";                                          // Formatierungsstring, auf wie viele Dezimalstellen normalerweise gerundet werden soll
public final float renderPreviewRate = 10000;
public final float defaultGammaValue = 2.2;
public final boolean gammaVibrancy = true;                                         // Funktioniert nur im RGB-Farbmodus
public final long defaultSeed = 0;                                                 // 0 = automatisch generieren
public final int windowScrollSensibility = 50;
public final int PAGEUP = 33;                                                      // Keycode
public final int PAGEDOWN = 34;                                                    // Keycode
public final int propertiesWindowWidth = 250;
public final String pictureFormat = ".png";
public final long iterationsPerFrame = (long) 0;                                          // 0 = nicht animieren
public final float animSpeed = 1;
public final float animParamMutateChance = 0.1;                                    // Chance für jeden Parameter, dass er bei einem Frame verändert wird
public final float animParamMutateValue = 0.1;                                    // Um wieviel ein Parameter maximal verändert wird
public final boolean allowCustomAnimFrames = false;                                // ob mit den Pfeiltasten auch neue Frames hinzugefügt werden können
// -------- KONFIGURIERBARE VARIABLEN -------- //

// -------- VARIATIONEN -------- //
public final Variation allVariations[] = {
new LinearVariation(),
new SinusoidalVariation(),
new SphericalVariation(),
new SwirlVariation(),
new HorseshoeVariation(),
new PolarVariation(),
new HandkerchiefVariation(),
new HeartVariation(),
new PopcornVariation(),
new PDJVariation()
};
// -------- VARIATIONEN -------- //


// -------- VORDEFINIERTE FUNKTIONEN -------- //
public final float[][] predefinedFunctions = {
/*{1.0, 0.3, 1.0,           0.9, 1.0, 0.1},
{0.5, 0.1, 0.5,           1.0, 0.5, 1.0},
{0.0, 1.0, 0.5,           0.2, 0.0, 0.2},
{0.5, 0.2, 0.1,           0.4, 0.0, 1.0}*/
{0.5, 0.0, 0.0,           0.0, 0.5, 0.0},
{0.5, 0.0, 0.5,           0.0, 1.0, 0.0},
{1.0, 0.0, 0.0,           0.0, 0.5, 0.5},
};

public final float[] predefinedPost    =   {1.0, 0.2, 0.1,           0.4, 0.6, 0.1};
public final float[] predefinedFinal   =   {1.0, 0.3, 0.1,           0.3, 1.0, 0.1};
// -------- VORDEFINIERTE FUNKTIONEN -------- //




public final float logTen = log(10);

private FlameFunction funcSet[];
private FlameFunction finalFunc;
private long[][] map;
private color[][] colors;
private long highest = 0;
private float x;
private float y;
private color c;
private float xOffset = 0;
private float yOffset = 0;
private float zoomX = 100;
private float zoomY = 100;
private long iterations = 0;
private int frame = 0;
private float exactFrame = 0;
private ArrayList<PGraphics> recorded = new ArrayList<PGraphics>();
private float startingX;
private float startingY;
private float calcTimePerFrame = calculationTimePerFrame/2;
private ArrayList<Float> exactX = new ArrayList<Float>();
private ArrayList<Float> exactY = new ArrayList<Float>();
private ArrayList<Integer> exactC = new ArrayList<Integer>();
private int exactCursor = 0;
private float[] defaultWeights;
private boolean drawStuff = true;
private float[] ips = new float[20];
private int ipsCursor = 0;
private int pictureWidth = previewWidth;
private int pictureHeight = previewHeight;
//private int xSplits = pictureWidth / maxSplitWidth;
//private int ySplits = pictureHeight / maxSplitHeight;
private boolean isRendering = false;
private int lastRenderPreviewRefresh = 0;
private PGraphics pic;
private float gammaValue = defaultGammaValue;
private boolean doGamma = true;
private Random rnd;
private long seed;
private GUIWindow propertyWindow;
private int propertyX = 0;
private int propertyY = 0;
private byte isDragging = 0;                                // 0 = nothing, 1 = dragging the picture, 2 = dragging the window
private boolean showWindow = false;
private boolean allowZooming = false;
private boolean doRenderPreview = true;
private boolean calculate = true;
private int predefinedFunctionCounter = 0;



void settings() {
  size(numberOrDisplay(windowWidth, false), numberOrDisplay(windowHeight, true), P2D);
}


void setup() {
  frameRate(goalFPS);
  if (colorMode == HSB) {
    colorMode(HSB, 360, 1, 1, 1);
  } else if (colorMode == RGB) {
    colorMode(RGB);
  } else {
    println("Unknown colormode: " + colorMode);
    exit();
  }
  reinit();
  repositionWindow();
}




void draw() {
  background(background);
  if (calculate) {
    calc();                        // Punkt berechnen
    updateCalcTime();              // neue Berechnungszeit für das nächste Frame berechnen
  }
  
  
  if (iterations >= iterationsPerFrame) {
    changeFrame(recorded.size() - frame + 1);
  }
  
  if (keyPressed) {
    if (keyCode == LEFT) {
      changeFrame(-1);
    } else if (keyCode == RIGHT && (allowCustomAnimFrames || frame < recorded.size())) {
      changeFrame(1);
    }
  }
  
  if (!drawStuff) {                  // Debug Screen anzeigen
    textSize(12);
    textAlign(LEFT);
    image(pic, 0, 0, width, height);
    fill(#FFFFFF);
    if (!isRendering) {
      text("Zeichnen deaktiviert", 20, height - 20);
    } else if (doRenderPreview) {
      text("Wird gerendert...", 20, height - 20);
    } else {
      text("Wird gerendert (Vorschau deaktiviert)...", 20, height - 20);
    }
    text(String.format(decimalNorm, frameRate) + " FPS, 10^" + String.format(decimalNorm, log(average(ips))) + " IPS", 20, height - 40);
    text("10^" + String.format(decimalNorm, log(iterations)/logTen) + " Punkte berechnet", 20, height - 60);
    if (doGamma && gammaValue != 1 && isRendering) {
      text("Gamma " + gammaValue, 20, height - 80);
    } else {
      text("Gamma AUS", 20, height - 80);
    }
    text("Seed: " + seed, 20, height - 100);
    if (frame != 0 || recorded.size() > 0) {
      text("Frame: " + frame + "/" + (recorded.size()), 20, height - 120);
    }
  }
  
  
  if (frame == recorded.size() && (drawStuff || (millis() - lastRenderPreviewRefresh > renderPreviewRate && isRendering && doRenderPreview))) {                // Bild zeichnen
    calcPic();
  }
  
  
  if (drawStuff) {            // bisher war alles nur in einer Variable, jetzt wird es angezeigt
    if (frame == recorded.size()) {
      image(pic, 0, 0, width, height);
    } else {
      image(recorded.get(frame), 0, 0, width, height);
    }
  }
  if (mousePressed && !inWindow(mouseX, mouseY)) {                    // falls die Maus gedrückt ist, zeichne die Achsen
    stroke(#FF0000);
    float xCoordsLine = constrain(xOffset, 0, width - 1);
    float yCoordsLine = constrain(yOffset, 0, height - 1);
    line(xCoordsLine, 0, xCoordsLine, height - 1);
    line(0, yCoordsLine, width - 1, yCoordsLine);
  }
  
  if (showWindow) {                            // Einstellungsfenster anzeigen
    propertyX = constrain(propertyX, 0, width - propertyWindow.getWidth());
    propertyY = constrain(propertyY, propertyWindow.verticalPadding - propertyWindow.getHeight(), height - propertyWindow.getHeaderHeight());
    PGraphics propWindow = propertyWindow.display();
    image(propWindow, propertyX, propertyY);
  }
  
  
}


color getColor(int x, int y, float alpha) {
  if (tint == background) {
    if (colorMode == RGB) {
      return setAlpha(colors[x][y], alpha);
    } else if (colorMode == HSB) {
      return color(hue(colors[x][y]), 1.0, 1.0, alpha);
    }
  } else {
    if (colorMode == RGB) {
      return setAlpha(tint, alpha);
    } else if (colorMode == HSB) {
      return color(hue(tint), saturation(tint), brightness(tint), alpha);
    }
  }
  println("Error: Could not return color for " + x + ", " + y + ".");
  return floor(random(0, #FFFFFF));
}


void calcPic() {
  color col;
  pic = createGraphics(pictureWidth, pictureHeight);
  pic.beginDraw();
  pic.loadPixels();
  float logHighest = log(highest);
  for (int i = 0; i < pictureWidth; i++) {
    for (int j = 0; j < pictureHeight; j++) {                                    // für jeden Pixel
      float alpha;
      float scale = 0;
      if (map[i][j] == 0) {
        alpha = 0;
      } else {
        scale = log(map[i][j]) / logHighest;
        alpha = scale;
      }        
      col = getColor(i, j, alpha);
      
      if (doGamma && gammaValue != 1 && isRendering) {
        col = applyGamma(col, gammaValue);
      }
      
      pic.pixels[j * pictureWidth + i] = col;
    }
  }
  pic.updatePixels();
  pic.endDraw();
  if (isRendering) {
    lastRenderPreviewRefresh = millis();
  }
}


void changeFrame(int n) {
  if (iterationsPerFrame == 0) {
    return;
  }
  
  exactFrame += n * animSpeed;
  frame = floor(exactFrame); 
  if (frame < 0) {
    exactFrame = frame = 0;
  } else if (frame > recorded.size()) {
    calcPic();
    PGraphics graphics = createGraphics(pic.width, pic.height);
    graphics.image(pic, 0, 0, pic.width, pic.height);
    recorded.add(graphics);
    for (int i = 0; i < funcSet.length; i++) {
      funcSet[i].randomChange();
    }
    reframe();
    exactFrame = frame = recorded.size();
  }
}

void calc() {
  float lastMillis = millis();
  int iterThisFrame = 0;
  while (millis() - lastMillis < calcTimePerFrame) {                                          // Iteration
    
    if (exactCursor == exactX.size()) {                                  // kein weiteres gespeichertes Resultat gefunden, berechne ein Neues
      FlameFunction f = null;
      //while (f == null || (f.w >= rnd.nextFloat() && doFunctionWeights)) {                      // momentan deaktiviert, weil es bis zur Abgabe nicht fertig wurde
      f = funcSet[rnd.nextInt(funcSet.length)];
      //}
      float[] coords = f.calcCoords(x, y);
      x = coords[0];
      y = coords[1];
      c = f.calcColor(c);
      if (storeExactResults > exactCursor) {
        exactX.add(x);
        exactY.add(y);
        exactC.add(c);
      }
    } else {                                                             // gespeichertes Resultat gefunden, in map[][] einfügen
      x = exactX.get(exactCursor);
      y = exactY.get(exactCursor);
      c = exactC.get(exactCursor);
      exactCursor++;
    }
    registerCurrentPixel();
    iterThisFrame++;
  }
  
  ips[ipsCursor] = iterThisFrame * (millis() - lastMillis) / 1000;
  if (++ipsCursor == ips.length) {
    ipsCursor = 0;
  }
}


void registerCurrentPixel() {                                    // (x, y) eintragen
  int cx;
  int cy;
  if (doFinalTransform) {
    float[] coords = finalFunc.calcCoords(x, y);
    cx = round(coords[0] * zoomX + xOffset * getOffsetZoomX());
    cy = round(coords[1] * zoomY + yOffset * getOffsetZoomY());
  } else {
    cx = round(x * zoomX + xOffset * getOffsetZoomX());
    cy = round(y * zoomY + yOffset * getOffsetZoomY());
  }
  if (iterations++ > 20 && cx >= 0 && cx < pictureWidth && cy >= 0 && cy < pictureHeight) {             // Die 20 ersten Durchläufe sind Teil der Initialisierung, und Punkte ausserhalb des Randes sollten nicht angezeigt werden
    if (++map[cx][cy] > highest) {
      highest = map[cx][cy];
    }
    if (doFinalColorTransform) {
      colors[cx][cy] = finalFunc.calcColor(c);
    } else {
      colors[cx][cy] = c;
    }
  }
}



void reinit() {                                // kompletter Neustart
  if (defaultSeed == 0) {
    seed = System.currentTimeMillis();
  } else {
    seed = defaultSeed;
  }
  rnd = new Random(seed);
  
  for (int i = 0; i < allVariations.length; i++) {
    allVariations[i].generateRandoms(rnd);
  }
  
  if (globalWeights) {
    defaultWeights = new float[allVariations.length];
    float weightSum = 0;
    for (int i = 0; i < defaultWeights.length; i++) {
      defaultWeights[i] = randomWeight();
        weightSum += defaultWeights[i];
    }
    if (weightsSumToOne) {
      float scale = 1 / weightSum;
      println(scale);
      for (int i = 0; i < defaultWeights.length; i++) {
        defaultWeights[i] /= scale;
      }
    }
  } else {
    defaultWeights = new float[0];
  }
  //gammaValue = 1.0 + rnd.nextFloat() * (gammaValue - 1.0);
  
  finalFunc = new FlameFunction(allVariations, defaultWeights, true);
  funcSet = new FlameFunction[flameFunctionCount];
  for (int i = 0; i < funcSet.length; i++) {
    funcSet[i] = new FlameFunction(allVariations, defaultWeights);
  }
  
  startingX = rnd.nextInt(800) - 400;
  startingY = rnd.nextInt(600) - 300;
  reframe();
  initPropWindow();
  xOffset = width/2;
  yOffset = height/2;
  frame = 0;
  recorded = new ArrayList<PGraphics>();
}

void reframe() {                             // nur neues Bild mit veränderten Parametern erzeugen, nicht neu Zustände berechnen
  exactX = new ArrayList<Float>();
  exactY = new ArrayList<Float>();
  exactC = new ArrayList<Integer>();
  exactCursor = 0;
  rerender();
}

void rerender() {                            // nur neu rendern/anzeigen
  float prevWidth = pictureWidth;
  float prevHeight = pictureHeight;
  if (isRendering) {
    pictureWidth = renderWidth;
    pictureHeight = renderHeight;
  } else {
    pictureWidth = previewWidth;
    pictureHeight = previewHeight;
  }
  zoomX *= pictureWidth/prevWidth;
  zoomY *= pictureHeight/prevHeight;
  
  x = startingX;
  y = startingY;
  map = new long[pictureWidth][pictureHeight];
  colors = new int[pictureWidth][pictureHeight];
  highest = 0;
  iterations = 0;
  lastRenderPreviewRefresh = millis();
}


void mouseDragged() {
  if (isDragging == 2 && showWindow) {                                // Fenster wird gedraggt
    propertyX += mouseX - pmouseX;
    propertyY += mouseY - pmouseY;
  } else if (isDragging == 1) {                                       // Bild wird gedraggt
    xOffset += mouseX - pmouseX;
    yOffset += mouseY - pmouseY;
    rerender();
  }
}

void mousePressed() {                                                 // Damit man immer das draggt, auf das man zuerst geklickt hat.
  if (inWindow(mouseX, mouseY)) {
    if (!propertyWindow.clicked(mouseX - propertyX, mouseY - propertyY)) {
      isDragging = 2;
    } else {
      isDragging = 0;
    }
  } else {
    isDragging = 1;
  }
}

void mouseWheel(MouseEvent event) {
  if (inWindow(mouseX, mouseY) || !allowZooming) {
    propertyY -= event.getCount() * windowScrollSensibility * scrollSensibility;
  } else {
    float factor = pow(1.2, event.getCount() * scrollSensibility);
    zoomX /= factor;
    zoomY /= factor;
    rerender();
  }
}

void mouseMoved() {                                // ansonsten kann es sein, dass man beim Scrollen zu weit scrolled und versehentlich das Bild zoomt
  if (inWindow(mouseX, mouseY)) {
    allowZooming = false;
  } else {
    allowZooming = true;
  }
}

void keyPressed() {
  if (key == 'f') {
    drawStuff = !drawStuff;
  } else if (key == 'r') {
    isRendering = !isRendering;
    drawStuff = false;
    rerender();
  } else if (key == 'g') {
    doGamma = !doGamma;
  } else if (key == ' ') {
    PGraphics picWithBackground = createGraphics(saveFrameWidth, saveFrameHeight, P2D);
    picWithBackground.beginDraw();
    storePicIn(picWithBackground);
    picWithBackground.endDraw();
    picWithBackground.save("Generierte Resourcen/Bilder/Frame " + getTodayString() + pictureFormat);
  } else if (key == 'p') {
    PGraphics picWithBackground = createGraphics(saveFrameWidth, saveFrameHeight, PDF, "Generierte Resourcen/PDFs/Frame " + getTodayString() + ".pdf");
    picWithBackground.beginDraw();
    storePicIn(picWithBackground);
    picWithBackground.dispose();
    picWithBackground.endDraw();
  } else if (key == 'w') {
    showWindow = !showWindow;
    repositionWindow();
  } else if (keyCode == PAGEUP) {
    propertyY += windowScrollSensibility;
  } else if (keyCode == PAGEDOWN) {
    propertyY -= windowScrollSensibility;
  } else if (key == 'z') {
    xOffset = width/2;
    yOffset = height/2;
    rerender();
  } else if (key == '+') {
    gammaValue += 0.1;
    gammaValue = round(gammaValue*10) / 10.0;
  } else if (key == '-') {
    gammaValue -= 0.1;
    gammaValue = round(gammaValue*10) / 10.0;
  } else if (key == 'v') {
    doRenderPreview = !doRenderPreview;
    if (doRenderPreview) {
      lastRenderPreviewRefresh = 0;
    }
  } else if (key == 'c') {
    calculate = !calculate;
  }
}

void initPropWindow() {
  ArrayList<GUIControl> controls = new ArrayList<GUIControl>();
  controls.add(new ColorControl());
  controls.add(new ColorControl());
  propertyWindow = new GUIWindow("Frame Properties", 250, new GUIContainer(controls.toArray(new GUIControl[0])));
}

void storePicIn(PGraphics p) {
  p.background(background);
  p.image(pic, 0, 0, saveFrameWidth, saveFrameHeight);
}

boolean inWindow(int x, int y) {
  return showWindow && x >= propertyX && x <= propertyX + propertyWindow.getWidth() && y >= propertyY && y <= propertyY + propertyWindow.getHeight();
}

/*boolean sketchFullScreen() {
  return windowWidth == 0 && windowHeight == 0;
}*/

int numberOrDisplay(int wh, boolean isHeight) {                        // falls wh == 0, mache wh zu displayWidth bzw. displayHeight
  return wh == 0 ? (isHeight ? displayHeight : displayWidth) : wh;
}

float randomWeight() {
  if (weightType == 1) {
    return sq(rnd.nextFloat());
  } else if (weightType == 2) {
    return 0.5 * (rnd.nextFloat() + rnd.nextFloat());
  } else {
    return rnd.nextFloat();
  }
}

float average(float array[]) {
  float result = 0;
  for (float f : array) {
    result += f;
  }
  return result / (float)array.length;
}

float getOffsetZoomX() {
  return pictureWidth/windowWidth;
}
float getOffsetZoomY() {
  return pictureHeight/windowHeight;
}

void repositionWindow() {
  if (propertyWindow == null) {
    return;
  }
  propertyX = width - propertyWindow.getWidth();
  propertyY = 0;
}

void updateCalcTime() {
  if (autoCalculationTime) {
    if (frameRate < criticalFPS) {
      calcTimePerFrame *= 0.9;                                                            // neue Geschwindigkeit: 90% der vorigen Geschwindigkeit
    } else {
      calcTimePerFrame = (calcTimePerFrame + calculationTimePerFrame)/2;                  // neue Geschwindigkeit: Durchschnitt zwischen Ziel und jetztiger Geschwindigkeit
    }
  } else {
    calcTimePerFrame = calculationTimePerFrame;
  }
}

public String getTodayString() {
    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss.SSS");
    Date now = new Date(System.currentTimeMillis());
    return sdf.format(now);
}

public color avg(color c1, color c2) {
  if (colorMode == RGB) {
    float r = (red(c1) + red(c2))/2;
    float g = (green(c1) + green(c2))/2;
    float b = (blue(c1) + blue(c2))/2;
    return color(r, g, b);
  } else if (colorMode == HSB) {
    float h = (hue(c1) + hue(c2))/2;
    float s = (saturation(c1) + saturation(c2))/2;
    float b = (brightness(c1) + brightness(c2))/2;
    return color(h, s, b);
  } else {
    println("Unknown colormode: " + colorMode);
    exit();
    return 0;
  }
}

public color setAlpha(color c, float alpha) {
  return (c & 0xffffff) | (round(alpha * 255) << 24); 
}

public color applyGamma(color c, float gamma) {
  if (colorMode == HSB) {
    float alpha = pow(alpha(c), 1/gamma);
    return setAlpha(c, alpha);
  } else if (colorMode == RGB) {
    float aOrig = alpha(c);
    float a = pow(aOrig/255, 1/gamma) * 255;
    float scale = (float)aOrig / (float)a;
    if (!gammaVibrancy) {
      float r = pow(red(c)/255, 1/gamma) * 255;
      float g = pow(green(c)/255, 1/gamma) * 255; 
      float b = pow(blue(c)/255, 1/gamma) * 255;
      return color(r, g, b, aOrig);
    } else {
      float r = red(c);
      float g = green(c); 
      float b = blue(c);
      return color(r, g, b, a);
    }
  }
  return 0;
}

public color multiplyColor(color c, float scale) {
  if (colorMode == RGB) {
    float r = red(c) * scale;
    float g = green(c) * scale;
    float b = blue(c) * scale;
    return color(r, g, b, alpha(c));
  }
  
  return c;
}

public float[] getNextPredefined() {
  if (predefinedFunctionCounter < predefinedFunctions.length) {
    return predefinedFunctions[predefinedFunctionCounter++];
  }
  println("More functions than predefined values");
  return new float[]{1, 0, 0, 0, 1, 0};
}