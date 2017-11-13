Point circumcenter(Point A, Point B, Point C) {
  // Find the circumcenter of these three points
  Point M = L(A, 0.5, B);
  Point H = L(A, 0.5, C);
  
  // Find the vector of the bisector (use cross-products to find this)
  Vector I = V(M,B);
  Vector K = cross(I, V(A,C));
  Vector J = cross(I, K);
  Vector MP = U(J);
  
  // Compute the magnitude to move towards P
  Vector AM = V(A, M);
  Vector AH = V(A, H);
  float s = (dot(AH, AH) - (dot(AM, AH))) / dot(MP, AH);
  
  // Compute P
  Point P = P(M, s, MP);    
  
  return P;
}

void triangulate2to2(Points floor, color floorColor, Points ceil, color ceilColor, color betweenColor) {
  // Find every triplet of points in the pointset
  for (int a = 0; a < floor.nv; a++) {
    for (int b = a + 1; b < floor.nv; b++) {
      for (int c = 0; c < ceil.nv; c++) {
        for (int d = c + 1; d < ceil.nv; d++) {
          Point A = floor.G.get(a);
          Point B = floor.G.get(b);
          Point C = ceil.G.get(c);
          Point D = ceil.G.get(d);
          
          Point P = circumcenter(A, B, C);
          Point Q = computeCircumsphereCenter(P,A,B,C,D);
          float minRadius = min(min(d(A, Q), d(B, Q), d(C, Q)), d(D, Q));
          
          boolean foundInside = false;
          for (int m = 0; m < floor.nv; m++) {
            if (m == a || m == b)
              continue;
              
            Point M = floor.G.get(m);
            if (d(M, Q) < minRadius) {
              foundInside = true;
              break;
            }
          }
          for (int n = 0; n < ceil.nv; n++) {
            if (n == c || n == d)
              continue;
              
            Point N = ceil.G.get(n);
            if (d(N, Q) < minRadius) {
              foundInside = true;
              break;
            }
          }
          
          if (foundInside)
            continue;
          
          drawTriangle(A, B, C, floorColor);
          drawTriangle(A, B, D, floorColor);
          drawTriangle(A, C, D, ceilColor);
          drawTriangle(B, C, D, ceilColor);
        }
      }
    }
  }
}
  
void triangulate(Points floor, color floorColor, Points ceil, color ceilColor, color betweenColor) {
  // Find every triplet of points in the pointset
  for (int a = 0; a < floor.nv; a++) {
    for (int b = a + 1; b < floor.nv; b++) {
      for (int c = b + 1; c < floor.nv; c++) {
        Point A = floor.G.get(a);
        Point B = floor.G.get(b);
        Point C = floor.G.get(c);
        
        Point P = circumcenter(A, B, C);
        float circumCircleRadius = min(d(A, P), d(B, P), d(C, P));
        
        // Find all other points and determine if they lie in this circumcenter (skip if so)
        boolean foundInside = false;
        for (int l = 0; l < floor.nv; l++) {
          foundInside = !((l == a || l == b || l == c) ) && (d(floor.G.get(l), P) < circumCircleRadius);
          if (foundInside) break;
        }
        
        if (foundInside)
          continue;
  
        drawTriangle(A, B, C, floorColor);

        Point D = findClosestPointOnCeilingUsingBulge(P, ceil);
        if (D != null) {
          drawInterlevelBeams(A, B, C, D, betweenColor);
        }
      }
    }
  }
}

Point findClosestPointOnCeilingUsingBulge(Point P, Points ceiling){
  
  // assumes that both the planes are parallel. will have to resort to O(n^2) approach for non parallel planes
  if(ceiling.nv == 0){
    //throw new RuntimeException("No points in ceiling");
    return null;
  }
  // projection of P on ceiling plane - just copying x, y values 
  Point PDash = P(P.x, P.y, ceiling.G.get(0).z);
  Point D = ceiling.G.get(0);
  float minDist =  d(PDash, ceiling.G.get(0));
  for (int i =1; i<ceiling.nv; i++){
    float dist = d(PDash, ceiling.G.get(i));
    if (dist < minDist) {
      D = ceiling.G.get(i);
      minDist = dist;
    }
  }
  return D;  
}

void drawTriangle(Point A, Point B, Point C, color floorColor){
  fill(floorColor);
  beam(A, B, rt);
  beam(A, C, rt);
  beam(B, C, rt);
  
  //fill(color(red(floorColor), green(floorColor), blue(floorColor), 50));
  //beginShape();
  //v(A); v(B); v(C);
  //endShape(CLOSE);
}

void drawInterlevelBeams(Point A, Point B, Point C, Point D, color betweenColor){
  fill(betweenColor);
  beam(A, D, rt);
  beam(B, D, rt);
  beam(C, D, rt);
  
  //fill(color(red(betweenColor), green(betweenColor), blue(betweenColor), 50));
  //beginShape(TRIANGLE_STRIP);
  //v(A); v(B); v(C); v(D);
  //v(A); v(B); v(D);
  //v(C); v(B);
  //endShape(CLOSE);
  
  //beginShape(); v(A); v(B); v(D); endShape(CLOSE);
  //beginShape(); v(A); v(C); v(D); endShape(CLOSE);
  //beginShape(); v(B); v(C); v(D); endShape(CLOSE);
}

Point computeCircumsphereCenter(Point P, Point A, Point B, Point C, Point D){
    // The circumcenter of the sphere is given by Q = P + sN, where
    //   P is a circumcenter of triangle ABC
    //   N is the normal to that triangle
    //
    // Using the two triangles APQ and ADQ, we can compute Q similar to 
    // computing the circumcenter of a triangle:
    //   Q = P + sN
    //   AQ = AP + sN
    //   AQ.AZ = AP.AZ + sN.AZ
    //      (where Z is midpoint of AD, and therefore AQ.AZ == AZ.AZ)
    //   s = (AZ.AZ - AP.AZ) / N.AZ
    
    // Normal to triangle ABC
    Vector N = U(cross(V(A,C), V(B,C)));
    
    // Obtain the vectors needed for the calculation
    Point Z = L(A, 0.5, D);
    Vector AP = V(A, P);
    Vector AZ = V(A, Z);
    
    // Compute the location of Q, the circumcenter of the sphere
    float s = (dot(AZ, AZ) - dot(AP, AZ)) / dot(N, AZ);
    return P(P, s, N);

}

void drawCircumcircle(Point P, Point A, Point B, Point C, color col, boolean showBeams) {
  // Draw the components
  fill(col);
  show(P, rb / 5);  // circumcenter
  
  if (showBeams) {
    beam(A, P, rt / 5);
    beam(B, P, rt / 5);
    beam(C, P, rt / 5);
  }
}

void drawCircumsphere(Point Q, Point A, Point B, Point C, Point D, color col, boolean showBeams) {
  // Draw the components
  
  if (showBeams) {
    beam(A, Q, rt / 5);
    beam(B, Q, rt / 5);
    beam(C, Q, rt / 5);
    beam(D, Q, rt / 5);
  }
  
  float sphereRadius = min(min(d(A,Q), d(B,Q), d(C,Q)), d(D,Q));
  fill(alphagrey);
  show(Q, sphereRadius);
}