//  ******************* LITM: Layer-Interpolating Tet Mesh, 2017 ***********************
Boolean 
  animating=true, 
  PickedFocus=false, 
  center=true, 
  track=false, 
  showViewer=false, 
  showBalls=false, 
  showControl=true, 
  showCurve=true, 
  showPath=true, 
  showKeys=true, 
  showSkater=false, 
  scene1=false, 
  solidBalls=false, 
  showCorrectedKeys=true, 
  showQuads=true, 
  showVecs=true, 
  showTube=true, 
  flipped = false, 
  b1 = true, 
  b2 = true, 
  b3 = true, 
  b4 = true,
  flipOrientation = false;
float 
  h_floor=0, h_ceiling=600, h=h_floor, 
  t=0, 
  s=0, 
  rb=30, rt=rb; // radius of the balls and tubes

int
  f=0, maxf=2*30, level=4, method=5, limit=9;
String SDA = "angle";
float defectAngle=0;
Points P; // polyloop in 3D
Points Q; // second polyloop in 3D
Points R, S; 

Set<Edge> edges;
List<EquilateralMesh> sampledMeshes;
List<Point> pointCloud;

List<Triangle> generatedTriangles ;
Map<Edge, Integer> pivotEdges;
Stack<Edge> frontier;
Set<Edge> explored;
Set<Edge> boundaryEdges;

void setup() {
  
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);          
  size(900, 900, P3D); // P3D means that we will do 3D graphics
  P = new Points();
  Q = new Points();
  P.declare(); 
  Q.declare(); // P is a polyloop in 3D: declared in pts
  //P.resetOnCircle(6,100); Q.copyFrom(P); // use this to get started if no model exists on file: move points, save to file, comment this line
  P.loadPts("data/pts");  
  Q.loadPts("data/pts2"); // loads saved models from file (comment out if they do not exist yet)
  noSmooth();
  frameRate(30);
  R=P; 
  S=Q;
  
  edges = new HashSet();
  sampledMeshes = new ArrayList();
  pointCloud = new ArrayList();
  resetAll();
  
  // Re-render initially
  change = true;
  
  reTriangulate();
  resample();
  
  
    

  
  //sampledMeshes.add(testSamplePointsOnSphere());
}

void resetAll(){
  //edges = new HashSet();
  //sampledMeshes = new ArrayList();
  //pointCloud = new ArrayList();
  generatedTriangles = new ArrayList();
  pivotEdges = new HashMap();
  frontier = new Stack();
  explored = new HashSet();
  boundaryEdges = new HashSet();
}

void draw(){  
  surface.setTitle("FPS: " + String.format("%.2f", frameRate));
  background(255);
  //hint(ENABLE_DEPTH_TEST); 
  //pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(h); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
  //hint(DISABLE_DEPTH_TEST);
  
  if (showBalls) 
  {
    fill(orange); 
    P.drawBalls(rb*0.7);
    fill(green); 
    Q.drawBalls(rb*0.7);  
    fill(red, 100); 
    R.showPicked(rb*0.8);
  }
    
  //for (Point p : pointCloud) {
  //  fill(blue, 100);
  //  strokeWeight(1);
  //  stroke(grey);
  //  show(p, 0.1);
  //}
  
  //for (int i =0; i<P.nv; i++){
  //  pointCloud.add(P.G.get(i));
  //}
  //for (int i =0; i<Q.nv; i++){
  //  pointCloud.add(Q.G.get(i));
  //}
  
  
  if (change) {
    resetAll();    
    reTriangulate();
    resample();
    
    float r = 20;
    VoxelSpace voxelSpace = new VoxelSpace(pointCloud, r * 2);
    //println("Voxels:", voxelSpace.voxels.size());
  
    limit = Integer.MAX_VALUE;
    ballPivot(voxelSpace, r, flipOrientation, limit);
  }
  
  strokeWeight(1);
  stroke(black);
  fill(pink, 200);
  //println("Triangles:", generatedTriangles.size());
  for (Triangle t: generatedTriangles){
    t.drawMe();
    //Point A = pointCloud.get(t.aIndex);
    //Point B = pointCloud.get(t.bIndex);
    //Point C = pointCloud.get(t.cIndex);
    //println("A:", A, "B:", B, "C:", C);
    
    //fill(red, 100); show(A, 1);
    //fill(green, 100); show(B, 1);
    //fill(blue, 100); show(C, 1);
  }
  
  //for (Edge e : explored) {
  //  fill(red);
  //  strokeWeight(0);
  //  beam(pointCloud.get(e.first), pointCloud.get(e.second), 0.1);
  //}
  
  //for (Edge e : frontier) {
  //  if (e == frontier.peek()) {
  //    fill(yellow);
  //  }
  //  else {
  //    fill(green);
  //  }
  //  strokeWeight(0);
  //  beam(pointCloud.get(e.first), pointCloud.get(e.second), 0.1);
  //}
  
  change = false;
}

