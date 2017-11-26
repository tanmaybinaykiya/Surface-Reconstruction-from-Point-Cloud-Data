class Triangle{
  int aIndex, bIndex, cIndex;
  Triangle(int aIndex, int bIndex, int cIndex){
    this.aIndex = min(aIndex, bIndex, cIndex);
    this.cIndex = max(aIndex, bIndex, cIndex);
    this.bIndex = aIndex + bIndex + cIndex - this.aIndex - this.cIndex;
  }
  
  int hashCode(){
    int hashCode  = Objects.hash(aIndex, bIndex, cIndex);
    //println("hashcode method called", hashCode);
    return hashCode;
  }
  
  boolean equals(Object other){
    //println("Equals method callsed");
    if(other instanceof Triangle){
      Triangle othern = (Triangle) other;
      return this.aIndex == othern.aIndex && this.bIndex == othern.bIndex && this.cIndex == othern.cIndex;
    } else {
      return false;
    }
  }
  
  void drawMe(){
    beginShape();
    v(pointCloud.get(aIndex));
    v(pointCloud.get(bIndex));
    v(pointCloud.get(cIndex));
    endShape(CLOSE);
  }
  
  String toString(){
    return " [ " +aIndex+ ","+bIndex+ ","+cIndex+ "]";
  }
  
}