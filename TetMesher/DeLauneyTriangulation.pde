pt circumcenter(pt A, pt B, pt C) {
  // Find the circumcenter of these three points
  pt M = L(A, 0.5, B);
  pt H = L(A, 0.5, C);
  
  // Find the vector of the bisector (use cross-products to find this)
  vec I = V(M,B);
  vec K = cross(I, V(A,C));
  vec J = cross(I, K);
  vec MP = U(J);
  
  // Compute the magnitude to move towards P
  vec AM = V(A, M);
  vec AH = V(A, H);
  float s = (dot(AH, AH) - (dot(AM, AH))) / dot(MP, AH);
  
  // Compute P
  pt P = P(M, s, MP);    
  
  return P;
}
  
void triangulate(pts floor, color floorColor, pts ceil, color ceilColor, color betweenColor) {
  // Find every triplet of points in the pointset
  for (int a = 0; a < floor.nv; a++) {
    for (int b = a + 1; b < floor.nv; b++) {
      for (int c = b + 1; c < floor.nv; c++) {
        pt A = floor.G[a];
        pt B = floor.G[b];
        pt C = floor.G[c];
        
        pt P = circumcenter(A, B, C);
        float circleRadius = min(d(A, P), d(B, P), d(C, P));
        
        // Find all other points and determine if they lie in this circumcenter (skip if so)
        boolean foundInside = false;
        for (int l = 0; l < floor.nv; l++) {
          if (l == a || l == b || l == c) 
            continue;
            
          if (d(floor.G[l], P) < circleRadius) {
            foundInside = true;
            break;
          }
        }
        
        if (foundInside)
          continue;
          
        // Draw the triangle    
        //drawCircumcenter(P, A, B, C, alphared, true);
        fill(floorColor);
        beam(A, B, rt);
        beam(A, C, rt);
        beam(B, C, rt);
        
        for (int d = 0; d < ceil.nv; d++) {
          pt D = ceil.G[d];
          
          /*****************************************************************
           The circumcenter of the sphere is given by Q = P + sN, where
             P is a circumcenter of one of the triangles
             N is the normal to that triangle
          
           Using the two triangles APQ and ADQ, we can compute Q similar to 
           computing the circumcenter of a triangle:
             Q = P + sN
             AQ = AP + sN
             AQ.AZ = AP.AZ + sN.AZ
                (where Z is midpoint of AD, and therefore AQ.AZ == AZ.AZ)
             s = (AZ.AZ - AP.AZ) / N.AZ
          ******************************************************************/
          
          // Normal to triangle ABC
          vec N = U(cross(V(A,C), V(B,C)));
          
          // Obtain the vectors needed for the calculation
          pt Z = L(A, 0.5, D);
          vec AP = V(A, P);
          vec AZ = V(A, Z);
          
          // Compute the location of Q, the circumcenter of the sphere
          float s = (dot(AZ, AZ) - dot(AP, AZ)) / dot(N, AZ);
          pt Q = P(P, s, N);
          
          float sphereRadius = min(min(d(A,Q), d(B,Q), d(C,Q)), d(D,Q));
          //fill(alphagrey);
          //show(Q, sphereRadius);
          
          foundInside = false;
          for (int e = 0; e < ceil.nv; e++) {
            pt E = ceil.G[e];
            if (d(E,Q) < sphereRadius) {
              foundInside = true;
              break;
            }
          }
          
          if (foundInside) {
            continue;
          }
          
          // Draw the circumsphere
          //drawCircumcenter(Q, A, B, C, D, alphagrey, true);
          fill(betweenColor);
          beam(A, D, rt);
          beam(B, D, rt);
          beam(C, D, rt);
        }
      }
    }
  }
}

void drawCircumcenter(pt P, pt A, pt B, pt C, color col, boolean showBeams) {
  // Draw the components
  fill(col);
  show(P, rb / 5);  // circumcenter
  
  if (showBeams) {
    beam(A, P, rt / 5);
    beam(B, P, rt / 5);
    beam(C, P, rt / 5);
  }
}

void drawCircumcenter(pt Q, pt A, pt B, pt C, pt D, color col, boolean showBeams) {
  // Draw the components
  fill(col);
  show(Q, rb / 5);  // circumcenter
  
  if (showBeams) {
    beam(A, Q, rt / 5);
    beam(B, Q, rt / 5);
    beam(C, Q, rt / 5);
    beam(D, Q, rt / 5);
  }
}