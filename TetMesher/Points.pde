import java.util.*;

class Points // class for manipulaitng and displaying pointclouds or polyloops in 3D 
  { 
    int maxnv = 16000;                 //  max number of vertices
    List<Point> G = new ArrayList<Point>();           // geometry table (vertices)
    Point[] G2 = new Point [maxnv];           // geometry table (vertices)
    char[] L = new char [maxnv];             // labels of points
    Vector [] LL = new Vector[ maxnv];  // displacement vectors
    Boolean loop=true;          // used to indicate closed loop 3D control polygons
    int pv =0,     // picked vertex index,
        iv=0,      //  insertion vertex index
        dv = 0,   // dancer support foot index
        nv = 0,    // number of vertices currently used in P
        pp=1; // index of picked vertex

  Points() {}
  Points declare() 
    {
    for (int i=0; i<maxnv; i++) G.add(P()); 
    for (int i=0; i<maxnv; i++) LL[i]=V(); 
    return this;
    }     // init all point objects
  Points empty() {nv=0; pv=0; return this;}                                 // resets P so that we can start adding points
  Points addPt(Point P, char c) { G.get(nv).setTo(P); pv=nv; L[nv]=c; nv++;  return this;}          // appends a new point at the end
  Points addPt(Point P) { G.get(nv).setTo(P); pv=nv; L[nv]='f'; nv++;  return this;}          // appends a new point at the end
  Points addPt(float x,float y) { G.get(nv).x=x; G.get(nv).y=y; pv=nv; nv++; return this;} // same byt from coordinates
  Points copyFrom(Points Q) {empty(); nv=Q.nv; for (int v=0; v<nv; v++) G.add(P(Q.G.get(v))); return this;} // set THIS as a clone of Q

  Points perturb(float e) { for (int i=1; i<nv; i++) {G.get(i).x+=random(-e,e); G.get(i).y+=random(-e,e);} return this;}
  
  Points resetOnCircle(int k, float r)  // sets THIS to a polyloop with k points on a circle of radius r around origin
    {
    empty(); // resert P
    Point C = P(); // center of circle
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-r,0)),2.*PI*i/k,C)); // points on z=0 plane
    pv=0; // picked vertex ID is set to 0
    return this;
    } 
  // ********* PICK AND PROJECTIONS *******  
  int SETppToIDofVertexWithClosestScreenProjectionTo(Point M)  // sets pp to the index of the vertex that projects closest to the mouse 
    {
    pp=0; 
    for (int i=1; i<nv; i++) if (d(M,ToScreen(G.get(i)))<=d(M,ToScreen(G.get(pp)))) pp=i; 
    return pp;
    }
    
  //pts showPicked() {show(G.get(pv)); return this;}
  Point closestProjectionOf(Point M)    // Returns 3D point that is the closest to the projection but also CHANGES iv !!!!
    {
    Point C = P(G.get(0)); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G.get(i))<=d) {iv=i; C=P(G.get(i)); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) { 
       Point A = G.get(i), B = G.get(j);
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); iv=i; C=projectionOnLine(M,A,B);}
       } 
    return C;    
    }

  // ********* MOVE, INSERT, DELETE *******  
  Points insertPt(Point P) { // inserts new vertex after vertex with ID iv
    for(int v=nv-1; v>iv; v--) {G.get(v+1).setTo(G.get(v));  L[v+1]=L[v];}
     iv++; 
     G.get(iv).setTo(P);
     L[iv]='f';
     nv++; // increments vertex count
     return this;
     }
  Points insertClosestProjection(Point M) {  
    Point P = closestProjectionOf(M); // also sets iv
    insertPt(P);
    return this;
    }
  Points deletePicked() 
    {
      if (nv == 0)
        return this;
        
    for(int i=pv; i<nv; i++) 
      {
      G.get(i).setTo(G.get(i+1)); 
      L[i]=L[i+1]; 
      }
    pv=max(0,pv-1); 
    nv--;  
    return this;
    }
  Points setPt(Point P, int i) { G.get(i).setTo(P); return this;}
  Points setZ(float z) {for (int v=0; v<nv; v++)  G.get(v).z=z; return this;}
  
  Points drawBalls(float r) {for (int v=0; v<nv; v++) show(G.get(v),r); return this;}
  Points showPicked(float r) {show(G.get(pv),r); return this;}
  Points drawClosedCurve(float r) 
    {
    fill(dgreen);
    for (int v=0; v<nv; v++) show(G.get(v),r*3);    
    fill(magenta);
    for (int v=0; v<nv-1; v++) stub(G.get(v),V(G.get(v),G.get(v+1)),r,r);  
    stub(G.get(nv-1),V(G.get(nv-1),G.get(0)),r,r);
    pushMatrix(); //translate(0,0,1); 
    scale(1,1,0.03);  
    fill(grey);
    for (int v=0; v<nv; v++) show(G.get(v),r*3);    
    for (int v=0; v<nv-1; v++) stub(G.get(v),V(G.get(v),G.get(v+1)),r,r);  
    stub(G.get(nv-1),V(G.get(nv-1),G.get(0)),r,r);
    popMatrix();
    return this;
    }
  Points set_pv_to_pp() {pv=pp; return this;}
  Points movePicked(Vector V) { G.get(pv).add(V); return this;}      // moves selected point (index p) by amount mouse moved recently
  Points setPickedTo(Point Q) { G.get(pv).setTo(Q); return this;}      // moves selected point (index p) by amount mouse moved recently
  Points moveAll(Vector V) {for (int i=0; i<nv; i++) G.get(i).add(V); return this;};   
  Point Picked() {return G.get(pv);} 
  Point Pt(int i) {if(0<=i && i<nv) return G.get(i); else return G.get(0);} 

  // ********* I/O FILE *******  
 void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G.get(i).x)+","+str(G.get(i).y)+","+str(G.get(i).z)+","+L[i];}
    saveStrings(fn,inppts);
    };
  
  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) 
      {
      int i=k+s; 
      //float [] xy = float(split(ss[i],",")); 
      String [] SS = split(ss[i],","); 
      G.get(k).setTo(float(SS[0]),float(SS[1]),float(SS[2]));
      L[k]=SS[3].charAt(0);
      }
    pv=0;
    };
 
  // Dancer
  void setPicekdLabel(char c) {L[pp]=c;}
  


  void setFifo() 
    {
    _LookAtPt.reset(G.get(dv),60);
    }              


  void next() {dv=n(dv);}
  int n(int v) {return (v+1)%nv;}
  int p(int v) {if(v==0) return nv-1; else return v-1;}
  
  Points subdivideDemoInto(Points Q) 
    {
    Q.empty();
    for(int i=0; i<nv; i++)
      {
      Q.addPt(P(G.get(i))); 
      Q.addPt(P(G.get(i),G.get(n(i)))); 
      //...
      }
    return this;
    }  
  
  void displaySkater() 
      {
      if(showCurve) {fill(yellow); for (int j=0; j<nv; j++) caplet(G.get(j),6,G.get(n(j)),6); }
      Point[] B = new Point [nv];           // geometry table (vertices)
      for (int j=0; j<nv; j++) B[j]=P(G.get(j),V(0,0,100));
      if(showPath) {fill(lime); for (int j=0; j<nv; j++) caplet(B[j],6,B[n(j)],6);} 
      if(showKeys) {fill(cyan); for (int j=0; j<nv; j+=4) arrow(B[j],G.get(j),3);}
      
      if(animating) f=n(f);
      if(showSkater) 
        {
        // ....
        }
      else {fill(red); arrow(B[f],G.get(f),20);} //
      }

        

} // end of pts class