void test_draw(){
  //testSamplePointsOnSphere();
  for (EquilateralMesh sampledMesh:sampledMeshes){
    sampledMesh.draw();
  }
  //resample();
}



void real_draw() {
  background(255);
  //hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(h); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
  //hint(DISABLE_DEPTH_TEST);
  
  if (showBalls) 
  {
    fill(orange); 
    P.drawBalls(rb*0.7);
    fill(green); 
    Q.drawBalls(rb*0.7);  
    //fill(red, 100); 
    //R.showPicked(rb*0.9);
  }
  
  float r = 100;
  Point A = Q.G.get(0), B = Q.G.get(1), C = Q.G.get(2);
  //Point D1 = P.G.get(0), D2 = P.G.get(1);
  
  //float angle1 = pivotAngle(B, C, A, D1, r);
  //float angle2 = pivotAngle(B, C, A, D2, r);
  //Point D = (angle1 < angle2 ? D1 : D2);
  
  //Point centerABC = centerOfBall(A, B, C, r);
  //Point centerCBD = centerOfBall(C, B, D, r);
  
  //drawBallCenter(A, B, C, centerABC, r, blue);
  //drawBallCenter(C, B, D, centerCBD, r, orange);
  
  //Point D1 = ballPivot(A, B, C, P, r);
  //Point D2 = ballPivot(B, C, A, P, r);
  //Point D3 = ballPivot(C, A, B, P, r);
  
  //drawBallCenter(A, B, C, centerOfBall(A, B, C, r), r, blue);
  //drawBallCenter(B, A, D1, centerOfBall(B, A, D1, r), r, red);
  //drawBallCenter(C, B, D2, centerOfBall(C, B, D2, r), r, green);
  //drawBallCenter(A, C, D3, centerOfBall(A, C, D3, r), r, orange);

  /*********************************
   * Part 1: Triangulate the mesh
   *********************************/
  //if (change) {
  //  reTriangulate();
  //}

  //if (showTube) {
  //  // Draw all of the edges
    //drawEdgeSet(edges, P, Q, green, orange, grey);
  //}

  ///*********************************
  // * Part 2: Approximate the mesh
  // *********************************/
  //if (change) {
  //  // Re-calculate the approximations
  //  resample();
  //}

  //fill(white);
  //stroke(black);
  //strokeWeight(1);
  //for (EquilateralMesh mesh : sampledMeshes) {
  //  mesh.draw();
  //}
  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible

  //*** TEAM: please fix these so that they provice the correct counts
  scribeHeader("Site count: " + 3 + " floor + " + 7 + " ceiling ", 1);
  scribeHeader("Beam count: " + 3 + " floor + " + 7 + " ceiling " + 6 + " mixed", 2);
  scribeHeader("Tet count: " + 20, 3);

  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if (mousePressed) {
    stroke(cyan); 
    strokeWeight(3); 
    noFill(); 
    ellipse(mouseX, mouseY, 20, 20); 
    strokeWeight(1);
  }
  if (keyPressed) {
    stroke(red); 
    fill(white); 
    ellipse(mouseX+14, mouseY+20, 26, 26); 
    fill(red); 
    text(key, mouseX-5+14, mouseY+4+20); 
    strokeWeight(1);
  }
  if (scribeText) {
    fill(black); 
    displayHeader();
  } // dispalys header on canvas, including my face
  if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++, 4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  //change=true;
}


void reTriangulate(){
  // Re-calculate triangulation
  edges.clear();

  if (b1) // 1-3 
    edges.addAll(triangulate(P, Q, true));

  if (b2) // 2-2
    edges.addAll(triangulate2to2(P, Q));

  if (b3) // 3-1
    edges.addAll(triangulate(P, Q, false));
  
}

void resample(){
  sampledMeshes.clear();

  //Floor
  for (int i =0; i<P.nv; i++) {
    Point S = P.G.get(i);
    sampledMeshes.add(samplePointsOnSphere(S, rb));
    //break;
  }
  
  //Ceiling
  for (int i =0; i<Q.nv; i++) {
    Point S = Q.G.get(i);
    sampledMeshes.add(samplePointsOnSphere(S, rb));
  }

  // Beams
  for (Edge edge : edges) {
    sampledMeshes.add(samplePointsOnBeam(edge, P, Q, rt));
  }
  
  pointCloud.clear();
  
  for (EquilateralMesh mesh: sampledMeshes){
    pointCloud.addAll(mesh.getAllPoints());
  }
}