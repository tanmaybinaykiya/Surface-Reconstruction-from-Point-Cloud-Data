> This is the project report compiled by Sajid Anwar and Tanmay Binaykiya as part of the course requirements of [CS 6491 Computer Graphics](https://www.cc.gatech.edu/~jarek/6491/) under [Prof. Jaroslav Rossignac](https://www.cc.gatech.edu/~jarek/)

# Abstract

The project aims to compute a tetrahedronalization from balls on a floor and on a ceiling, to create a mesh that is comprised of cylinders and spheres corresponding to the edges and vertices of the tetrahedra, and finally computing a water tight approximation of the boundary of those cylinders and spheres given a point cloud. The tetrahedronalization is computed using Delaunay triangulation extended to three dimensions. We generate the mesh we want to approximate by creating spheres at the vertices and cylinders at the edges of all of the tetrahedra that were computed. Points are sampled on all of the spheres and cylinders to obtain the point cloud, and finally ball pivoting is used to reconstruct the surface of our mesh using the point cloud.

<center><iframe width="1280" height="720" src="https://www.youtube.com/embed/bC1mUjPqBsM?rel=0" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe></center>


Detailed Report can be found on the [project page](https://tanmaybinaykiya.github.io/tetrahedralization-of-3d-meshes)

