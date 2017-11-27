class Triangle{
  int aIndex, bIndex, cIndex;
  Triangle(int aIndex, int bIndex, int cIndex){
    this.aIndex = aIndex;
    this.cIndex = bIndex;
    this.bIndex = cIndex;
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
      
      int minIndex = min(this.aIndex, this.bIndex, this.cIndex);
      int maxIndex = max(this.aIndex, this.bIndex, this.cIndex);
      int midIndex = this.aIndex + this.bIndex + this.cIndex - minIndex - maxIndex;
      
      int otherMinIndex = min(othern.aIndex, othern.bIndex, othern.cIndex);
      int otherMaxIndex = max(othern.aIndex, othern.bIndex, othern.cIndex);
      int otherMidIndex = othern.aIndex + othern.bIndex + othern.cIndex - minIndex - maxIndex;
      
      return minIndex == otherMinIndex && maxIndex == otherMaxIndex && midIndex == otherMidIndex;
    } else {
      return false;
    }
  }
  
  void drawMe(boolean smooth){
    beginShape();
    if (smooth) { normal(pointNormals[aIndex]); } v(pointCloud.get(aIndex));
    if (smooth) { normal(pointNormals[bIndex]); } v(pointCloud.get(bIndex));
    if (smooth) { normal(pointNormals[cIndex]); } v(pointCloud.get(cIndex));
    endShape(CLOSE);
  }
  
  String toString(){
    return " [ " +aIndex+ ","+bIndex+ ","+cIndex+ "]";
  }
  
}