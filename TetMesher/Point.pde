import java.util.Objects;

class Point 
 { 
   float x=0,y=0,z=0; 
   Point () {}; 
   Point (float px, float py) {x = px; y = py;};
   Point (float px, float py, float pz) {x = px; y = py; z = pz; };
   Point set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   Point set (Point P) {x = P.x; y = P.y; z = P.z; return this;}; 
   Point setTo(Point P) {x = P.x; y = P.y; z = P.z; return this;}; 
   Point setTo(float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   Point add(Point P) {x+=P.x; y+=P.y; z+=P.z; return this;};
   Point add(Vector V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   Point sub(Vector V) {x-=V.x; y-=V.y; z-=V.z; return this;};
   Point add(float s, Vector V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   Point sub(Point P) {x-=P.x; y-=P.y; z-=P.z; return this;};
   Point mul(float f) {x*=f; y*=f; z*=f; return this;};
   Point div(float f) {x/=f; y/=f; z/=f; return this;};
   Point div(int f) {x/=f; y/=f; z/=f; return this;};
   
   public int hashCode() {
     return Objects.hash(this.x, this.y, this.z);
   }
   
   public String toString(){
     return "P["+ x + ", " + y+ ", "+z+"]";
   }
 }
   