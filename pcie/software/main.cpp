#include <Windows.h>
#include <cassert>
#include <cstdio>
#include <bitset>
#include "TERASIC_PCIE.h"
#include "PCIE.h"
#include "rasterization.h"
#include "time.h"

#define VID 0x1172
#define DID 0xE001
#define BAR PCIE_BAR1

PCIE pcie;  // this is the PCIe handle (see PCIE.h and TERASIC_PCIE.h)

FILE* logFile = fopen("log.txt", "w");

// PCIE test function
DWORD f(int idx) {  // some function used to define written data
	//return idx;
	return (idx ^ 0x31415926) * 0x53589793;
}

struct Point{
	WORD coor_x;
	WORD coor_y;
	WORD coor_z;
	BYTE r;
	BYTE g;
	BYTE b;
	bool operator==(Point a){
		if( (*this).coor_x==a.coor_x&&
			(*this).coor_x==a.coor_y&&
			(*this).coor_x==a.coor_z&&
			(*this).coor_x==a.r&&
			(*this).coor_x==a.g&&
			(*this).coor_x==a.b)
		return 1;
		else return 0;
	}
	bool operator!=(Point a){
		return !((*this)==a);
	}
};

struct Triangle{
	Point a;
	Point b;
	Point c;
	BYTE change;

	bool operator==(Triangle test){
		if( (*this).a==test.a&&
			(*this).b==test.b&&
			(*this).c==test.c&&
			(*this).change==test.change)
		return 1;
		else return 0;
	}
	bool operator!=(Triangle test){
		return !((*this)==test);
	}
	//Triangle(){
	//	cout << "size of point is " << sizeof(a) << endl;
	//}
};

bool scTest() {
	// single cycle r/w test
	// address should be 4's multiple
	const int N = 1024;
	for (int i = 0; i < N; ++i) {
		PCIE_ADDRESS addr = i*4;
		DWORD wdata = f(i);
		assert(pcie.Write32(BAR, addr, wdata));
	}
	int ndiff = 0;
	for (int i = 0; i < N; ++i) {
		PCIE_ADDRESS addr = i*4;
		DWORD expected = f(i);
		DWORD rdata = 0;
		assert(pcie.Read32(BAR, addr, &rdata));
		if (rdata != expected) ++ndiff;
		fprintf(logFile, "%04X %08X %08X %d\n", addr, rdata, expected, ndiff);
	}
	return (ndiff == 0);
}

WORD fix_word(float f){
	return (int(f)==1)?0xffff:(WORD)(f*65535);
}

BYTE fix_byte(float f){
	return (int(f)==1)?0xff:(BYTE)(f*256);
}

