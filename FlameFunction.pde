class FlameFunction {
  float a, b, c, d, e, f, w;
  color col;
  Variation variations[];
  float weights[];
  FlameFunction postTransform = null;
  
  FlameFunction(Variation[] vars, float[] defaultWeights, boolean isFinalTransform) {
    this(isFinalTransform?2:0);
    
    variations = vars.clone();
    
    if (defaultWeights.length > 0) {
      weights = defaultWeights;
    } else {
      weights = new float[variations.length];
      float weightSum = 0;
      for (int i = 0; i < weights.length; i++) {
        weights[i] = randomWeight();
        weightSum += weights[i];
      }
      
      if (weightsSumToOne) {
        float scale = 1 / weightSum;
        for (int i = 0; i < weights.length; i++) {
          weights[i] /= scale;
        }
      }
    }
    
    if (doPostTransform) {
      postTransform = new FlameFunction(1);
    }
  }
  
  FlameFunction(Variation[] vars, float[] defaultWeights) {
    this(vars, defaultWeights, false);
  }
  
  FlameFunction(int type) {
    resetParams(type);
    
    w = rnd.nextFloat();
    if (colorMode == HSB) {
      col = color(rnd.nextFloat() * 360, 1.0, 1.0);
    } else if (colorMode == RGB) {
      col = color(rnd.nextInt(256), rnd.nextInt(256), rnd.nextInt(256));
    }
    variations = new Variation[1];
    variations[0] = new LinearVariation();
    weights = new float[1];
    weights[0] = 1;
  }
  
  
  /*float calcX(float x, float y) {
    float fx = a*x + b*y + c;
    float fy = d*x + e*y + f;
    float result = 0;
    float rSq = sq(fx) + sq(fy);
    float r = sqrt(rSq);
    float theta = atan(x/y);
    float phi = atan(y/x);
    for (int i = 0; i < variations.length; i++) {
      result += variations[i].calcX(fx, fy, r, rSq, theta, phi, a, b, c, d, e, f) * weights[i];
    }
    
    if (postTransform != null) {
      return postTransform.calcX(result);
    } else {
      return result;
    }
  }
  
  float calcY(float x, float y) {
    float fx = a*x + b*y + c;
    float fy = d*x + e*y + f;
    float result = 0;
    float rSq = sq(fx) + sq(fy);
    float r = sqrt(rSq);
    float theta = atan(x/y);
    float phi = atan(y/x);
    for (int i = 0; i < variations.length; i++) {
      result += variations[i].calcY(fx, fy, r, rSq, theta, phi, a, b, c, d, e, f) * weights[i];
    }
    
    if (postTransform != null) {
      return postTransform.calcY(result);
    } else {
      return result;
    }
  }*/
  
  
  float[] calcCoords(float x, float y) {
    float fx = a*x + b*y + c;
    float fy = d*x + e*y + f;
    float[] result = new float[2];
    float rSq = sq(fx) + sq(fy);
    float r = sqrt(rSq);
    float theta = atan(x/y);
    float phi = atan(y/x);
    for (int i = 0; i < variations.length; i++) {
      result[0] += variations[i].calcX(fx, fy, r, rSq, theta, phi, a, b, c, d, e, f) * weights[i];
      result[1] += variations[i].calcY(fx, fy, r, rSq, theta, phi, a, b, c, d, e, f) * weights[i];
    }
    
    if (postTransform != null) {
      return postTransform.calcCoords(result[0], result[1]);
    } else {
      return result;
    }
  }
  
  
  color calcColor(color prevColor) {
    if (colorMode == HSB) {
      return color(0.5 * (hue(col) + hue(prevColor)), 1.0, 1.0);
    } else if (colorMode == RGB) {
      float r = 0.5 * (red(col) + red(prevColor));
      float g = 0.5 * (green(col) + green(prevColor));
      float b = 0.5 * (blue(col) + blue(prevColor));
      return color(r, g, b);
    }
    return 0;
  }
  
  
  void randomChange() {
    float[] params = getParamsAsArray();
    println("----------------");
    for (int i = 0; i < params.length; i++) {
      println("1: " + params[i]);
      float rndVal = rnd.nextFloat();
      println(rndVal, animParamMutateChance);
      if (rndVal < animParamMutateChance) {
        println("k");
        rndVal = (rndVal - animParamMutateChance/2) * animParamMutateValue / animParamMutateChance;
        params[i] = constrain(params[i] + rndVal, -1, 1);
      }
      println("2: " + params[i]);
    }
    
    setParamsFromArray(params);
  }
  
  
  float[] getParamsAsArray() {
    return new float[]{a, b, c, d, e, f};
  }
  
  void setParamsFromArray(float[] params) {
    a = params[0];
    b = params[1];
    c = params[2];
    d = params[3];
    e = params[4];
    f = params[5];
  }
  
  
  private void resetParams(int type) {
    float[] params = getParamsAsArray();
    if (functionGenType == 0) {
      for (int i = 0; i < params.length; i++) {
        params[i] = 2*rnd.nextFloat() - 1; // ich weiss, dass so -1 aber nicht 1 vorkommen kann. Ich weiss auch, dass man das fixen kann, indem man zufällig zwischen 0 und 1 generiert und das Vorzeichen zufällig bestimmen lässt (und bei -0 alles wiederholt). Der Unterschied ist aber minimal, weshalb ich der Einfachheit halber darauf verzichten werde.
      }
      setParamsFromArray(params);
    } else if (functionGenType == 1) {
      for (int i = 0; i < params.length; i++) {
        params[i] = (int) (3*rnd.nextFloat());
      }
      setParamsFromArray(params);
    } else {
      if (type == 0) {
        setParamsFromArray(getNextPredefined());
      } else if (type == 1) {
        setParamsFromArray(predefinedPost);
      } else if (type == 2) {
        setParamsFromArray(predefinedFinal);
      }
    }
  }
  
}
