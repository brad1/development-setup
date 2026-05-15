#include <windows.h>
#include <list>
#include <fstream>
#include <string>

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#define texWidth  32
#define texHeight 32
#define NUM_JOINTS 16

using std::fstream;
using std::ofstream;
using std::string;

// used for reshaping the display on window resize
const int START_WIDTH = 540;
const int START_HEIGHT = 540;

int SCREEN_WIDTH = START_WIDTH;
int SCREEN_HEIGHT = START_HEIGHT;

bool DRAGGING        = false;
bool MOVING_JOINTS   = false;
bool ZOOMING_CAMERA  = false;
bool ROTATING_CAMERA = false;
bool PANNING_CAMERA  = false;
int startY = 0;
int startX = 0;

/* --- camera manipulation --- */
const float camera_distance = 30.0f;
const float zoom_max = 5.0f;
const float zoom_min = 1.0f;
float zoom_points = 0.0f;
float camera_zoom = 1.0f;

float camera_angle_up = 45.0f;
float camera_angle_side = -45.0f;

float camera_height = 0.0f;

// for saving file
bool TYPING = false;
string outFileName = "";
ofstream outFile;

// Joint manipulation
int JOINT = 0;
GLfloat jointAngles[NUM_JOINTS];
fstream jointsFile;

GLuint  texture;
GLubyte image[texHeight][texWidth][4];

// calback functions
void myKeyboardCB(unsigned char key, int x, int y);
void myMouseCB(int button, int state, int x, int y);
void myMotionCB(int x, int y);
void reshapeCB( int width, int height );
void display();

// callback helpers
void mousePress(int, int);
void mouseRelease(int, int);
void rightClickMenu(int);

void mouseToScreen( int& );
void drawAxis();
void setupLights();

// model routines
void drawRobot();
void drawHip();
void drawUpperBody();
void drawLowerBody();
void drawStomache();
void drawChest();
void drawRightArm();
void drawLeftArm();
void drawRightLeg();
void drawLeftLeg();
void drawHead();

/* Generate texture */
void generateTex();

/* Other helpers */
void defaultJoints( GLfloat * );
void loadJoints( GLfloat *, char * );
void saveToFile(void);
void zoomCamera(void);
void rotateCamera(int,int);
void panCamera( int );

// Main method sets up for openGL infinite loop
int main ( int argc, char **argv ) {
	if( argc == 2 ) {
		loadJoints( jointAngles, argv[1] );
	} else {
		defaultJoints( jointAngles );
	}
	
	glutInit(&argc, argv);
	glutInitDisplayMode ( GLUT_SINGLE | GLUT_RGB );
	glutInitWindowSize( START_WIDTH, START_HEIGHT );		
	glutInitWindowPosition( 100, 100 );
	glutCreateWindow("3Dobj");
	
	// setup callbacks
	glutKeyboardFunc( myKeyboardCB );
	glutMouseFunc( myMouseCB );
	glutMotionFunc(myMotionCB);
	glutReshapeFunc(reshapeCB);
	glutDisplayFunc(display);
	

	// Setup right click menu
	glutCreateMenu(rightClickMenu);
	glutAddMenuEntry("Deselect joint", 0);
	glutAddMenuEntry("Bend neck", 1);
	glutAddMenuEntry("Bend over (chest)", 2);
	glutAddMenuEntry("Bend over (waist)", 3);
	glutAddMenuEntry("Lift leg (Left)", 4);	
	glutAddMenuEntry("Lift leg (Right)", 5);
	glutAddMenuEntry("Bend knee (Left)", 6);
	glutAddMenuEntry("Bend knee (Right)", 7);
	glutAddMenuEntry("Bend ankle (Left)", 8);
	glutAddMenuEntry("Bend ankle (Right)", 9);
	glutAddMenuEntry("Lift shoulder (Left)", 10);
	glutAddMenuEntry("Lift shoulder (Right)", 11);
	glutAddMenuEntry("Bend elbow (Left)", 12);
	glutAddMenuEntry("Bend elbow (Right)", 13);
	glutAddMenuEntry("Bend wrist (Left)", 14);
	glutAddMenuEntry("Bend wrist (Right)", 15);
	glutAddMenuEntry("Save file", 16);
	glutAddMenuEntry("Rotate camera", 17);
	glutAddMenuEntry("Pan camera", 18);
	glutAddMenuEntry("Zoom camera", 19);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
	
	setupLights();
	generateTex();

	glutMainLoop();
	return 0;
}

