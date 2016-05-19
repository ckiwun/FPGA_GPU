#include "rasterization.h"

bool Model::load(const char* filename) {
	_filename.assign(filename);
	ifstream ifs(filename, ios::in);
	if(!ifs) {
		cerr << "Error: can't load model: \"" << filename << "\"." << endl;
		return false;
	}
	cout << "Info: Loading model \"" << filename << "\"..." << endl;
	string str;
	int array_size, i;
	while(!ifs.eof()) {
		str.clear();
		ifs >> str;
		if(!str.compare("Vertices")) {
			ifs >> _num_vertices;
			array_size = _num_vertices*3;
			_vertices = new float[array_size];
			_colors = new float[array_size];
			for(i = 0; i < array_size; ++i) {
				ifs >> _vertices[i];
			}
			cout << "Info: " << _num_vertices << " vertices loaded." << endl;
		}
		else if(!str.compare("Colors")) {
			ifs >> _num_colors;
			_isColored = true;
			for(i = 0; i < array_size; ++i) {
				ifs >> _colors[i];
			}
			cout << "Info: Color information loaded." << endl;
		}
		else if(!str.compare("Triangle_list")) {
			ifs >> _num_triangles;
			array_size = _num_triangles*3;
			_triangles = new int[array_size];
			for(i = 0; i < array_size; ++i) {
				ifs >> _triangles[i];
			}
			cout << "Info: " << _num_triangles << " triangles loaded." << endl;
		}
		else {
			if(str.size())
				cout << "Warning: Can't recognize this token \"" << str << "\"." << endl;
		}
	}
	ifs.close();
	return true;
}

void Model::normalize() {
	// find the boundary of the model
	float x_min, x_max, y_min, y_max, z_min, z_max, x, y, z, scale_factor, offset_x, offset_y, offset_z, tmp;
	x_min = x_max = _vertices[0];
	y_min = y_max = _vertices[1];
	z_min = z_max = _vertices[2];
	for(int i = 1; i < _num_vertices; ++i) {
		x = _vertices[3*i];
		y = _vertices[3*i+1];
		z = _vertices[3*i+2];
		if(x < x_min) {
			x_min = x;
		}
		else if(x > x_max) {
			x_max = x;
		}
		if(y < y_min) {
			y_min = y;
		}
		else if(y > y_max) {
			y_max = y;
		}
		if(z < z_min) {
			z_min = z;
		}
		else if(z > z_max) {
			z_max = z;
		}
	}
	// normalize along the longest axis, so that the aspect ratio can be preserved.
	scale_factor = x_max - x_min;
	tmp = y_max - y_min;
	if(tmp > scale_factor) {
		scale_factor = tmp;
	}
	scale_factor *= 1.2f;
	offset_x = (scale_factor - (x_max - x_min))/2.f;
	offset_y = (scale_factor - (y_max - y_min))/2.f;
	offset_z = (scale_factor - (z_max - z_min))/2.f;
	cout << "offset = (" << -x_min+offset_x << "," << -y_min+offset_y << "," << -z_min+offset_z<< ")" << endl;
	cout << "scale factor = " << scale_factor << endl;
	// normalize x, y coordinates to [0, 1]
	for(int i = 0; i < _num_vertices; ++i) {
		_vertices[3*i  ] = (_vertices[3*i  ]-x_min+offset_x)/scale_factor;
		_vertices[3*i+1] = (_vertices[3*i+1]-y_min+offset_y)/scale_factor;
		_vertices[3*i+2] = (_vertices[3*i+2]-z_min+offset_z)/scale_factor;
		//cout << "(x,y,z) = " << _vertices[3*i  ] << "," << _vertices[3*i+1] << ","  << _vertices[3*i+2] << endl;
	}
}

void Model::rotateX(const float theta) {
	float y_temp;
	for(int i = 0; i < _num_vertices; ++i){
		y_temp				= _vertices[3*i+1]*cosf(theta)-_vertices[3*i+2]*sinf(theta);
		_vertices[3*i+2]	= _vertices[3*i+1]*sinf(theta)+_vertices[3*i+2]*cosf(theta);
		_vertices[3*i+1]	= y_temp;
	}
}

