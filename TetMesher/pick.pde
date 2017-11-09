// suppport of 3D picking and dragging in user's (i.e., screen) coordinate system

import java.nio.*;
import processing.core.PMatrix3D;
pt PP=P(); // picked point
Boolean  picking=false;

float dz=0;                                 // distance to camera. Manipulated with wheel or when 's' is pressed and mouse moved
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;     // view angles manipulated when space bar (but not mouse) is pressed and mouse is moved
pt Viewer = P(); // location of the viewpoint
pt F = P(1000,1000,h_ceiling/2);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt Of=P(1000,1000,0), Ofp=P(1000,1000,0); // current and previous point on the floor under the mouse
boolean viewpoint=false;  // set to show frozen viewpoint and frustum from a different angle

//*********** TOOLS FOR 3D PICK ******************
pt ToScreen(pt P) {return P(screenX(P.x,P.y,P.z),screenY(P.x,P.y,P.z),0);}  // O+xI+yJ+kZ
pt ToModel(pt P) {return P(modelX(P.x,P.y,P.z),modelY(P.x,P.y,P.z),modelZ(P.x,P.y,P.z));}  // O+xI+yJ+kZ

vec I=V(1,0,0), J=V(0,1,0), K=V(0,0,1); // screen projetions of global model frame

void computeProjectedVectors() { 
  pt O = ToScreen(P(0,0,0));
  pt A = ToScreen(P(1,0,0));
  pt B = ToScreen(P(0,1,0));
  pt C = ToScreen(P(0,0,1));
  I=V(O,A);
  J=V(O,B);
  K=V(O,C);
  }

vec ToIJ(vec V) {
 float x = det2(V,J) / det2(I,J);
 float y = det2(V,I) / det2(J,I);
 return V(x,y,0);
 }
 
vec ToK(vec V) {
 float z = dot(V,K) / dot(K,K);
 return V(0,0,z);
 }
 
 
public pt pick(int mX, int mY) { // returns point on visible surface at pixel (mX,My)
  PGL pgl = beginPGL();
  FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.nativeOrder()).asFloatBuffer();
  pgl.readPixels(mX, height - mY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
  float depthValue = depthBuffer.get(0);
  depthBuffer.clear();
  endPGL();

  //get 3d matrices
  PGraphics3D p3d = (PGraphics3D)g;
  PMatrix3D proj = p3d.projection.get();
  PMatrix3D modelView = p3d.modelview.get();
  PMatrix3D modelViewProjInv = proj; modelViewProjInv.apply( modelView ); modelViewProjInv.invert();
  
  float[] viewport = {0, 0, p3d.width, p3d.height};
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = depthValue * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  
  float[] unprojected = new float[4];
  
  modelViewProjInv.mult( normalized, unprojected );
  return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
  }

public pt pick(float mX, float mY, float mZ) { 
  PGraphics3D p3d = (PGraphics3D)g;
  PMatrix3D proj = p3d.projection.get();
  PMatrix3D modelView = p3d.modelview.get();
  PMatrix3D modelViewProjInv = proj; modelViewProjInv.apply( modelView ); modelViewProjInv.invert();
  float[] viewport = {0, 0, p3d.width, p3d.height};
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = mZ * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  float[] unprojected = new float[4];
  modelViewProjInv.mult( normalized, unprojected );
  return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
  }
  
  void setView() 
    {
    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    camera(0,0,cameraZ,0,0,0,0,1,0  );       // sets a standard perspective
    perspective(fov, 1.0, 0.1, 10000);
    
    translate(0,0,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
    if(center) translate(-F.x,-F.y,-F.z);  // center the focus on F
    
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
    //showFrame(50); // show the vectors of the main coordinate system: X-red, Y-green, Z-blue arrows
    }
 
    
  void doPick()
    {
    Ofp.setTo(Of); // places Of on the floor under the mouse  
    Of = pick( mouseX, mouseY);  
    if(mousePressed&&!keyPressed) // when mouse is pressed (but no key), show red ball at surface point under the mouse (and its shadow)
       {
       PickedFocus=false;  
       fill(magenta); show(Of,3);  fill(grey); show(Ofp,3); 
       }  
    // Locks focus on point Of until Of is reset (mouse pressed, but no key)
    if(PickedFocus) F=P(Of); 
    // show focus point F and its shadow
    fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
    fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'
    computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    

    //P.setIdOfVertexWithClosestScreenProjectionTo2(Mouse()); // ID of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...
    }

pt viewPoint() {return pick( 0,0, (height/2) / tan(PI/6));}
/*  
in draw, before popMatrix, insert
      
    if(picking) {PP = pick( mouseX, mouseY ); picking=false;} else {fill(yellow); show(PP,3);}

in keyPressed, 

      if(key=='`') picking=true; 

*/