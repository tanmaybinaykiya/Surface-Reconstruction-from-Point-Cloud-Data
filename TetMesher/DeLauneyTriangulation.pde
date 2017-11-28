Point circumcircleCenter(Point A, Point B, Point C) {
  // Find the circumcenter of these three points
  Point M = L(A, 0.5, B);
  Point H = L(A, 0.5, C);

  // Find the vector of the bisector (use cross-products to find this)
  Vector I = V(M, B);
  Vector K = cross(I, V(A, C));
  Vector J = cross(I, K);
  Vector MP = U(J);

  // Compute the magnitude to move towards P
  Vector AM = V(A, M);
  Vector AH = V(A, H);
  float s = (dot(AH, AH) - (dot(AM, AH))) / dot(MP, AH);

  // Compute P
  return P(M, s, MP);
}

/**
  P: circumcenter of triangle A, B, C
*/

Point circumsphereCenter(Point P, Point A, Point B, Point C, Point D) {
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
  Vector N = U(cross(V(A, C), V(B, C)));

  // Obtain the vectors needed for the calculation
  Point Z = L(A, 0.5, D);
  Vector AP = V(A, P);
  Vector AZ = V(A, Z);

  // Compute the location of Q, the circumcenter of the sphere
  float s = (dot(AZ, AZ) - dot(AP, AZ)) / dot(N, AZ);
  return P(P, s, N);
}

Set<Edge> triangulate2to2(Points floor, Points ceil) {
  Set<Edge> edges = new HashSet();

  // Find every triplet of points in the pointset
  for (int a = 0; a < floor.nv; a++) {
    for (int b = a + 1; b < floor.nv; b++) {
      for (int c = 0; c < ceil.nv; c++) {
        for (int d = c + 1; d < ceil.nv; d++) {
          Point A = floor.G.get(a);
          Point B = floor.G.get(b);
          Point C = ceil.G.get(c);
          Point D = ceil.G.get(d);

          Point P = circumcircleCenter(A, B, C);
          Point Q = circumsphereCenter(P, A, B, C, D);
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

          edges.add(edgeFloorFloor(a, b));
          edges.add(edgeFloorCeiling(a, c));
          edges.add(edgeFloorCeiling(a, d));
          edges.add(edgeFloorCeiling(b, c));
          edges.add(edgeFloorCeiling(b, d));
          edges.add(edgeCeilingCeiling(c, d));

          tetrahedraCount++;
          //if (b4)
          //  drawTetrahedron(A, B, C, D);
        }
      }
    }
  }

  return edges;
}

Set<Edge> triangulate(Points floor, Points ceil, boolean flip) {
  Set<Edge> edges = new HashSet();

  // Used to keep track of whether floor and ceiling indices are flipped
  if (flip) {
    Points temp = floor;
    floor = ceil;
    ceil = temp;
  }

  // Find every triplet of points in the pointset
  for (int a = 0; a < floor.nv; a++) {
    for (int b = a + 1; b < floor.nv; b++) {
      for (int c = b + 1; c < floor.nv; c++) {
        Point A = floor.G.get(a);
        Point B = floor.G.get(b);
        Point C = floor.G.get(c);

        Point P = circumcircleCenter(A, B, C);
        float circumCircleRadius = min(d(A, P), d(B, P), d(C, P));

        // Find all other points and determine if they lie in this circumcenter (skip if so)
        boolean foundInside = false;
        for (int l = 0; l < floor.nv; l++) {
          foundInside = !((l == a || l == b || l == c) ) && (d(floor.G.get(l), P) < circumCircleRadius);
          if (foundInside) break;
        }

        if (foundInside)
          continue;

        if (flip) {
          edges.add(edgeCeilingCeiling(a, b));
          edges.add(edgeCeilingCeiling(b, c));
          edges.add(edgeCeilingCeiling(c, a));
        } else {
          edges.add(edgeFloorFloor(a, b));
          edges.add(edgeFloorFloor(b, c));
          edges.add(edgeFloorFloor(c, a));
        }

        int d = findClosestPointOnCeilingUsingBulge(P, ceil);

        if (d != -1) {
          Point D = ceil.G.get(d);

          if (flip) {
            edges.add(edgeCeilingFloor(a, d));
            edges.add(edgeCeilingFloor(b, d));
            edges.add(edgeCeilingFloor(c, d));
          } else {
            edges.add(edgeFloorCeiling(a, d));
            edges.add(edgeFloorCeiling(b, d));
            edges.add(edgeFloorCeiling(c, d));
          }

          tetrahedraCount++;
          //if (b4)
          //  drawTetrahedron(A, B, C, D);
        }
      }
    }
  }

  return edges;
}

int findClosestPointOnCeilingUsingBulge(Point P, Points ceiling) {

  // assumes that both the planes are parallel. will have to resort to O(n^2) approach for non parallel planes
  if (ceiling.nv == 0) {
    //throw new RuntimeException("No points in ceiling");
    return -1;
  }
  // projection of P on ceiling plane - just copying x, y values 
  Point PDash = P(P.x, P.y, ceiling.G.get(0).z);
  int d = 0;
  float minDist =  d(PDash, ceiling.G.get(0));
  for (int i =1; i<ceiling.nv; i++) {
    float dist = d(PDash, ceiling.G.get(i));
    if (dist < minDist) {
      d = i;
      minDist = dist;
    }
  }
  return d;
}