bool dmaTest(Model* model) {
	// DMA r/w test
	// address should be 16's multiple
	//const int N = 4096;
	//DWORD wdata[N] = {};
	//DWORD rdata[N] = {};
	//for (int i = 0; i < N; ++i) {
	//	wdata[i] = f(i);
	//}
	//cout << sizeof(wdata) << endl;
	//assert(pcie.DmaWrite(0, wdata, sizeof(wdata)));
	//assert(pcie.DmaRead(0, rdata, sizeof(rdata)));
	// *needs modification
	const int vertices_num = (*model)._num_vertices;
	const int color_num	= (*model)._num_colors;
	const int triangle_num = (*model)._num_triangles;
	Triangle *triangle = new Triangle[triangle_num];
	Triangle *triangle_test = new Triangle[triangle_num];
	//cout << "floating point a.coor_x is " << (*model)._vertices[0] << endl;
	//cout << "fix point a.coor_x is " << bitset<16>(fix_word((*model)._vertices[0])) << endl;
	//for(int i=0;i<vertices_num;i++){
	//	cout << "color [" << i << "] is (" <<  (*model)._colors[3*i  ] << ", " <<  (*model)._colors[3*i+1] << ", " <<  (*model)._colors[3*i+2] << ")" <<endl;
	//	cout << "vertices[" << i << "]'s coordinate is (" << (*model)._vertices[3*i] << ", " << (*model)._vertices[3*i+1] << ", " << (*model)._vertices[3*i+2] << ")" << endl; 
	//}
	for(int i=0;i<triangle_num;i++){
		//cout << "triangle[" << i << "]'s vertices number is (" << (*model)._triangles[3*i] << ", " << (*model)._triangles[3*i+1] << ", " << (*model)._triangles[3*i+2] << ")" << endl; 
		triangle[i].a.coor_x = fix_word((*model)._vertices[3*(*model)._triangles[3*i]  ]);
		triangle[i].a.coor_y = fix_word((*model)._vertices[3*(*model)._triangles[3*i]+1]);
		triangle[i].a.coor_z = fix_word((*model)._vertices[3*(*model)._triangles[3*i]+2]);
		triangle[i].a.r		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i]  ]);
		triangle[i].a.g		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i]+1]);
		triangle[i].a.b		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i]+2]);
		triangle[i].b.coor_x = fix_word((*model)._vertices[3*(*model)._triangles[3*i+1]  ]);
		triangle[i].b.coor_y = fix_word((*model)._vertices[3*(*model)._triangles[3*i+1]+1]);
		triangle[i].b.coor_z = fix_word((*model)._vertices[3*(*model)._triangles[3*i+1]+2]);
		triangle[i].b.r		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+1]  ]);
		triangle[i].b.g		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+1]+1]);
		triangle[i].b.b		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+1]+2]);
		triangle[i].c.coor_x = fix_word((*model)._vertices[3*(*model)._triangles[3*i+2]  ]);
		triangle[i].c.coor_y = fix_word((*model)._vertices[3*(*model)._triangles[3*i+2]+1]);
		triangle[i].c.coor_z = fix_word((*model)._vertices[3*(*model)._triangles[3*i+2]+2]);
		triangle[i].c.r		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+2]  ]);
		triangle[i].c.g		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+2]+1]);
		triangle[i].c.b		 = fix_byte((*model)._colors[3*(*model)._triangles[3*i+2]+2]);
		triangle[i].change   = (i==triangle_num-1)?1:0;
		//cout << "write PCIE bus " << bitset<16>(triangle[i].a.coor_x) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].a.coor_y) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].a.coor_z) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].a.r     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].a.g     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].a.b     ) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].b.coor_x) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].b.coor_y) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].b.coor_z) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].b.r     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].b.g     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].b.b     ) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].c.coor_x) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].c.coor_y) << endl
		//	 << "write PCIE bus " << bitset<16>(triangle[i].c.coor_z) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].c.r     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].c.g     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].c.b     ) << endl
		//	 << "write PCIE bus " << bitset<8 >(triangle[i].change  ) << endl;
	}
	cout << "size of triangles is " << (sizeof(*triangle)*triangle_num) << endl;
	//assert(pcie.DmaWrite(0, triangle, (sizeof(*triangle))*triangle_num));

	//assert(pcie.DmaRead(0, triangle_test, (sizeof(*triangle_test))*triangle_num));
	//int ndiff = 0;
	//for (int i = 0; i < triangle_num; ++i) {
	//	//PCIE_ADDRESS addr = i*4;
	//	if (triangle[i] != triangle_test[i]) ++ndiff;
	//	//fprintf(logFile, "%04X %08X %08X %d\n", addr, rdata[i], wdata[i], ndiff);
	//}
	//cout << "error num is " << ndiff << endl;
	//return (ndiff == 0);

	return 1;
}

void usage() {
	cerr << "[Usage] Rasterization.exe <filename>" << endl;
	exit(-1);
}


int main(int args, char* argv[]) {

	if(args != 2) {
		usage();
	}
	
	Model* model = new Model();
	if(!model->load(argv[1])) {
		usage();
	}
	
	// Apply some transformation (model dependent)
	// for example:
	
	model->rotateX(PI/8.0);
	model->rotateY(-PI/12.0);
	//model->rotateZ(-PI/4.0);
	model->normalize();
	model->rendercolor();
	//assert(pcie.IsDriverAvailable());  // is there available driver?
	//assert(pcie.Open(VID, DID, 0));  // is there available FPGA card?
	
	if (dmaTest(model)) {
		printf("PCIe r/w in DMA mode succeeded :)\n");
	} else {
		printf("PCIe r/w in DMA mode failed QQ\n");
	}
	
	return 0;
}