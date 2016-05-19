#ifndef RASTER_H
#define RASTER_H

#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
using namespace std;

#define PI 3.14159265
#define Z_INF 1000.f

// Add any data members or member functions as you like...

class Model {
public:
	Model(): _num_vertices(0), _vertices(0), _isColored(false), _num_colors(0), _colors(0), _num_triangles(0), _triangles(0), _frameBuffer(0), _filename("") {}
	~Model() {
		delete [] _vertices;
		if(_isColored) {
			delete [] _colors;
		}
		delete [] _triangles;
		delete [] _frameBuffer;
	}

	bool load(const char* filename);
	void normalize();
	void rotateX(const float theta);
	void rotateY(const float theta);
	void rotateZ(const float theta);
	void translate(const float tx, const float ty, const float tz);
	void rendercolor();
	void rasterizeOff(int width, int height);		// Point cloud mode
	void rasterizeWireframe(int width, int height);	// Wireframe mode
	void rasterizeSolid(int width, int height);		// Solid mode
	void writePPM();

//private:
	int		_num_vertices;
	float*	_vertices;
	bool	_isColored;
	int		_num_colors;		// deprecated
	float*	_colors;
	int		_num_triangles;
	int*	_triangles;
	int		_frame_wid;
	int		_frame_hei;
	int		_current_mode;		// 0 = point cloud; 1 = wireframe; 2 = solid;
	unsigned char* _frameBuffer;
	string	_filename;
};

#endif