void myKeyboardCB(unsigned char key, int x, int y) {
	if( !TYPING ) {
		return;
	}

	// Presses return, done typing file name
	if( key == 13 ) {
		saveToFile();
		TYPING = false;
	} else {
		outFileName += key;
	}

	printf("%c", key );
	return;
}

/* Click and release the mouse */
void myMouseCB(int button, int state, int x, int y) {
	if( button == 0 ) {
		switch( state ) {
			case 0 :
				mousePress( x, y );
				break;
			case 1 :
				mouseRelease(x, y);
				break;
		}
	}

	return;
}

/* Dragging camera or bending joints */
void myMotionCB(int x, int y) {
	if( !DRAGGING ) return;
	mouseToScreen(y);

	if( MOVING_JOINTS ) {
		int move = y - startY;
		startY = y;
		jointAngles[JOINT] += move;
		display();
		return;
	}

	if( ZOOMING_CAMERA ) {
		int move = y - startY;
		startY = y;
		zoom_points += 0.05f * move;
		zoomCamera();
		return;
	}

	if( ROTATING_CAMERA ) {
		int move_x = x - startX;
		int move_y = y - startY;
		startX = x;
		startY = y;
		rotateCamera(move_x, move_y);
		return;
	}

	if( PANNING_CAMERA ) {
		int move_y = y - startY;
		startY = y;
		panCamera( move_y );
		return;
	}
}

/* gl display function */
void display() {	
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	
	gluLookAt (0.0, camera_height, camera_distance, 0.0, camera_height, 0.0, 0.0, 1.0, 0.0);
	glRotatef( camera_angle_up, 1.0, 0.0, 0.0 );
	glRotatef( camera_angle_side, 0.0, 1.0, 0.0 );

	drawAxis();

	// setup texture to be applied to robot
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture);

	drawRobot();

    glFlush ();
	glDisable(GL_TEXTURE_2D);
	return;
}          

/* gl reshaping function */
void reshapeCB( int width, int height ) {
	SCREEN_WIDTH = width;
	SCREEN_HEIGHT = height;
	
	glViewport (0, 0, (GLsizei) width, (GLsizei) height); 
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();

	/* Make sure that resizing the window widens the view instead of 
	stretching the scene. Also controls the camera zoom. */
	glFrustum (-0.5*width / START_WIDTH, 
		0.5*width / START_WIDTH, 
		-0.5*height / START_HEIGHT, 
		0.5*height /START_HEIGHT, 
		1.0 + camera_zoom, 
		100.0);
	
	glMatrixMode (GL_MODELVIEW);
}

/* Converts mouse y coordinate to match the screen */
void mouseToScreen( int& y) {
	y = SCREEN_HEIGHT - y;
}

/* Draws red, green, and blue lines for X, Y, and Z axis respectively */
void drawAxis() {
	glDisable( GL_LIGHTING );
	glBegin( GL_LINES );
	
	glColor3f( 1.0, 0.0, 0.0 );
	glVertex3f( 0.0, 0.0, 0.0 );
	glVertex3f( 200.0, 0.0, 0.0 );

	glColor3f( 0.0, 1.0, 0.0 );
	glVertex3f( 0.0, 0.0, 0.0 );
	glVertex3f( 0.0, 200.0, 0.0 );

	glColor3f( 0.0, 0.0, 1.0 );
	glVertex3f( 0.0, 0.0, 0.0 );
	glVertex3f( 0.0, 0.0, 200.0 );
	
	glEnd();

	glPointSize(5.0f);
	glBegin( GL_POINTS );
		
	glColor3f( 1.0, 0.0, 0.0 );
	glVertex3f( 1.0, 0.0, 0.0 );
	glVertex3f( 2.0, 0.0, 0.0 );
	glVertex3f( 3.0, 0.0, 0.0 );

	glColor3f( 0.0, 1.0, 0.0 );
	glVertex3f( 0.0, 1.0, 0.0 );
	glVertex3f( 0.0, 2.0, 0.0 );
	glVertex3f( 0.0, 3.0, 0.0 );

	glColor3f( 0.0, 0.0, 1.0 );
	glVertex3f( 0.0, 0.0, 1.0 );
	glVertex3f( 0.0, 0.0, 2.0 );
	glVertex3f( 0.0, 0.0, 3.0 );

	glEnd();
	glEnable( GL_LIGHTING );
}

