EquilateralMesh samplePointsOnBeam(Edge edge, Points floor, Points ceil, float radius) {
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
    for (int a = 0; a < angleStepNum; a++) {
      float alphaStart = alphaOffset + a*angleStepEach;
      
      Point O = P(P, d * lengthStepEach, T);
      Point X = P(P(O, radius * cos(alphaStart), I), radius * sin(alphaStart), J);
      layer.add(X);
    }
    
    layers.add(layer);
  }
  
  return new EquilateralMesh(layers);
}

EquilateralMesh samplePointsOnSphere(Point P, float radius) {
  
  float someConst = 10;
  
  println("samplePointsOnSphere: r", radius, P);
  // TODO: Implement so that you get nicely spaced equilateral triangles around the sphere
  List<List<Point>> layers = new ArrayList();
  Vector i = V(1, 0, 0);
  Vector j = V(0, 1, 0);
  Vector k = V(0, 0, 1);
  for (float r = -radius + 1; r < radius; r += 8){
    float thisRadius = sqrt(radius*radius - r*r);
    float dTheta = PI/someConst; // L / (thisRadius * 3);

    List<Point> layer = new ArrayList();     
    println("move along z axis:", r, P, k, P(P, r, k));

    for (float angle = 0; angle < 2*PI; angle += dTheta){
      
      
      Point X = P(P(P(P, r, k), thisRadius * cos(angle), i), thisRadius * sin(angle), j);
      //println("X: ", X);
      layer.add(X);
    }
    layers.add(layer);
  }
  println("samplePointsOnSphere done: " + layers.size());
  return new EquilateralMesh(layers);
}