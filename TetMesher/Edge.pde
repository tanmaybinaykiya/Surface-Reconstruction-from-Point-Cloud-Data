import java.util.Objects;

public class Edge {
  /* 
   * Keeps track of an edge between two vertex IDs.
   * A positive ID is on the floor, and negative on the ceiling.
   * IDs begin at 1 (or -1).
   */
   
  public int first, second;
  
  public Edge(int vertex1, int vertex2) {
    // Canonical representation of edge is sorted IDs.
    this.first = min(vertex1, vertex2);
    this.second = max(vertex1, vertex2);
  }
  
  public Point getFirstPoint(Points floor, Points ceil) {
    return (this.first > 0) ? floor.G.get(this.first - 1) : ceil.G.get(-1*this.first - 1);
  }
  
  public Point getSecondPoint(Points floor, Points ceil) {
    return (this.second > 0) ? floor.G.get(this.second - 1) : ceil.G.get(-1*this.second - 1);
  }
  
  public boolean equals(Edge other) {
    return this.first == other.first && this.second == other.second;
  }
  
  public int hashCode() {
    return Objects.hash(this.first, this.second);
  }
}
Edge edgeFloorFloor(int v1, int v2) { return new Edge(v1 + 1, v2 + 1); }
Edge edgeCeilingCeiling(int v1, int v2) { return new Edge(-(v1 + 1), -(v2 + 1)); }
Edge edgeFloorCeiling(int v1, int v2) { return new Edge(v1 + 1, -(v2 + 1)); }
Edge edgeCeilingFloor(int v1, int v2) { return new Edge(-(v1 + 1), v2 + 1); }