void Model::rotateY(const float theta) {
	float x_temp;
	for(int i = 0; i < _num_vertices; ++i){
		x_temp				=  _vertices[3*i  ]*cosf(theta)+_vertices[3*i+2]*sinf(theta);
		_vertices[3*i+2]	= (-1)*_vertices[3*i  ]*sinf(theta)+_vertices[3*i+2]*cosf(theta);
		_vertices[3*i  ]	= x_temp;
	}
}

void Model::rotateZ(const float theta) {
	float x_temp;
	for(int i = 0; i < _num_vertices; ++i){
		x_temp				= _vertices[3*i  ]*cosf(theta)-_vertices[3*i+1]*sinf(theta);
		_vertices[3*i+1]	= _vertices[3*i  ]*sinf(theta)+_vertices[3*i+1]*cosf(theta);
		_vertices[3*i  ]	= x_temp;
	}
}

void Model::translate(const float tx, const float ty, const float tz) {
	for(int i = 0; i < _num_vertices; ++i){
		_vertices[3*i  ] += tx;
		_vertices[3*i+1] += ty;
		_vertices[3*i+2] += tz;
	}
}

void Model::rendercolor()	{	// Point cloud mode
	float z;

	// If no color assigned, render color by depth
	if(!_isColored) {
		float color_base_r = 1.0f;
		float color_base_g = 1.0f;
		float color_base_b = 1.0f;
		float z_min, z_max;
		float scale_factor;
		z_min = z_max = _vertices[2];
		for(int i = 5; i < 3*_num_vertices; i += 3) {
			z = _vertices[i];
			if(z < z_min) {
				z_min = z;
			}
			else if(z > z_max) {
				z_max = z;
			}
		}
		scale_factor = z_max - z_min;
		for(int i = 0; i < _num_vertices; ++i) {
			_colors[3*i  ] = color_base_r*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+1] = color_base_g*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+2] = color_base_b*(_vertices[3*i+2]-z_min)/scale_factor;
		}
	}
}

void Model::rasterizeOff(int width, int height)	{	// Point cloud mode
	_current_mode = 0;		// 0 = point cloud; 1 = wireframe; 2 = solid;
	_frame_wid = width;
	_frame_hei = height;
	float x, y, z;

	// Prepare a depth buffer
	int buffer_size = width*height;
	float* zBuffer = new float[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		zBuffer[i] = Z_INF;
	
	// Prepare a frame buffer
	buffer_size = width*height*3;
	_frameBuffer = new unsigned char[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		_frameBuffer[i] = 0;
	
	// If no color assigned, render color by depth
	if(!_isColored) {
		float color_base_r = 1.0f;
		float color_base_g = 1.0f;
		float color_base_b = 1.0f;
		float z_min, z_max;
		float scale_factor;
		z_min = z_max = _vertices[2];
		for(int i = 5; i < 3*_num_vertices; i += 3) {
			z = _vertices[i];
			if(z < z_min) {
				z_min = z;
			}
			else if(z > z_max) {
				z_max = z;
			}
		}
		scale_factor = z_max - z_min;
		for(int i = 0; i < _num_vertices; ++i) {
			_colors[3*i  ] = color_base_r*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+1] = color_base_g*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+2] = color_base_b*(_vertices[3*i+2]-z_min)/scale_factor;
		}
	}

	// Render
	int intX, intY, offset;
	for(int i = 0; i < _num_vertices; ++i) {
		x = _vertices[3*i  ];
		y = _vertices[3*i+1];
		z = _vertices[3*i+2];
		
		intX = int(x*float(width));
		intX = (intX < width)? intX : width-1;
		intY = int(y*float(height));
		intY = (intY < height)? intY : height-1;

		offset = intY*width + intX;
		// Z-test
		if(z < zBuffer[offset]) {
			zBuffer[offset] = z;
			cout<<"render a point"<<endl;
			_frameBuffer[3*offset  ] = (unsigned char)(255.f*_colors[3*i  ]);
			_frameBuffer[3*offset+1] = (unsigned char)(255.f*_colors[3*i+1]);
			_frameBuffer[3*offset+2] = (unsigned char)(255.f*_colors[3*i+2]);
		}
	}

}

