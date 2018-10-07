abstract class Variation {
  abstract float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f);
  abstract float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f);
  void generateRandoms(Random rnd) {
    // Quite dusty here...
  }
}




class LinearVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return x;
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return y;
  }
}



class SinusoidalVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return sin(x);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return sin(y);
  }
}



class SphericalVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return x/rSq;
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return y/rSq;
  }
}



class SwirlVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return x * sin(rSq) - y * cos(rSq);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return x * cos(rSq) - y * sin(rSq);
  }
}



class HandkerchiefVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return r * sin(theta + r);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return r * cos(theta - r);
  }
}



class HorseshoeVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return 1/r * (x - y) * (x + y);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return 2*x*y / r;
  }
}



class PopcornVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return x + c*sin(tan(3*y));
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return y + f*sin(tan(3*x));
  }
}



class PDJVariation extends Variation {
  float p1, p2, p3, p4;
  void generateRandoms(Random rnd) {
    p1 = rnd.nextFloat();
    p2 = rnd.nextFloat();
    p3 = rnd.nextFloat();
    p4 = rnd.nextFloat();
  }
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return sin(p1*y) - cos(p2*x);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return sin(p3*x) - cos(p4*x);
  }
}


class HeartVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return r * sin(theta * r);
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return -r * cos(theta * r);
  }
}


class PolarVariation extends Variation {
  float calcX(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return theta/PI;
  }
  float calcY(float x, float y, float r, float rSq, float theta, float phi, float a, float b, float c, float d, float e, float f) {
    return r - 1;
  }
}
