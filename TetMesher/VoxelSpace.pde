public class VoxelCoordinate {
  public int x;
  public int y;
  public int z;
  
  public VoxelCoordinate(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public int hashCode(){
    return Objects.hash(x, y, z);
  }
  
  public boolean equals(Object other){
    if(other instanceof VoxelCoordinate){
      VoxelCoordinate othern = (VoxelCoordinate) other;
      return this.x == othern.x && this.y == othern.y && this.z == othern.z;
    } 
    else {
      return false;
    }
  }
  
  public String toString() {
    return "(" + x + ", " + y + ", " + z + ")";
  }
}

public class VoxelSpace {
  List<Point> points;
  float cellSize;
  
  // Maps solve everything
  Map<VoxelCoordinate, List<Integer>> voxels;
  
  public VoxelSpace(List<Point> points, float cellSize) {
    this.points = points;
    this.cellSize = cellSize;
    this.voxels = new HashMap();
    
    for (int pIndex = 0; pIndex < points.size(); pIndex++) {
      // Find the voxel coordinate, add it to the map
      VoxelCoordinate coord = this.getCoordinate(pIndex);
      List<Integer> bucket;
      
      if (!this.voxels.containsKey(coord)) {
        bucket = new LinkedList();
        this.voxels.put(coord, bucket);
      }
      else {
        bucket = this.voxels.get(coord);
      }
      
      bucket.add(pIndex);
    }
  }
  
  public VoxelCoordinate getCoordinate(int pIndex) {
    Point P = this.points.get(pIndex);
    return this.getCoordinate(P);
  }
  
  public VoxelCoordinate getCoordinate(Point P) {
    return new VoxelCoordinate(int(P.x / this.cellSize), int(P.y / this.cellSize), int(P.z / this.cellSize));
  }
  
  public List<Integer> getNeighboringPoints(int pIndex) {
    // Returns all of the points in all of the 27 neighboring voxel coordinates
    List<Integer> pointsIndices = new LinkedList();
    VoxelCoordinate coord = this.getCoordinate(pIndex);

    for (int vx = coord.x - 1; vx <= coord.x + 1; vx++) {
      for (int vy = coord.y - 1; vy <= coord.y + 1; vy++) {
        for (int vz = coord.z - 1; vz <= coord.z + 1; vz++) {
          List<Integer> bucket = this.voxels.get(new VoxelCoordinate(vx, vy, vz));
          
          if (bucket != null) {
            pointsIndices.addAll(bucket);
          }
        }
      }
    }
    
    return pointsIndices;
  }
}