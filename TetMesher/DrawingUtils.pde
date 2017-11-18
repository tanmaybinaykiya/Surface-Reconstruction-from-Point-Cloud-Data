
// *************************************ZZ*****COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB,
   grey=#818181, orange=#FFA600, brown=#B46005, metal=#B5CCDE, 
   lime=#A4FA83, pink=#FCC4FA, dgreen=#057103,
   lightWood=#F5DEA6, darkWood=#D8BE7A;
   
color
  alphared = color(255, 0, 0, 128),
  alphagreen = color(0, 255, 0, 128),
  alphagrey = color(128, 128, 128, 64),
  alphawhite = color(255, 255, 255, 128);
   
color[] palette = { red, green, blue, yellow, cyan, magenta, orange, metal, lime, pink };
   
color getRandomColor(Object o) {
  return palette[abs(o.hashCode() % palette.length)]; 
}

color colorWithAlpha(color c, float alpha) {
  return color(red(c), green(c), blue(c), alpha);
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
  
  float sphereRadius = min(min(d(A,Q), d(B, Q)), min(d(C,Q), d(D,Q)));
  fill(alphagrey);
  show(Q, sphereRadius);
}

void drawTriangle(Point A, Point B, Point C, color floorColor){
  fill(floorColor);
  beam(A, B, rt);
  beam(A, C, rt);
  beam(B, C, rt);
}

void drawInterlevelBeams(Point A, Point B, Point C, Point D, color betweenColor){
  fill(betweenColor);
  beam(A, D, rt);
  beam(B, D, rt);
  beam(C, D, rt);
}

void drawTetrahedron(Point A, Point B, Point C, Point D) {
  // Find the centroid of the tetrahedron, and move each vertex towards the centroid
  Point centroid = P(A, B, C, D);
  float scale = 0.5;
  A = P(A, scale, centroid);
  B = P(B, scale, centroid);
  C = P(C, scale, centroid);
  D = P(D, scale, centroid);
  
  int alpha = 128;
  color col = colorWithAlpha(getRandomColor(centroid), alpha);
  fill(col);
  beginShape(TRIANGLE_STRIP);
  v(A); v(B); v(C); v(D);
  v(A); v(B); v(D);
  v(C); v(B);
  endShape(CLOSE);
}

void drawEdgeSet(Set<Edge> edges, Points floor, Points ceil, color floorColor, color ceilColor, color betweenColor) {
  /*
   * Each edge has two vertex IDs; a positive ID is on the floor, a negative ID is on the ceiling.
   * These IDs also start at 1 (and -1), so they must be adjusted accordingly
   */
   
  for (Edge edge : edges) {
    color col;
    
    if (edge.first > 0 && edge.second > 0)
      col = floorColor;
    else if (edge.first < 0 && edge.second < 0)
      col = ceilColor;
    else
      col = betweenColor;
      
    Point first = edge.getFirstPoint(floor, ceil);
    Point second = edge.getSecondPoint(floor, ceil);
    
    fill(col);
    beam(first, second, rt);
  }
}