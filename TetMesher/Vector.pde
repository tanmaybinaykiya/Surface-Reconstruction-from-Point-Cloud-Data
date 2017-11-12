class Vector { 
   float x=0,y=0,z=0; 
   // creation    
   Vector () {}; 
   Vector (float px, float py, float pz) {x = px; y = py; z = pz;};
   Vector (float px, float py) {x = px; y = py;};
   Vector set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   Vector setTo(Vector V) {x = V.x; y = V.y; z = V.z; return this;}; 
   Vector set (Vector V) {x = V.x; y = V.y; z = V.z; return this;}; 

   // measure
   float norm() {return(sqrt(sq(x)+sq(y)+sq(z)));}; 

   //alteration
   Vector add(Vector V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   Vector add(float s, Vector V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   Vector sub(Vector V) {x-=V.x; y-=V.y; z-=V.z; return this;};
   Vector mul(float f) {x*=f; y*=f; z*=f; return this;};
   Vector div(float f) {x/=f; y/=f; z/=f; return this;};
   Vector div(int f) {x/=f; y/=f; z/=f; return this;};
   Vector rev() {x=-x; y=-y; z=-z; return this;}; 
   Vector normalize() {float n=norm(); if (n>0.000001) {div(n);}; return this;};
   Vector rotate(float a, Vector I, Vector J)  // Rotate this by angle a parallel in plane (I,J) Assumes I and J are orthogonal
     {
     float x=d(this,I), y=d(this,J); // dot products
     float c=cos(a), s=sin(a); 
     add(x*c-x-y*s,I); add(x*s+y*c-y,J); 
     return this; 
     } 
   } // end class vec
  