void Model::rasterizeWireframe(int width, int height) {	// Wireframe mode
	_current_mode = 1;		// 0 = point cloud; 1 = wireframe; 2 = solid;
	_frame_wid = width;
	_frame_hei = height;
	float x, y, z;

	// Prepare a depth buffer
	int buffer_size = width*height;
	float* zBuffer = new float[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		zBuffer[i] = Z_INF;
	
	// Prepare a frame buffer
	buffer_size = width*height*3;
	_frameBuffer = new unsigned char[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		_frameBuffer[i] = 0;
	
	// If no color assigned, render color by depth
	if(!_isColored) {
		float color_base_r = 1.0f;
		float color_base_g = 1.0f;
		float color_base_b = 1.0f;
		float z_min, z_max;
		float scale_factor;
		z_min = z_max = _vertices[2];
		for(int i = 5; i < 3*_num_vertices; i += 3) {
			z = _vertices[i];
			if(z < z_min) {
				z_min = z;
			}
			else if(z > z_max) {
				z_max = z;
			}
		}
		scale_factor = z_max - z_min;
		for(int i = 0; i < _num_vertices; ++i) {
			_colors[3*i  ] = color_base_r*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+1] = color_base_g*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+2] = color_base_b*(_vertices[3*i+2]-z_min)/scale_factor;
			//cout << " R G B = " << _colors[3*i  ] << " " << _colors[3*i+1]<< " " << _colors[3*i+2] << endl;
		}
	}
	// Render
	bool is_X_major;
	int intX, intY, int_v0_x, int_v0_y, int_v1_x, int_v1_y, int_v2_x, int_v2_y, offset, v0, v1, v2;
	float v0_x, v0_y, v0_z, v1_x, v1_y, v1_z, v2_x, v2_y, v2_z, slope, dist, slope_depth, dist_depth;
	float v0_R, v0_G, v0_B, v1_R, v1_G, v1_B, v2_R, v2_G, v2_B, slope_R, dist_R, slope_G, dist_G, slope_B, dist_B, color_R, color_G, color_B;
	for(int i = 0; i < _num_triangles; ++i) {
		v0 = _triangles[3*i  ];
		v1 = _triangles[3*i+1];
		v2 = _triangles[3*i+2];
		
		v0_x = _vertices[3*v0  ];
		v0_y = _vertices[3*v0+1];
		v0_z = _vertices[3*v0+2];
		v1_x = _vertices[3*v1  ];
		v1_y = _vertices[3*v1+1];
		v1_z = _vertices[3*v1+2];
		v2_x = _vertices[3*v2  ];
		v2_y = _vertices[3*v2+1];
		v2_z = _vertices[3*v2+2];
		v0_R = _colors[3*v0  ];
		v0_G = _colors[3*v0+1];
		v0_B = _colors[3*v0+2];
		v1_R = _colors[3*v1  ];
		v1_G = _colors[3*v1+1];
		v1_B = _colors[3*v1+2];
		v2_R = _colors[3*v2  ];
		v2_G = _colors[3*v2+1];
		v2_B = _colors[3*v2+2];

		//cout << "v0.R G B = " << v0_R << " " << v0_G << " " << v0_B << endl;
		//cout << "v1.R G B = " << v1_R << " " << v1_G << " " << v1_B << endl;
		//cout << "v0.x = " << v0_x<< endl;
		//cout << "v1.x = " << v1_x<< endl;
		
		//========== v0 -> v1 ============//

		//cout<<" v0_x "<< v0_x <<endl;
		//cout<<" v0_y "<< v0_y <<endl;
		//cout<<" v1_x "<< v1_x <<endl;
		//cout<<" v1_y "<< v1_y <<endl;
		slope = (v1_y-v0_y)/(v1_x-v0_x);
		//cout<<"slope " << slope << endl;
		dist = v0_y - slope*v0_x;
		//cout<<" dist " << dist << endl;
		is_X_major =( (slope <= 1) && (slope >= -1) ) ? true : false;
		//cout<<" is_X_major " << is_X_major <<endl;
		if(is_X_major){
			slope_depth = (v1_z-v0_z)/((v1_x-v0_x)*float(width));
			dist_depth = v0_z - slope_depth*v0_x*float(width);
			slope_R = (v1_R-v0_R)/((v1_x-v0_x)*float(width));
			dist_R = v0_R - slope_R*v0_x*float(width);
			slope_G = (v1_G-v0_G)/((v1_x-v0_x)*float(width));
			dist_G = v0_G - slope_G*v0_x*float(width);
			slope_B = (v1_B-v0_B)/((v1_x-v0_x)*float(width));
			dist_B = v0_B - slope_B*v0_x*float(width);
			//cout << "v0_z v1_z v0_x v1_x = " << v0_z <<" "<< v1_z <<" "<< v0_x <<" "<< v1_x <<endl;
			//cout << "slope_R distR = " << slope_R << " " << dist_R << endl;
			intX = int(v0_x*float(width));
			intX = (intX < width)? intX : width-1;
				//cout << "intX = " << intX <<endl;
			int_v1_x = int(v1_x*float(width));
			int_v1_x = (int_v1_x < width)? int_v1_x : width-1;
				//cout << "int_v1_x = " << int_v1_x <<endl;
			while(intX != int_v1_x){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				y = slope*float(intX) + dist*float(width);
				z = slope_depth*float(intX) + dist_depth;
				color_R = slope_R*float(intX) + dist_R;
				color_G = slope_G*float(intX) + dist_G;
				color_B = slope_B*float(intX) + dist_B;
				//cout<<" result y = "<<y<<endl;
				//cout<<" result z = "<<z<<endl;
				//cout << "R slope_R intX dist_R = " << color_R << " " << slope_R << " "<< intX << " " << dist_R << endl;
				//cout << "R G B intX = " << color_R << " " << color_G << " "<< color_B << " " << intX << endl;
				intY = int(y);
				//cout<<" temp_intY = "<<intY<<endl;
				intY = (intY < height)? intY : height-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
				//if(zBuffer[offset]!=Z_INF){
					//cout<<"intersect!"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intX = (intX < int_v1_x) ? intX + 1 : intX - 1;
			}
		}
		else {	
			slope_depth = (v1_z-v0_z)/((v1_y-v0_y)*float(height));
			dist_depth = v0_z - slope_depth*v0_y*float(height);
			slope_R = (v1_R-v0_R)/((v1_y-v0_y)*float(height));
			dist_R = v0_R - slope_R*v0_y*float(height);
			slope_G = (v1_G-v0_G)/((v1_y-v0_y)*float(height));
			dist_G = v0_G - slope_G*v0_y*float(height);
			slope_B = (v1_B-v0_B)/((v1_y-v0_y)*float(height));
			dist_B = v0_B - slope_B*v0_y*float(height);
			intY = int(v0_y*float(height));
			intY = (intY < height)? intY : height-1;
			int_v1_y = int(v1_y*float(height));
			int_v1_y = (int_v1_y < height)? int_v1_y : height-1;
			while(intY != int_v1_y){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				x = (float(intY)-dist*float(width))/slope;
				z = slope_depth*float(intY) + dist_depth;
				color_R = slope_R*float(intY) + dist_R;
				color_G = slope_G*float(intY) + dist_G;
				color_B = slope_B*float(intY) + dist_B;
				//cout<<" result x = "<<x<<endl;
				intX = int(x);
				//cout<<" temp_intX = "<<intX<<endl;
				intX = (intX < width)? intX : width-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
					//cout<<"render a point"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intY = (intY < int_v1_y) ? intY + 1 : intY - 1;
			}
		}
		
		//========== v1 -> v2 ============//

		//cout<<" v1_x "<< v1_x <<endl;
		//cout<<" v1_y "<< v1_y <<endl;
		//cout<<" v2_x "<< v2_x <<endl;
		//cout<<" v2_y "<< v2_y <<endl;
		slope = (v2_y-v1_y)/(v2_x-v1_x);
		//cout<<" slope " << slope << endl;
		dist = v1_y - slope*v1_x;
		//cout<<" dist " << dist << endl;
		is_X_major =( (slope <= 1) && (slope >= -1) ) ? true : false;
		//cout<<" is_X_major " << is_X_major <<endl;
		if(is_X_major){
			slope_depth = (v2_z-v1_z)/((v2_x-v1_x)*float(width));
			dist_depth = v1_z - slope_depth*v1_x*float(width);
			slope_R = (v2_R-v1_R)/((v2_x-v1_x)*float(width));
			dist_R = v1_R - slope_R*v1_x*float(width);
			slope_G = (v2_G-v1_G)/((v2_x-v1_x)*float(width));
			dist_G = v1_G - slope_G*v1_x*float(width);
			slope_B = (v2_B-v1_B)/((v2_x-v1_x)*float(width));
			dist_B = v1_B - slope_B*v1_x*float(width);
			//cout << "v1_R v2_R v1_x v2_x = " << v1_R <<" "<< v2_R <<" "<< v1_x <<" "<< v2_x <<endl;
			//cout << "slope_R distR = " << slope_R << " " << dist_R << endl;
			intX = int(v1_x*float(width));
			intX = (intX < width)? intX : width-1;
			int_v2_x = int(v2_x*float(width));
			int_v2_x = (int_v2_x < width)? int_v2_x : width-1;
			while(intX != int_v2_x){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				y = slope*float(intX) + dist*float(width);
				z = slope_depth*float(intX) + dist_depth;
				color_R = slope_R*float(intX) + dist_R;
				color_G = slope_G*float(intX) + dist_G;
				color_B = slope_B*float(intX) + dist_B;
				//cout<<" result y = "<<y<<endl;
				//cout << "R slope_R intX dist_R = " << color_R << " " << slope_R << " "<< intX << " " << dist_R << endl;
				//cout << "R G B = " << color_R << " " << color_G << " "<< color_B << endl;
				intY = int(y);
				//cout<<" temp_intY = "<<intY<<endl;
				intY = (intY < height)? intY : height-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
					//cout<<"render a point"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intX = (intX < int_v2_x) ? intX + 1 : intX - 1;
			}
		}
		else {	
			slope_depth = (v2_z-v1_z)/((v2_y-v1_y)*float(height));
			dist_depth = v1_z - slope_depth*v1_y*float(height);
			slope_R = (v2_R-v1_R)/((v2_y-v1_y)*float(height));
			dist_R = v1_R - slope_R*v1_y*float(height);
			slope_G = (v2_G-v1_G)/((v2_y-v1_y)*float(height));
			dist_G = v1_G - slope_G*v1_y*float(height);
			slope_B = (v2_B-v1_B)/((v2_y-v1_y)*float(height));
			dist_B = v1_B - slope_B*v1_y*float(height);
			intY = int(v1_y*float(height));
			intY = (intY < height)? intY : height-1;
			int_v2_y = int(v2_y*float(height));
			int_v2_y = (int_v2_y < height)? int_v2_y : height-1;
			while(intY != int_v2_y){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				x = (float(intY)-dist*float(width))/slope;
				z = slope_depth*float(intY) + dist_depth;
				color_R = slope_R*float(intY) + dist_R;
				color_G = slope_G*float(intY) + dist_G;
				color_B = slope_B*float(intY) + dist_B;
				//cout<<" result x = "<<x<<endl;
				intX = int(x);
				//cout<<" temp_intX = "<<intX<<endl;
				intX = (intX < width)? intX : width-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
					//cout<<"render a point"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intY = (intY < int_v2_y) ? intY + 1 : intY - 1;
			}
		}
		
		//========== v2 -> v0 ============//

		//cout<<" v2_x "<< v2_x <<endl;
		//cout<<" v2_y "<< v2_y <<endl;
		//cout<<" v0_x "<< v0_x <<endl;
		//cout<<" v0_y "<< v0_y <<endl;
		slope = (v0_y-v2_y)/(v0_x-v2_x);
		//cout<<" slope " << slope << endl;
		dist = v2_y - slope*v2_x;
		//cout<<" dist " << dist << endl;
		is_X_major =( (slope <= 1) && (slope >= -1) ) ? true : false;
		//cout<<" is_X_major " << is_X_major <<endl;
		if(is_X_major){
			slope_depth = (v0_z-v2_z)/((v0_x-v2_x)*float(width));
			dist_depth = v2_z - slope_depth*v2_x*float(width);
			slope_R = (v0_R-v2_R)/((v0_x-v2_x)*float(width));
			dist_R = v2_R - slope_R*v2_x*float(width);
			slope_G = (v0_G-v2_G)/((v0_x-v2_x)*float(width));
			dist_G = v2_G - slope_G*v2_x*float(width);
			slope_B = (v0_B-v2_B)/((v0_x-v2_x)*float(width));
			dist_B = v2_B - slope_B*v2_x*float(width);
			//cout << "v2_R v0_R v2_x v0_x = " << v2_R <<" "<< v0_R <<" "<< v2_x <<" "<< v0_x <<endl;
			//cout << "slope_R distR = " << slope_R << " " << dist_R << endl;
			intX = int(v2_x*float(width));
			intX = (intX < width)? intX : width-1;
			int_v0_x = int(v0_x*float(width));
			int_v0_x = (int_v0_x < width)? int_v0_x : width-1;
			while(intX != int_v0_x){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				y = slope*float(intX) + dist*float(width);
				z = slope_depth*float(intX) + dist_depth;
				color_R = slope_R*float(intX) + dist_R;
				color_G = slope_G*float(intX) + dist_G;
				color_B = slope_B*float(intX) + dist_B;
				//cout<<" result y = "<<y<<endl;
				//cout << "R slope_R intX dist_R = " << color_R << " " << slope_R << " "<< intX << " " << dist_R << endl;
				//cout << "R G B = " << color_R << " " << color_G << " "<< color_B << endl;
				intY = int(y);
				//cout<<" temp_intY = "<<intY<<endl;
				intY = (intY < height)? intY : height-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
					//cout<<"render a point"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intX = (intX < int_v0_x) ? intX + 1 : intX - 1;
			}
		}
		else {	
			slope_depth = (v0_z-v2_z)/((v0_y-v2_y)*float(height));
			dist_depth = v2_z - slope_depth*v2_y*float(height);
			slope_R = (v0_R-v2_R)/((v0_y-v2_y)*float(height));
			dist_R = v2_R - slope_R*v2_y*float(height);
			slope_G = (v0_G-v2_G)/((v0_y-v2_y)*float(height));
			dist_G = v2_G - slope_G*v2_y*float(height);
			slope_B = (v0_B-v2_B)/((v0_y-v2_y)*float(height));
			dist_B = v2_B - slope_B*v2_y*float(height);
			intY = int(v2_y*float(height));
			intY = (intY < height)? intY : height-1;
			int_v0_y = int(v0_y*float(height));
			int_v0_y = (int_v0_y < height)? int_v0_y : height-1;
			while(intY != int_v0_y){
				//cout<<" slope = " << slope << endl
					//<<" intX = " << intX << endl
					//<<" dist = " << dist << endl;
				x = (float(intY)-dist*float(width))/slope;
				z = slope_depth*float(intY) + dist_depth;
				color_R = slope_R*float(intY) + dist_R;
				color_G = slope_G*float(intY) + dist_G;
				color_B = slope_B*float(intY) + dist_B;
				//cout<<" result x = "<<x<<endl;
				intX = int(x);
				//cout<<" temp_intX = "<<intX<<endl;
				intX = (intX < width)? intX : width-1;
				offset = intY*width + intX;
				//cout << "int X, intY = " << intX << " , " << intY << endl;
				// Z-test
				if(-z < zBuffer[offset]) {
					//cout<<"render a point"<<endl;
					zBuffer[offset] = -z;
					_frameBuffer[3*offset  ] = (unsigned char)(255.f*color_R);
					_frameBuffer[3*offset+1] = (unsigned char)(255.f*color_G);
					_frameBuffer[3*offset+2] = (unsigned char)(255.f*color_B);
				}
				intY = (intY < int_v0_y) ? intY + 1 : intY - 1;
			}
		}
		
	}

}

