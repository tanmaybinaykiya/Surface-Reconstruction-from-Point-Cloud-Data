class Triangle{
  int aIndex, bIndex, cIndex;
  Triangle(int aIndex, int bIndex, int cIndex){
    this.aIndex = min(aIndex, bIndex, cIndex);
    this.cIndex = max(aIndex, bIndex, cIndex);
    this.bIndex = aIndex + bIndex + cIndex - this.aIndex - this.cIndex;
  }
  
  int hashCode(){
    return Objects.hash(aIndex, bIndex, cIndex);
  }
  
  void drawMe(){
    beginShape();
    v(pointCloud.get(aIndex));
    v(pointCloud.get(bIndex));
    v(pointCloud.get(cIndex));
    endShape(CLOSE);
  }
  
}