/* setup the lights for the scene */
void setupLights()
{
	GLfloat light0position[] = { 1.0, 1.0, 1.0, 0.0 };
	glClearColor (0.0, 0.0, 0.0, 0.0);
	glShadeModel (GL_SMOOTH);
	
	glLightfv(GL_LIGHT0, GL_POSITION, light0position);

	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
}


/* ------------ Modeling routines ---------- */

void drawRobot() {
	drawHip();
	drawUpperBody();
	drawLowerBody();
}

void drawHip() {
	glTranslatef( 0.0f, 3.0f, 0.0f );
	glPushMatrix();
	glRotatef( jointAngles[3], 1.0, 0.0, 0.0 );
	glutSolidSphere( 0.5, 10.0, 10.0);
}

void drawUpperBody() {
	glPushMatrix();

	drawStomache();
	drawChest();
	drawRightArm();
	drawLeftArm();
	drawHead();

	glPopMatrix();
}

void drawStomache() {
	glTranslatef( 0.0f, 0.85f, 0.0f );
	glRotatef( 0.0, 1.0, 0.0, 0.0 );
	glutSolidSphere( 0.4, 10.0, 10.0);
}

void drawChest() {
	glRotatef( jointAngles[2], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, -1.5f );
	glutSolidCone( 0.5, 2.0, 10.0, 10.0 );
}

void drawRightArm() {
	glPushMatrix();

	// upper arm
	glTranslatef( -0.75f, 0.0f, 0.0f );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[11], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.0, 10.0, 10.0 );

	// lower arm
	glTranslatef( 0.0f, 0.0f, 0.8f );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[13], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 1.0, 10.0, 10.0 );

	// drawAxis();

	glTranslatef( 0.0f, 0.0f, 1.0f );
	glRotatef( jointAngles[15], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, 0.25f );
	glutSolidSphere( 0.125, 10.0, 10.0 );

	glPopMatrix();
}

void drawLeftArm() {
	glPushMatrix();

	// upper arm
	glTranslatef( 0.75f, 0.0f, 0.0f );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[10], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.0, 10.0, 10.0 );

	// lower arm
	glTranslatef( 0.0f, 0.0f, 0.8f );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[12], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 1.0, 10.0, 10.0 );

	// drawAxis();

	glTranslatef( 0.0f, 0.0f, 1.0f );
	glRotatef( jointAngles[14], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, 0.25f );
	glutSolidSphere( 0.125, 10.0, 10.0 );

	glPopMatrix();}

void drawHead() {
	glRotatef( jointAngles[1], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, -0.75f );
	glutSolidCone( 0.35, 1.0, 10.0, 10.0 );
}

void drawLowerBody() {
	glPopMatrix(); // to joint to hip
	drawRightLeg();
	drawLeftLeg();
}

void drawRightLeg() {
	glPushMatrix();

	// upper leg
	glRotatef( jointAngles[5], 1.0, 0.0, 0.0 );
	glTranslatef( -0.45, 0.0, 0.0 );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glutSolidCone( 0.4, 2.0, 10.0, 10.0 );
	
	// lower leg
	glTranslatef( 0.0, 0.0, 1.2 );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[7], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.5, 10.0, 10.0 );
	
	// foot
	glTranslatef( 0.0, 0.0, 1.45 );
	glRotatef( jointAngles[9], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 0.5, 10.0, 10.0 );	
	glPopMatrix();
}

