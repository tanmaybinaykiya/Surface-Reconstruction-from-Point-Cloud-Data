class EquilateralMesh {
  List<List<Point>> layers;
  
  public EquilateralMesh(List<List<Point>> layers) {
    this.layers = layers; 
  }
  
  public List<Point> getAllPoints() {
    List<Point> all = new ArrayList();
    
    for (List<Point> layer : this.layers) {
      all.addAll(layer);
    }
    
    return all;
  }
  
  public void draw() {
    for (int i = 0; i < layers.size(); i++) {
      beginShape(TRIANGLE_STRIP);
      
      List<Point> curLayer = layers.get(i);
      List<Point> nextLayer = (i+1 < layers.size()) ? layers.get(i+1) : null;
      
      for (int j = 0; j < curLayer.size(); j++) {
        v(curLayer.get(j));
        
        if (nextLayer != null) {
          v(nextLayer.get(j));
        }
      }
      
      endShape(CLOSE);
    }
  }
}

EquilateralMesh samplePointsOnBeam(Edge edge, Points floor, Points ceil, float radius, boolean drawMesh) {
  List<List<Point>> layers = new ArrayList();
  
  // Uniformly sample points around an edge beam for triangulation
  Point P = edge.getFirstPoint(floor, ceil);
  Point Q = edge.getSecondPoint(floor, ceil);
  
  // Get basis vectors for the space along the beam
  Vector T = U(V(P, Q));
  Vector I = U(Normal(T));
  Vector J = U(N(I, T));
  
  // Compute the parameters for going around and along the beam
  float angleTotal = 2*PI;
  float angleStepNum = 12;
  float angleStepEach = angleTotal / angleStepNum;
  
  float lengthTotal = d(P, Q);
  float lengthStepNum = ceil(lengthTotal / (sqrt(3) * radius * sin(angleStepEach / 2)));
  float lengthStepEach = lengthTotal / lengthStepNum;
  //println("Steps: Angle = " + angleStepNum + ", Length = " + lengthStepNum);
  
  // Enumerate along the length of the beam
  for (int d = 0; d < lengthStepNum + 1; d++) {
    List<Point> layer = new ArrayList();
    
    // Offset each enumeration by alpha/2 (to make nice triangles)
    float alphaOffset = d * angleStepEach / 2;
    
    // Enumerate around the beam
    for (int a = 0; a < angleStepNum + 1; a++) {
      float alphaStart = alphaOffset + a*angleStepEach;
      
      Point O = P(P, d * lengthStepEach, T);
      Point X = P(P(O, radius * cos(alphaStart), I), radius * sin(alphaStart), J);
      layer.add(X);
    }
    
    layers.add(layer);
  }
  
  return new EquilateralMesh(layers);
}