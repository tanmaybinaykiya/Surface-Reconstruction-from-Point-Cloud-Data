// **************************** DISPLAY PRIMITIVES (spheres, cylinders, cones, arrows) from 3D Pts, Vecs *********
// procedures for showing balls and lines are in tab "pv3D" (for example "show(P,r)")

void sphere(pt P, float r) {pushMatrix(); translate(P.x,P.y,P.z); sphere(r); popMatrix();}; // render sphere of radius r and center P (same as show(P,r))

// **************************** PRIMITIVE FROM POINT, VECTOR, RADIUS PARAMETER
void caplet(pt A, float a, pt B, float b) { // cone section surface that is tangent to Sphere(A,a) and to Sphere(B,b)
  vec I = U(A,B);
  float d = d(A,B), s=b/a;
  float x=(a-b)*a/d, y = sqrt(sq(a)-sq(x));
  pt PA = P(A,x,I), PB = P(B,s*x,I); 
  coneSection(PA,PB,y,y*s);
  }  

void coneSection(pt P, pt Q, float p, float q) { // surface
  vec V = V(P,Q);
  vec I = U(Normal(V));
  vec J = U(N(I,V));
  collar(P,V,I,J,p,q);
  }

void cylinderSection(pt P, pt Q, float r) { coneSection(P,Q,r,r);}
 


// FANS, CONES, AND ARROWS
void disk(pt P, vec I, vec J, float r) {
  float da = TWO_PI/36;
  beginShape(TRIANGLE_FAN);
    v(P);
    for(float a=0; a<=TWO_PI+da; a+=da) v(P(P,r*cos(a),I,r*sin(a),J));
  endShape();
  }
  
void disk(pt P, vec V, float r) {  
  vec I = U(Normal(V));
  vec J = U(N(I,V));
  disk(P,I,J,r);
  }

void fan(pt P, vec V, vec I, vec J, float r) {
  float da = TWO_PI/36;
  beginShape(TRIANGLE_FAN);
    v(P(P,V));
    for(float a=0; a<=TWO_PI+da; a+=da) v(P(P,r*cos(a),I,r*sin(a),J));
  endShape();
  }
  
void fan(pt P, vec V, float r) {  
  vec I = U(Normal(V));
  vec J = U(N(I,V));
  fan(P,V,I,J,r);
  }

void collar(pt P, vec V, float r, float rd) {
  vec I = U(Normal(V));
  vec J = U(N(I,V));
  collar(P,V,I,J,r,rd);
  }
 
void collar(pt P, vec V, vec I, vec J, float r, float rd) {
  float da = TWO_PI/36;
  beginShape(QUAD_STRIP);
    for(float a=0; a<=TWO_PI+da; a+=da) {v(P(P,r*cos(a),I,r*sin(a),J,0,V)); v(P(P,rd*cos(a),I,rd*sin(a),J,1,V));}
  endShape();
  }

void cone(pt P, vec V, float r) {fan(P,V,r); disk(P,V,r);}

void beam(pt P, pt Q, float r) // cone section
  {
  stub(P,V(P,Q),r,r);
  }

void stub(pt P, vec V, float r, float rd) // cone section
  {
  collar(P,V,r,rd); disk(P,V,r); disk(P(P,V),V,rd); 
  }

void arrow(pt A, pt B, float r) {
  vec V=V(A,B);
  stub(A,V(.8,V),r*2/3,r/3); 
  cone(P(A,V(.8,V)),V(.2,V),r); 
  }  
  
void arrow(pt P, float s, vec V, float r) {arrow(P,V(s,V),r);}

void arrow(pt P, vec V, float r) {
  stub(P,V(.8,V),r*2/3,r/3); 
  cone(P(P,V(.8,V)),V(.2,V),r); 
  }  
  

void block(float w, float d, float h, float x, float y, float z, float a) {
  pushMatrix(); translate(x,y,z); rotateZ(TWO_PI*a); box(w, d, h); popMatrix(); 
  }
  

// **************************** PRIMITIVE IN NOMINAL POSITION (Origin, Z-axis)
void showFrame(float d) { 
  noStroke(); 
  fill(metal); sphere(d/10);
  fill(blue);  showArrow(d,d/10);
  fill(red); pushMatrix(); rotateY(PI/2); showArrow(d,d/10); popMatrix();
  fill(green); pushMatrix(); rotateX(-PI/2); showArrow(d,d/10); popMatrix();
  }

void showFan(float d, float r) {
  float da = TWO_PI/36;
  beginShape(TRIANGLE_FAN);
    vertex(0,0,d);
    for(float a=0; a<=TWO_PI+da; a+=da) vertex(r*cos(a),r*sin(a),0);
  endShape();
  }

void showCollar(float d, float r, float rd) {
  float da = TWO_PI/36;
  beginShape(QUAD_STRIP);
    for(float a=0; a<=TWO_PI+da; a+=da) {vertex(r*cos(a),r*sin(a),0); vertex(rd*cos(a),rd*sin(a),d);}
  endShape();
  }

void showCone(float d, float r) {showFan(d,r);  showFan(0,r);}

void showStub(float d, float r, float rd) {
  showCollar(d,r,rd); showFan(0,r);  pushMatrix(); translate(0,0,d); showFan(0,rd); popMatrix();
  }

void showArrow() {showArrow(1,0.08);}
 
void showArrow(float d, float r) {
  float dd=d/5;
  showStub(d-dd,r*2/3,r/3); pushMatrix(); translate(0,0,d-dd); showCone(dd,r); popMatrix();
  }  
  
void showBlock(float w, float d, float h, float x, float y, float z, float a) {
  pushMatrix(); translate(x,y,h/2); rotateZ(TWO_PI*a); box(w, d, h); popMatrix(); 
  }
  
void showFloor(float h) 
    {
    fill(yellow); 
    pushMatrix(); 
      translate(0,0,h-1.5); 
      float d=100;
      int n=20;
      pushMatrix();
        translate(0,-d*n/2,0);
          for(int j=0; j<n; j++)
            {
            pushMatrix();
              translate(-d*n/2,0,0);
              for(int i=0; i<n; i++)
                {
                fill(cyan); box(d,d,1);  pushMatrix(); translate(d,d,0);  box(d,d,1); popMatrix();
                fill(pink); pushMatrix(); translate(d,0,0); box(d,d,1); translate(-d,d,0); box(d,d,1); popMatrix();
                translate(2*d,0,0);
                }
            popMatrix();
            translate(0,2*d,0);
            }
      popMatrix(); // draws floor as thin plate
    popMatrix(); // draws floor as thin plate
    }
  