void drawLeftLeg() {
	glPushMatrix();

	// upper leg
	glRotatef( jointAngles[4], 1.0, 0.0, 0.0 );
	glTranslatef( 0.45, 0.0, 0.0 );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glutSolidCone( 0.4, 2.0, 10.0, 10.0 );
	
	// lower leg
	glTranslatef( 0.0, 0.0, 1.2 );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[6], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.5, 10.0, 10.0 );

	// foot
	glTranslatef( 0.0, 0.0, 1.45 );
	glRotatef( jointAngles[8], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 0.5, 10.0, 10.0 );	
	glPopMatrix();
}


/* Texture generating routine */
void generateTex() {
	// generate a gray image with full alpha
	for(int i = 0; i < texHeight; i++) {
		for(int j = 0; j < texWidth; j++) {
			image[i][j][0] = (GLubyte) 127;
			image[i][j][1] = (GLubyte) 127;
			image[i][j][2] = (GLubyte) 127;
			image[i][j][3] = (GLubyte) 255;
		}
	}

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
}

/* ---- Mouse routines ---- */

void mousePress( int x, int y ) {
	DRAGGING = true;
	mouseToScreen(y);
	startY = y;
}

void mouseRelease( int x, int y ) {
	DRAGGING        = false;
	MOVING_JOINTS   = false;
	ZOOMING_CAMERA  = false;
	ROTATING_CAMERA = false;
	PANNING_CAMERA  = false;
	
	zoom_points = 0.0f;
}


void rightClickMenu(int i) {
	// type file name
	if( i == 16 ) {
		outFileName = "";
		printf("Specify file name \n");
		TYPING = true;
		return;
	} 

	if( i == 17 ) {
		ROTATING_CAMERA = true;
		return;
	}

	if (i == 18 ) {
		PANNING_CAMERA = true;
		return;
	}

	if ( i == 19 ) {
		ZOOMING_CAMERA = true;
		return;
	}

	MOVING_JOINTS = true;
	JOINT = i;
}

/* Default angles for joints if no file is used */
void defaultJoints( GLfloat *jointAngles ) {
	jointAngles[1]  = 0.0;
	jointAngles[2]  = 90.0;
	jointAngles[3]  = 0.0;
	jointAngles[4]  = 90.0;
	jointAngles[5]  = 90.0;
	jointAngles[6]  = 0.0;
	jointAngles[7]  = 0.0;
	jointAngles[8]  = -90.0;
	jointAngles[9]  = -90.0;
	jointAngles[10] = 0.0;
	jointAngles[11] = 0.0;
	jointAngles[12] = 0.0;
	jointAngles[13] = 0.0;
	jointAngles[14] = 0.0;
	jointAngles[15] = 0.0;
}

/* Load joint angles from file */
void loadJoints( GLfloat *jointAngles, char *fileName  ) {
	jointsFile.open( fileName );

	for( int i = 1; i < 16; i++) {
		jointAngles[i] = jointsFile.get();
	}

	if( jointsFile.fail() ) {
		printf("Invalid input file \n");
		defaultJoints( jointAngles );
	} else {
		printf("Loaded file successfully \n");
	}

	jointsFile.close();
}

void saveToFile() {
	outFile.open( outFileName.c_str());
	for( int i = 1; i < 16; i++ ) {
		outFile.put( jointAngles[i] );			
	}
	outFile.close();
}

/* ------ Camera routines ------ */

void zoomCamera() {
	camera_zoom = zoom_max - zoom_points;
	if( camera_zoom < zoom_min ) {
		camera_zoom = zoom_min;
	} else if( camera_zoom > zoom_max ) {
		camera_zoom = zoom_max;
	}
	reshapeCB( SCREEN_WIDTH, SCREEN_HEIGHT );
	display();
}

void rotateCamera( int dx, int dy ) {
	camera_angle_up -= (float) dy;
	camera_angle_side += (float) dx;
	reshapeCB( SCREEN_WIDTH, SCREEN_HEIGHT );
	display();
}

void panCamera( int dy ) {
	camera_height -= 0.02f * dy;
	reshapeCB( SCREEN_WIDTH, SCREEN_HEIGHT );
	display();
}
