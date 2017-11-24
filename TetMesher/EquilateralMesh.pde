class EquilateralMesh {
  List<List<Point>> layers;
  
  public EquilateralMesh(List<List<Point>> layers) {
    this.layers = layers; 
  }
  
  public List<Point> getAllPoints() {
    List<Point> all = new ArrayList();
    
    for (List<Point> layer : this.layers) {
      all.addAll(layer);
    }
    
    return all;
  }
  
  public void draw() {
    for (int i = 0; i < layers.size(); i++) {
      beginShape(TRIANGLE_STRIP);
      
      List<Point> curLayer = layers.get(i);
      List<Point> nextLayer = (i+1 < layers.size()) ? layers.get(i+1) : null;
      
      for (int j = 0; j < curLayer.size(); j++) {
        
        
        if (nextLayer != null && nextLayer.size() > j) {
          v(curLayer.get(j));
          v(nextLayer.get(j));
        }
      }
      
      endShape(CLOSE);
    }
  }
}