void Model::rasterizeSolid(int width, int height) {		// Solid mode
	_current_mode = 2;		// 0 = point cloud; 1 = wireframe; 2 = solid;
	_frame_wid = width;
	_frame_hei = height;
	float z;

	// Prepare a depth buffer
	int buffer_size = width*height;
	float* zBuffer = new float[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		zBuffer[i] = Z_INF;
	
	// Prepare a frame buffer
	buffer_size = width*height*3;
	_frameBuffer = new unsigned char[buffer_size];
	for(int i = 0; i < buffer_size; ++i)
		_frameBuffer[i] = 0;
	
	// If no color assigned, render color by depth
	if(!_isColored) {
		float color_base_r = 1.0f;
		float color_base_g = 1.0f;
		float color_base_b = 1.0f;
		float z_min, z_max;
		float scale_factor;
		z_min = z_max = _vertices[2];
		for(int i = 5; i < 3*_num_vertices; i += 3) {
			z = _vertices[i];
			if(z < z_min) {
				z_min = z;
			}
			else if(z > z_max) {
				z_max = z;
			}
		}
		scale_factor = z_max - z_min;
		for(int i = 0; i < _num_vertices; ++i) {
			_colors[3*i  ] = color_base_r*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+1] = color_base_g*(_vertices[3*i+2]-z_min)/scale_factor;
			_colors[3*i+2] = color_base_b*(_vertices[3*i+2]-z_min)/scale_factor;
			//cout << " R G B = " << _colors[3*i  ] << " " << _colors[3*i+1]<< " " << _colors[3*i+2] << endl;
		}
	}
	// Render
	bool is_inside, is_back_face;
	int v0, v1, v2;
	float v0_x, v0_y, v0_z, v1_x, v1_y, v1_z, v2_x, v2_y, v2_z, v_cross_a, v_cross_b, v_cross_c, v_cross_d, b0, b1, b2;
	float v0_R, v0_G, v0_B, v1_R, v1_G, v1_B, v2_R, v2_G, v2_B, a_R, b_R, c_R, d_R, a_G, b_G, c_G, d_G, a_B, b_B, c_B, d_B, color_R, color_G, color_B;
	for(int i = 0; i < _num_triangles; ++i) {
		v0 = _triangles[3*i  ];
		v1 = _triangles[3*i+1];
		v2 = _triangles[3*i+2];
		
		v0_x = _vertices[3*v0  ];
		v0_y = _vertices[3*v0+1];
		v0_z = _vertices[3*v0+2];
		v1_x = _vertices[3*v1  ];
		v1_y = _vertices[3*v1+1];
		v1_z = _vertices[3*v1+2];
		v2_x = _vertices[3*v2  ];
		v2_y = _vertices[3*v2+1];
		v2_z = _vertices[3*v2+2];
		v0_R = _colors[3*v0  ];
		v0_G = _colors[3*v0+1];
		v0_B = _colors[3*v0+2];
		v1_R = _colors[3*v1  ];
		v1_G = _colors[3*v1+1];
		v1_B = _colors[3*v1+2];
		v2_R = _colors[3*v2  ];
		v2_G = _colors[3*v2+1];
		v2_B = _colors[3*v2+2];
		//back face culling
		//(v1_x-v0_x) , (v1_y-v0_y) , (v1_z-v0_z)
		//(v2_x-v0_x) , (v2_y-v0_y) , (v2_z-v0_z)
		v_cross_a = (v1_y-v0_y)*(v2_z-v0_z)-(v1_z-v0_z)*(v2_y-v0_y);
		v_cross_b = (v1_z-v0_z)*(v2_x-v0_x)-(v1_x-v0_x)*(v2_z-v0_z);
		v_cross_c = (v1_x-v0_x)*(v2_y-v0_y)-(v1_y-v0_y)*(v2_x-v0_x);
		v_cross_d = v_cross_a*v0_x + v_cross_b*v0_y + v_cross_c*v0_z;
		//dot view vector (0,0,-1)
		is_back_face = (-v_cross_c)>0;
		//R plane
		//(v1_x-v0_x) , (v1_y-v0_y) , (v1_R-v0_R)
		//(v2_x-v0_x) , (v2_y-v0_y) , (v2_R-v0_R)
		a_R = (v1_y-v0_y)*(v2_R-v0_R)-(v1_R-v0_R)*(v2_y-v0_y);
		b_R = (v1_R-v0_R)*(v2_x-v0_x)-(v1_x-v0_x)*(v2_R-v0_R);
		c_R = (v1_x-v0_x)*(v2_y-v0_y)-(v1_y-v0_y)*(v2_x-v0_x);
		d_R = a_R*v0_x + b_R*v0_y + c_R*v0_R;
		//G plane
		//(v1_x-v0_x) , (v1_y-v0_y) , (v1_G-v0_G)
		//(v2_x-v0_x) , (v2_y-v0_y) , (v2_G-v0_G)
		a_G = (v1_y-v0_y)*(v2_G-v0_G)-(v1_G-v0_G)*(v2_y-v0_y);
		b_G = (v1_G-v0_G)*(v2_x-v0_x)-(v1_x-v0_x)*(v2_G-v0_G);
		c_G = (v1_x-v0_x)*(v2_y-v0_y)-(v1_y-v0_y)*(v2_x-v0_x);
		d_G = a_G*v0_x + b_G*v0_y + c_G*v0_G;
		//B plane
		//(v1_x-v0_x) , (v1_y-v0_y) , (v1_B-v0_B)
		//(v2_x-v0_x) , (v2_y-v0_y) , (v2_B-v0_B)
		a_B = (v1_y-v0_y)*(v2_B-v0_B)-(v1_B-v0_B)*(v2_y-v0_y);
		b_B = (v1_B-v0_B)*(v2_x-v0_x)-(v1_x-v0_x)*(v2_B-v0_B);
		c_B = (v1_x-v0_x)*(v2_y-v0_y)-(v1_y-v0_y)*(v2_x-v0_x);
		d_B = a_B*v0_x + b_B*v0_y + c_B*v0_B;
		if(!is_back_face){
		//if(true){
			for(int i=0;i<width;i++)
				for(int j=0;j<height;j++){
					b0 = (  (i - v1_x*float(width)) * (v0_y - v1_y)*float(height) - (v0_x - v1_x)*float(width) * (j - v1_y*float(height)) ) < 0.0f;
					b1 = (  (i - v2_x*float(width)) * (v1_y - v2_y)*float(height) - (v1_x - v2_x)*float(width) * (j - v2_y*float(height)) ) < 0.0f;
					b2 = (  (i - v0_x*float(width)) * (v2_y - v0_y)*float(height) - (v2_x - v0_x)*float(width) * (j - v0_y*float(height)) ) < 0.0f;
					is_inside = ((b0 == b1) && (b1 == b2));
					// Z-test
					if(is_inside){
						//depth plane
						z = (v_cross_d - v_cross_a*float(i)/float(width) - v_cross_b*float(j)/float(height))/v_cross_c;
						//R plane
						color_R = (d_R - a_R*float(i)/float(width) - b_R*float(j)/float(height))/c_R;
						//G plane
						color_G = (d_G - a_G*float(i)/float(width) - b_G*float(j)/float(height))/c_G;
						//B plane
						color_B = (d_B - a_B*float(i)/float(width) - b_B*float(j)/float(height))/c_B;
						if(-z < zBuffer[j*width+i]) {
							//cout<<"render a point"<<endl;
							zBuffer[j*width+i] = -z;
							_frameBuffer[3*(j*width+i)  ] = (unsigned char)(255.f*color_R);
							_frameBuffer[3*(j*width+i)+1] = (unsigned char)(255.f*color_G);
							_frameBuffer[3*(j*width+i)+2] = (unsigned char)(255.f*color_B);
						}
					}
			}
		}
	}
}
void Model::writePPM() {
	
	if(_current_mode == 0)
		_filename.replace(_filename.end()-4, _filename.end(), "_point.ppm");
	else if(_current_mode == 1)
		_filename.replace(_filename.end()-4, _filename.end(), "_wireframe.ppm");
	else
		_filename.replace(_filename.end()-4, _filename.end(), "_solid.ppm");

	cout << "Info: Writing to \"" << _filename.c_str() << "\"." << endl;

	ofstream ofs(_filename.c_str(), ios::out);
	ofs << "P3" << endl
		<< _frame_wid << " " << _frame_hei << endl
		<< 255 << endl;
	int offset;
	for(int y = _frame_hei-1; y >= 0; --y) {
		for(int x = _frame_wid-1; x >= 0; --x) {
			offset = y*_frame_wid+x;
			ofs << int(_frameBuffer[3*offset  ]) << " "
				<< int(_frameBuffer[3*offset+1]) << " "
				<< int(_frameBuffer[3*offset+2]) << " ";
		}
	}
	ofs.close();
}
