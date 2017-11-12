// points, vectors, frames in 3D

// =====  vector functions
Vector V() {return new Vector(); };                                                                          // make vector (x,y,z)
Vector V(float x, float y, float z) {return new Vector(x,y,z); };                                            // make vector (x,y,z)
Vector V(Vector V) {return new Vector(V.x,V.y,V.z); };                                                          // make copy of vector V
Vector A(Vector A, Vector B) {return new Vector(A.x+B.x,A.y+B.y,A.z+B.z); };                                       // A+B
Vector A(Vector U, float s, Vector V) {return V(U.x+s*V.x,U.y+s*V.y,U.z+s*V.z);};                               // U+sV
Vector M(Vector U, Vector V) {return V(U.x-V.x,U.y-V.y,U.z-V.z);};                                              // U-V
Vector M(Vector V) {return V(-V.x,-V.y,-V.z);};                                                              // -V
Vector V(Vector A, Vector B) {return new Vector((A.x+B.x)/2.0,(A.y+B.y)/2.0,(A.z+B.z)/2.0); }                      // (A+B)/2
Vector V(Vector A, float s, Vector B) {return new Vector(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };      // (1-s)A+sB
Vector V(Vector A, Vector B, Vector C) {return new Vector((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0,(A.z+B.z+C.z)/3.0); };  // (A+B+C)/3
Vector V(Vector A, Vector B, Vector C, Vector D) {return V(V(A,B),V(C,D)); };                                         // (A+B+C+D)/4
Vector V(float s, Vector A) {return new Vector(s*A.x,s*A.y,s*A.z); };                                           // sA
Vector S(Vector U, float s, Vector V) {return V(U.x+s*V.x,U.y+s*V.y,U.z+s*V.z);};                  // U+sV
Vector V(float a, Vector A, float b, Vector B) {return A(V(a,A),V(b,B));}                                       // aA+bB 
Vector V(float a, Vector A, float b, Vector B, float c, Vector C) {return A(V(a,A,b,B),V(c,C));}                   // aA+bB+cC
Vector V(Point P, Point Q) {return new Vector(Q.x-P.x,Q.y-P.y,Q.z-P.z);};                                          // PQ
Vector U(Vector V) {float n = V.norm(); if (n<0.0000001) return V(0,0,0); else return V(1./n,V);};           // V/||V||
Vector U(Point P, Point Q) {return U(V(P,Q));};                                                                 // PQ/||PQ||
Vector U(float x, float y, float z) {return U(V(x,y,z)); };                                               // make vector (x,y,z)
Vector N(Vector U, Vector V) {return V( U.y*V.z-U.z*V.y, U.z*V.x-U.x*V.z, U.x*V.y-U.y*V.x); };                  // UxV cross product (normal to both)
Vector cross(Vector U, Vector V) {return V( U.y*V.z-U.z*V.y, U.z*V.x-U.x*V.z, U.x*V.y-U.y*V.x); };                  // UxV cross product (normal to both)
Vector N(Point A, Point B, Point C) {return N(V(A,B),V(A,C)); };                                                   // normal to triangle (A,B,C), not normalized (proportional to area)
Vector B(Vector U, Vector V) {return U(N(N(U,V),U)); }                                                          // normal to U in plane (U,V)
Vector Normal(Vector V) {                                                                                    // vector orthogonal to V
  if(abs(V.z)<=min(abs(V.x),abs(V.y))) return V(-V.y,V.x,0); 
  if(abs(V.x)<=min(abs(V.z),abs(V.y))) return V(0,-V.z,V.y);
  return V(V.z,0,-V.x);
  }
float mixed(Vector U, Vector V, Vector W) {return dot(U,cross(V,W));}

// ===== point functions
Point P() {return new Point(); };                                                                          // point (x,y,z)
Point P(float x, float y, float z) {return new Point(x,y,z); };                                            // point (x,y,z)
Point P(float x, float y) {return new Point(x,y); };                                                       // make point (x,y)
Point P(Point A) {return new Point(A.x,A.y,A.z); };                                                           // copy of point P
Point P(Point A, float s, Point B) {return new Point(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };        // A+sAB
Point L(Point A, float s, Point B) {return new Point(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };        // A+sAB
Point P(Point A, Point B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0,(A.z+B.z)/2.0); }                             // (A+B)/2
Point P(Point A, Point B, Point C) {return new Point((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0,(A.z+B.z+C.z)/3.0); };     // (A+B+C)/3
Point P(Point A, Point B, Point C, Point D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4
Point P(float s, Point A) {return new Point(s*A.x,s*A.y,s*A.z); };                                            // sA
Point A(Point A, Point B) {return new Point(A.x+B.x,A.y+B.y,A.z+B.z); };                                         // A+B
Point P(float a, Point A, float b, Point B) {return A(P(a,A),P(b,B));}                                        // aA+bB 
Point P(float a, Point A, float b, Point B, float c, Point C) {return A(P(a,A),P(b,B,c,C));}                     // aA+bB+cC 
Point P(float a, Point A, float b, Point B, float c, Point C, float d, Point D){return A(P(a,A,b,B),P(c,C,d,D));}   // aA+bB+cC+dD
Point P(Point P, Vector V) {return new Point(P.x + V.x, P.y + V.y, P.z + V.z); }                                 // P+V
Point P(Point P, float s, Vector V) {return new Point(P.x+s*V.x,P.y+s*V.y,P.z+s*V.z);}                           // P+sV
Point P(Point O, float x, Vector I, float y, Vector J) {return P(O.x+x*I.x+y*J.x,O.y+x*I.y+y*J.y,O.z+x*I.z+y*J.z);}  // O+xI+yJ
Point P(Point O, float x, Vector I, float y, Vector J, float z, Vector K) {return P(O.x+x*I.x+y*J.x+z*K.x,O.y+x*I.y+y*J.y+z*K.y,O.z+x*I.z+y*J.z+z*K.z);}  // O+xI+yJ+kZ
void makePts(Point[] C) {for(int i=0; i<C.length; i++) C[i]=P();}
Point Bezier(Point A, Point B, Point C, float t) {return L(L(A,t,B),t,L(B,t,C));}

// ===== mouse
Point Mouse() {return P(mouseX,mouseY,0);};                                          // current mouse location
Point Pmouse() {return P(pmouseX,pmouseY,0);};
Vector MouseDrag() {return V(mouseX-pmouseX,mouseY-pmouseY,0);};                     // vector representing recent mouse displacement
Point ScreenCenter() {return P(width/2,height/2);}                                                        //  point in center of  canvas

// ===== measures
float d(Vector U, Vector V) {return U.x*V.x+U.y*V.y+U.z*V.z; };                                            //U*V dot product
float dot(Vector U, Vector V) {return U.x*V.x+U.y*V.y+U.z*V.z; };                                          //U*V dot product
float det2(Vector U, Vector V) {return -U.y*V.x+U.x*V.y; };                                                // U:V det product of (x,y) components
float det3(Vector U, Vector V) {return sqrt(d(U,U)*d(V,V) - sq(d(U,V))); };                                // U:V det product (norm of UxV)
float m(Vector U, Vector V, Vector W) {return d(U,N(V,W)); };                                                 // U*(VxW)  mixed product, determinant
float m(Point E, Point A, Point B, Point C) {return m(V(E,A),V(E,B),V(E,C));}                                    // det (EA EB EC) is >0 when E sees (A,B,C) clockwise
float n2(Vector V) {return sq(V.x)+sq(V.y)+sq(V.z);};                                                   // V*V    norm squared
float n(Vector V) {return sqrt(n2(V));};                                                                // ||V||  norm
float norm(Vector V) {return sqrt(n2(V));};                                                                // ||V||  norm
float d(Point P, Point Q) {return sqrt(sq(Q.x-P.x)+sq(Q.y-P.y)+sq(Q.z-P.z)); };                            // ||AB|| distance
float area(Point A, Point B, Point C) {return n(N(A,B,C))/2; };                                               // (positive) area of triangle in 3D
float volume(Point A, Point B, Point C, Point D) {return m(V(A,B),V(A,C),V(A,D))/6; };                           // (signed) volume of tetrahedron
boolean parallel (Vector U, Vector V) {return n(N(U,V))<n(U)*n(V)*0.00001; }                               // true if U and V are almost parallel
float angle(Vector U, Vector V) {return acos(d(U,V)/n(V)/n(U)); };                                         // angle(U,V) positive  (in 0,PI)
boolean cw(Vector U, Vector V, Vector W) {return m(U,V,W)>0; };                                               // U*(VxW)>0  U,V,W are clockwise in 3D
boolean cw(Point A, Point B, Point C, Point D) {return volume(A,B,C,D)>0; };                                     // tet is oriented so that A sees B, C, D clockwise 
boolean projectsBetween(Point P, Point A, Point B) {return dot(V(A,P),V(A,B))>0 && dot(V(B,P),V(B,A))>0 ; };
float disToLine(Point P, Point A, Point B) {return det3(U(A,B),V(A,P)); };
Point projectionOnLine(Point P, Point A, Point B) {return P(A,dot(V(A,B),V(A,P))/dot(V(A,B),V(A,B)),V(A,B));}

// ===== rotations 
Vector R(Vector V) {return V(-V.y,V.x,V.z);} // rotated 90 degrees in XY plane
Point R(Point P, float a, Vector I, Vector J, Point G) {float x=d(V(G,P),I), y=d(V(G,P),J); float c=cos(a), s=sin(a); return P(P,x*c-x-y*s,I,x*s+y*c-y,J); }; // Rotated P by a around G in plane (I,J)
Vector R(Vector V, float a, Vector I, Vector J) {float x=d(V,I), y=d(V,J); float c=cos(a), s=sin(a); return A(V,V(x*c-x-y*s,I,x*s+y*c-y,J)); }; // Rotated V by a parallel to plane (I,J)
Point R(Point Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return P(c*dx+s*dy,-s*dx+c*dy,Q.z); };  // Q rotated by angle a around the origin
Point R(Point Q, float a, Point C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P(C.x+c*dx-s*dy, C.y+s*dx+c*dy, Q.z); };  // Q rotated by angle a around point P
Point R(Point Q, Point C, Point P, Point R)  // returns rotated version of Q by angle(CP,CR) parallel to plane (C,P,R)
   {
   Vector I0=U(C,P), I1=U(C,R), V=V(C,Q); 
   float c=d(I0,I1), s=sqrt(1.-sq(c)); 
                                       if(abs(s)<0.00001) return Q; // singular cAW
   Vector J0=V(1./s,I1,-c/s,I0);  
   Vector J1=V(-s,I0,c,J0);  
   float x=d(V,I0), y=d(V,J0);
   return P(Q,x,M(I1,I0),y,M(J1,J0)); 
   } 

// ===== rending functions
void normal(Vector V) {normal(V.x,V.y,V.z);};                                     // changes current normal vector for subsequent smooth shading
void vertex(Point P) {vertex(P.x,P.y,P.z);};                                      // vertex for shading or drawing
void v(Point P) {vertex(P.x,P.y,P.z);};                                           // vertex for shading or drawing (between BeginShape() ; and endShape();)
void vTextured(Point P, float u, float v) {vertex(P.x,P.y,P.z,u,v);};                          // vertex with texture coordinates
void show(Point P, Point Q) {line(Q.x,Q.y,Q.z,P.x,P.y,P.z); };                       // render edge (P,Q)
void show(Point P, Vector V) {line(P.x,P.y,P.z,P.x+V.x,P.y+V.y,P.z+V.z); };          // render edge from P to P+V
void show(Point P, float d , Vector V) {line(P.x,P.y,P.z,P.x+d*V.x,P.y+d*V.y,P.z+d*V.z); }; // render edge from P to P+dV
void show(Point A, Point B, Point C) {beginShape(); vertex(A);vertex(B); vertex(C); endShape(CLOSE);};                      // render Triangle(A,B,C)
void show(Point A, Point B, Point C, Point D) {beginShape(); vertex(A); vertex(B); vertex(C); vertex(D); endShape(CLOSE);};    // render Quad(A,B,C,D)
void show(Point P, float s, Vector I, Vector J, Vector K) {noStroke(); fill(yellow); show(P,5); stroke(red); show(P,s,I); stroke(green); show(P,s,J); stroke(blue); show(P,s,K); }; // render coordinate system
void show(Point P, String s) {text(s, P.x, P.y, P.z); }; // prints string s in 3D at P
void show(Point P, String s, Vector D) {text(s, P.x+D.x, P.y+D.y, P.z+D.z);  }; // prints string s in 3D at P+D (offset vector)
void show(Point P, float r) {pushMatrix(); translate(P.x,P.y,P.z); sphere(r); popMatrix();};                          // render sphere of radius r and center P
void showShadow(Point P, float r) {pushMatrix(); translate(P.x,P.y,0); scale(1,1,0.01); sphere(r); popMatrix();}      // render shadow on the floot of sphere of radius r and center P

//===== SUBDIVISION
Point B(Point A, Point B, Point C, float s) {return( P(P(B,s/4.,A),0.5,P(B,s/4.,C))); };                          // returns a tucked B towards its neighbors
Point F(Point A, Point B, Point C, Point D, float s) {return( P(P(A,1.+(1.-s)/8.,B) ,0.5, P(D,1.+(1.-s)/8.,C))); };    // returns a bulged mid-edge point 