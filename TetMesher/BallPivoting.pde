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

/// Pivot angle between BC-A and BC-D
float pivotAngle(Point B, Point C, Point A, Point D, float r) {
  Point centerABC = centerOfBall(A, B, C, r);
  Point centerCBD = centerOfBall(C, B, D, r);
  
  if (centerABC == null || centerCBD == null) 
    return Float.MAX_VALUE;
  
  Point mBC = P(B, C);
  
  Vector U = V(mBC, centerABC);
  Vector V = V(mBC, centerCBD);
  Vector W = V(C, B);
  
  return angle(U, V, W);
}

void drawBallCenter(Triangle t, float r, color c) {
  Point A = pointCloud.get(t.aIndex);
  Point B = pointCloud.get(t.bIndex);
  Point C = pointCloud.get(t.cIndex);
  
  Point centr = centerOfBall(A, B, C, r);
  
  fill(c);
  show(centr, rb);
  
  beginShape();
  v(B);
  v(A);
  v(C);
  endShape(CLOSE);
  
  fill(color(red(c), green(c), blue(c), 50));
  show(centr, r);
}


void drawBallCenter(Point A, Point B, Point C, Point center, float r, color c) {
  if (center == null)
    return;
    
  fill(c);
  show(center, rb);
  
  beginShape();
  v(B);
  v(A);
  v(C);
  endShape(CLOSE);
  
  //fill(color(red(c), green(c), blue(c), 50));
  //show(center, r);
}

Point ballPivot(Point A, Point B, Point C, Points P, float r) {
  float bestAngle = Float.MAX_VALUE;
  Point bestPoint = null;
  
  for (Point D : P.G) {
    float angle = pivotAngle(A, B, C, D, r);
    
    if (angle < bestAngle) {
      bestAngle = angle;
      bestPoint = D;
    }
  }
  
  return bestPoint;
}

int getSeedTriangleIndex(List<Point> P, float r){
  for (int i = 0; i<P.size(); i++){
    for (int j = i+1; j<P.size(); j++){
      for (int k = j+1; k<P.size(); k++){
        Point sphereCenter = centerOfBall(P.get(i), P.get(j), P.get(k), r);
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
          return getTriangleIndex(i, j, k);
        }
      }
    }
  }
  throw new RuntimeException("No seed triangle found. Better luck next time.");
}

void ballPivot(List<Point> P, float r){

  int firstTriangleIndex = getSeedTriangleIndex(P, r);
  
  Stack<Map.Entry<Integer, Integer>> frontier = new Stack();  // triangleIndex and corner to pivot  
  Set<Map.Entry<Integer, Integer>> explored = new HashSet();

  frontier.push(new AbstractMap.SimpleImmutableEntry(firstTriangleIndex, 0));
  frontier.push(new AbstractMap.SimpleImmutableEntry(firstTriangleIndex, 1));
  frontier.push(new AbstractMap.SimpleImmutableEntry(firstTriangleIndex, 2));
  
  // frontier is a stack of (edges- corner) to pivot over
  while(!frontier.isEmpty()){
    Map.Entry<Integer, Integer> front = frontier.pop();
    if(explored.contains(front)){
      continue;
    }
    explored.add(front);
    int triangleIndex = front.getKey();
    int cornerIndex = front.getValue();

    int aCornerIndex;
    int bCornerIndex;
    
    if (cornerIndex % 3 == 0){
      aCornerIndex = triangleIndex*3 + 1;
      bCornerIndex = triangleIndex*3 + 2;
    } else if (cornerIndex % 3 == 1) {
      aCornerIndex = triangleIndex*3;
      bCornerIndex = triangleIndex*3 + 2;
    }
    else {
      aCornerIndex = triangleIndex*3;
      bCornerIndex = triangleIndex*3 + 1;
    }
    
    int nextTriangleIndex = ballPivot(aCornerIndex, bCornerIndex, cornerIndex, P, r);
    
    if (nextTriangleIndex == triangleIndex){
      // we pivoted to ourselves.
      continue;
    }
    // pick the remaining 2 edges. add them to frontier if not explored already.
    
    int oppIndex = opposites.get(cornerIndex);
    for(int newCornerIndex: Arrays.asList(3*nextTriangleIndex, 3*nextTriangleIndex + 1, 3*nextTriangleIndex +2) ){
      if (newCornerIndex != oppIndex){
        frontier.add(new AbstractMap.SimpleImmutableEntry(nextTriangleIndex, newCornerIndex));
      }  
    }
    
  }
  
  // pop an edge from the frontier 
  // pivot around this edge
  // 
  
}

int ballPivot(int aCornerIndex, int bCornerIndex, int cCornerIndex, List<Point> P, float r) {
  
  int aIndex = corners.get(aCornerIndex), 
    bIndex = corners.get(bCornerIndex),
    cIndex = corners.get(cCornerIndex);
    
  float bestAngle = Float.MAX_VALUE;
  int bestPointIndex = -1;
  
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
  
  int triangleIndex = getTriangleIndex(aIndex, bIndex, bestPointIndex); 

  if (bestPointIndex != cIndex){
    int oppositeIndex = getOpposite(aIndex, bIndex, triangleIndex);
  
    opposites.put(cCornerIndex, oppositeIndex);
    opposites.put(oppositeIndex, cCornerIndex);
  }
  return triangleIndex;
}

int getOpposite(int aIndex, int bIndex, int triangleIndex){
  int dIndex = corners.get(triangleIndex * 3);  
  int eIndex = corners.get(triangleIndex * 3 + 1);  
  int fIndex = corners.get(triangleIndex * 3 + 2);  
  
  int sumAB = aIndex + bIndex; 
  
  if (dIndex + eIndex == sumAB ){
    return fIndex;
  } else if (dIndex + fIndex == sumAB ){
    return eIndex;
  } else {
    return dIndex;
  }
  
}

int getTriangleIndex(int aIndex, int bIndex, int dIndex){
  Triangle t = new Triangle(aIndex, bIndex, dIndex);
  if(vertexTriangleMapping.containsKey(t)){
    return vertexTriangleMapping.get(t);
  } else {
    generatedTriangles.add(t);
    int triangleIndex = generatedTriangles.size() - 1;
    vertexTriangleMapping.put(t, triangleIndex);
        
    corners.put(triangleIndex * 3, aIndex);
    corners.put(triangleIndex * 3 + 1, bIndex);
    corners.put(triangleIndex * 3 + 2, dIndex);
    return triangleIndex;
  }
}