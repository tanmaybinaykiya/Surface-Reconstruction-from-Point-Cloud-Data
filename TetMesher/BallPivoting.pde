Point centerOfBall(Point A, Point B, Point C, float r) {
  Point circumcenter = circumcircleCenter(A, B, C);
  Vector normal = U(N(V(A,C), V(C, B)));
  
  float dACircumcenter = d(A, circumcenter);
  
  if (r < dACircumcenter)
    return null;
  
  float distance = sqrt(r*r - dACircumcenter*dACircumcenter);
  Point center = P(circumcenter, distance, normal);
  
  return center;
}

float angle(Vector U, Vector V, Vector W) {
  float a = atan2(d(V,U(N(W,U))),d(V,U(U))); 
  
  if(a<0) 
    a+=TWO_PI; 
    
  return a; 
}

void drawBallCenter(Triangle t, float r, color c) {
  Point A = pointCloud.get(t.aIndex);
  Point B = pointCloud.get(t.bIndex);
  Point C = pointCloud.get(t.cIndex);
  
  Point centr = centerOfBall(B, A, C, r);
  
  fill(c);
  show(centr, rb);
  
  //beginShape();
  //v(B);
  //v(A);
  //v(C);
  //endShape(CLOSE);
  
  strokeWeight(0);
  fill(c, 50);
  show(centr, r);
}

void drawBallCenter(int c, int a, int b, float r, color col) {
  Point C = pointCloud.get(c);
  Point A = pointCloud.get(a);
  Point B = pointCloud.get(b);
  
  Point centr = centerOfBall(C, A, B, r);
  
  fill(col);
  show(centr, rb/10);
  
  //beginShape();
  //v(B);
  //v(A);
  //v(C);
  //endShape(CLOSE);
  
  strokeWeight(1);
  //fill(col, 50);
  stroke(black, 50);
  noFill();
  show(centr, r);
}

void addSeedEdges(List<Point> P, float r){
  for (int i = 0; i<P.size(); i++){
    for (int j = i+1; j<P.size(); j++){
      for (int k = j+1; k<P.size(); k++){
        Point I = P.get(i);
        Point J = P.get(j);
        Point K = P.get(k);
        Point sphereCenter = centerOfBall(J, I, K, r);
        
        if(sphereCenter == null){
          continue;
        }
        
        boolean isValid = true;
        
        for (int l = 0; l<P.size(); l++){
          if( l== i || l==j || l==k ){
            continue;
          }
          if(d(P.get(l), sphereCenter) < r){
            isValid = false;
            break;
          }
        }
        
        if (isValid){
          frontier.put(new Edge(j, i), k);
          frontier.put(new Edge(k, j), i);
          frontier.put(new Edge(i, k), j);
          generatedTriangles.add(new Triangle(i, j, k));
          return;
        }
      }
    }
  }
  throw new RuntimeException("No seed triangle found. Better luck next time.");
}

void ballPivot(List<Point> P, float r, int limit){
  addSeedEdges(P, r);
  println("Added seed edges: ", frontier);
  
  int count = 0;
  
  while (!frontier.isEmpty() && count < limit) {
    //println(frontier);
    
    // Get the next item from the frontier
    Map.Entry<Edge, Integer> front = frontier.entrySet().iterator().next();    
    Edge pivotEdge = front.getKey();
    int pivotVertex = front.getValue();
    
    frontier.remove(pivotEdge);
    
    // Add the frontier to explored
    explored.add(pivotEdge);
    count++;
    
    
    
    int nextVertex = ballPivot(pivotEdge.first, pivotEdge.second, pivotVertex, P, r);    
    
    //if (count == limit) {
    //  drawBallCenter(pivotVertex, pivotEdge.first, pivotEdge.second, r, blue);
    //}
    
    if (nextVertex < 0) {
      println("Could not find vertex;", pivotEdge, "is boundary");
      boundaryEdges.add(pivotEdge);
      continue;
    }
    
    // Create the next edges
    Edge edgeFirst = new Edge(pivotEdge.first, nextVertex);
    Edge edgeSecond = new Edge(nextVertex, pivotEdge.second);
    
    // If both have not  been seen, add a triangle
    boolean exploredEdgeFirst = false, exploredEdgeSecond = false;
    if (explored.contains(edgeFirst)) {
      exploredEdgeFirst = true;
    }
    if (!frontier.containsKey(edgeFirst) && !exploredEdgeFirst) {
      // This edge was not seen, so add it to the frontier
      frontier.put(edgeFirst, pivotEdge.second);
    }
    
    if (explored.contains(edgeSecond)) {
      exploredEdgeSecond = true;
    }
    if (!frontier.containsKey(edgeSecond) && !exploredEdgeSecond) {
      // This edge was not seen, so add it to the frontier
      frontier.put(edgeSecond, pivotEdge.first);
    }
    
    if (!exploredEdgeFirst && !exploredEdgeSecond) {
      // Neither edge was found, so this is a new triangle
      generatedTriangles.add(new Triangle(pivotEdge.first, pivotEdge.second, nextVertex));
    }
  }
  
  //println("Done");
}

int ballPivot(int aIndex, int bIndex, int cIndex, List<Point> P, float r) {
  float bestAngle = Float.MAX_VALUE;
  int bestPointIndex = -30;
  
  // AB
  Point A  = P.get(aIndex);
  Point B  = P.get(bIndex);
  Point C  = P.get(cIndex);

  for (int dIndex=0; dIndex <P.size(); dIndex++) {
    Point D  = P.get(dIndex);
    
    if(aIndex != dIndex && bIndex != dIndex){ // let c match d - if we pivot to c we dont create the triangle 
      float angle = pivotAngle(A, B, C, D, r);
      
      if (angle < bestAngle) {
        bestAngle = angle;
        bestPointIndex = dIndex;
      }
    }
  }
     
  return bestPointIndex;
}

float pivotAngle(Point B, Point C, Point A, Point D, float r) {
  Point centerABC = centerOfBall(A, B, C, r);
  Point centerCBD = centerOfBall(C, B, D, r);
  
  if (centerABC == null || centerCBD == null) 
    return Float.MAX_VALUE;
  
  Point mBC = P(B,C);
  
  Vector U = V(mBC, centerABC);
  Vector V = V(mBC, centerCBD);
  Vector W = V(C, B);
  
  return angle(U, V, W);
}