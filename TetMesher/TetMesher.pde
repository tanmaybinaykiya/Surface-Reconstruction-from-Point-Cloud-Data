//  ******************* LITM: Layer-Interpolating Tet Mesh, 2017 ***********************
Boolean 
  animating=true, 
  PickedFocus=false, 
  center=true, 
  track=false, 
  showViewer=false, 
  showBalls=true, 
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
  //b4 = true,
  //b5 = true,
  flipOrientation = false;
  
// Flags that track which demo mode we are in
enum DemoMode { DELAUNAY, POINT_SAMPLING, BALL_PIVOTING_MANUAL, BALL_PIVOTING_AUTOMATIC }
DemoMode mode = DemoMode.DELAUNAY;

float 
  h_floor=0, h_ceiling=600, h=h_floor, 
  t=0, 
  s=0, 
  rb=30, rt=rb/2; // radius of the balls and tubes
 
int tetrahedraCount = 0;

int
  f=0, maxf=2*30, level=4, method=5, limit=0;
String SDA = "angle";
float defectAngle=0;
Points P; // polyloop in 3D
Points Q; // second polyloop in 3D
Points R, S; 

Set<Edge> edges;
List<EquilateralMesh> sampledMeshes;
List<Point> pointCloud;
Vector[] pointNormals;

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
  
  //sampledMeshes.add(testSamplePointsOnSphere());
}

void resetAll(){
  generatedTriangles = new ArrayList();
  pivotEdges = new HashMap();
  frontier = new Stack();
  explored = new HashSet();
  boundaryEdges = new HashSet();
  
  pointNormals = new Vector[pointCloud.size()];
  for (int i = 0; i < pointNormals.length; i++) {
    pointNormals[i] = V(0, 0, 0);
  }
}

void draw(){  
  surface.setTitle("FPS: " + String.format("%.2f", frameRate));
  background(255);
  hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(h); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
  
  R.showPicked(rb*1.05);
  
  if (mode == DemoMode.DELAUNAY) {
    /*********************************
     * Part 1: Triangulate the mesh
     *********************************/
     
    if (change) {
      reTriangulate();
    }
    
    if (showBalls) {
      fill(orange); 
      P.drawBalls(rb);
      fill(green); 
      Q.drawBalls(rb);  
      fill(red, 100); 
    }
  
    if (showTube) {
      // Draw all of the edges
      drawEdgeSet(edges, P, Q, green, orange, grey);
    }
  }
  else if (mode == DemoMode.POINT_SAMPLING) {
    ///*********************************
    // * Part 2: Approximate the mesh
    // *********************************/
    
    if (change) {
      // Re-calculate the approximations
      reTriangulate();
      resample();
    }
  
    fill(white);
    stroke(black);
    strokeWeight(1);
    for (EquilateralMesh mesh : sampledMeshes) {
      mesh.draw();
    }
  }
  else if (mode == DemoMode.BALL_PIVOTING_MANUAL) {
    if (change) {
      reTriangulate();
      resample();
    }
    
    ///*********************************
    // * Part 3: Allow user to control ball pivoting
    // *********************************/
    
    resetAll();    
    float r = 20;
    VoxelSpace voxelSpace = new VoxelSpace(pointCloud, r * 2);    
    
    // Add the seed triangle
    // We want to set this at the center of some beam
    Edge beam = edges.iterator().next();
    VoxelCoordinate v1 = voxelSpace.getCoordinate(beam.getFirstPoint(P, Q));
    VoxelCoordinate v2 = voxelSpace.getCoordinate(beam.getSecondPoint(P, Q));
    VoxelCoordinate vMid = new VoxelCoordinate((v1.x + v2.x)/2, (v1.y + v2.y)/2, (v1.z + v2.z)/2);
    
    addSeedEdges(voxelSpace, r, flipOrientation, vMid);    
    println("Added seed edges:", frontier);
    int lastPivotVertex = ballPivot(voxelSpace, r, limit);
    
    fill(pink);
    for (Triangle t: generatedTriangles){
      t.drawMe(b1); // b1 is smooth shading
    }
    
    for (Edge e : explored) {
      fill(red);
      strokeWeight(0);
      beam(pointCloud.get(e.first), pointCloud.get(e.second), 0.1);
    }
    
    for (Edge e : frontier) {
      if (e == frontier.peek()) {
        fill(yellow);
      }
      else {
        fill(green);
      }
      strokeWeight(0);
      beam(pointCloud.get(e.first), pointCloud.get(e.second), 0.1);
    }
  
    if (animating) {
      t += 1;
      
      // Animate the limit
      if (t % 2 == 0) {
        limit += 1;
      }
    }
    
    if (b2) {
      // Show the point cloud around where the ball is
      for (int vertexIndex : voxelSpace.getNeighboringPoints(lastPivotVertex)) {
        Point P = pointCloud.get(vertexIndex);
        fill(blue);
        show(P, 0.5);
      }
    }
  }
  else if (mode == DemoMode.BALL_PIVOTING_AUTOMATIC) {
    ///*********************************
    // * Part 4: Automatic ball pivoting
    // *********************************/
    
    if (change) {
      reTriangulate();
      resample();
      resetAll();    
      
      float r = 20;
      limit = Integer.MAX_VALUE;
      VoxelSpace voxelSpace = new VoxelSpace(pointCloud, r * 2);    
      
      // Add the seed triangle
      // We want to set this at the center of some beam
      Edge beam = edges.iterator().next();
      VoxelCoordinate v1 = voxelSpace.getCoordinate(beam.getFirstPoint(P, Q));
      VoxelCoordinate v2 = voxelSpace.getCoordinate(beam.getSecondPoint(P, Q));
      VoxelCoordinate vMid = new VoxelCoordinate((v1.x + v2.x)/2, (v1.y + v2.y)/2, (v1.z + v2.z)/2);
      
      addSeedEdges(voxelSpace, r, flipOrientation, vMid);    
      println("Added seed edges:", frontier);
      ballPivot(voxelSpace, r, limit);
    }
    
    fill(pink);
    for (Triangle t: generatedTriangles){
      t.drawMe(b1); // b1 is smooth shading
    }
  }
  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible

  //*** TEAM: please fix these so that they provice the correct counts
  int floorBeams = 0, ceilingBeams = 0, mixedBeams = 0;
  for (Edge edge : edges) {
    if (edge.first > 0 && edge.second > 0) 
      floorBeams++;
    else if (edge.first < 0 && edge.second < 0) 
      ceilingBeams++;
    else 
      mixedBeams++;
  }
  
  scribeHeader("Site count: " + P.nv + " floor + " + Q.nv + " ceiling ", 1);
  scribeHeader("Beam count: " + floorBeams + " floor + " + ceilingBeams + " ceiling " + mixedBeams + " mixed", 2);
  scribeHeader("Tet count: " + tetrahedraCount, 3);

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
  tetrahedraCount = 0;

  if (mode == DemoMode.DELAUNAY) {
    // In this demo mode, allow the user to change which tubes to show
    if (b1) // 1-3 
      edges.addAll(triangulate(P, Q, true));
  
    if (b2) // 2-2
      edges.addAll(triangulate2to2(P, Q));
  
    if (b3) // 3-1
      edges.addAll(triangulate(P, Q, false));
  }
  else {
    // In other modes, always do all triangulations
      edges.addAll(triangulate(P, Q, true));
      edges.addAll(triangulate2to2(P, Q));
      edges.addAll(triangulate(P, Q, false));
  }
  
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