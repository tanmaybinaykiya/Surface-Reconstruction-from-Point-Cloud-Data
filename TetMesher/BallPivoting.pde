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