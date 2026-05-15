#include <windows.h>
#include <list>
#include <fstream>
#include <string>
#include <ctime>
#include <iostream>

#include <GL/gl.h>
#include <GL/glu.h>
#include <glut.h>

#define texWidth  32
#define texHeight 32
#define NUM_JOINTS 16

#define DEBUG
//#define STEPPLAYBACK

using namespace std;


/* For animation playback */
	
// matrix inverse taken from notes for 
// calculating hermite cubic coefficients
float matrix[4][4] = { 
	{  2.0f, -2.0f,  1.0f,  1.0f }, 
	{ -3.0f,  3.0f, -2.0f, -1.0f },
	{  0.0f,  0.0f,  1.0f,  0.0f },
	{  1.0f,  0.0f,  0.0f,  0.0f } 
};

bool animationPlaying = false;
bool animationLoaded = false;

list<float**> cubics;
float **cubic;

float pointsEtc[4];
float t0;
float t1;
float t;

list<float*> playbackPoses;
int remainingPlaybackPoses;

list<float> poseTimes;

float numPoses;

float *pose0;
float *pose1;

clock_t animationStart;
/*------------------------*/

/* Animation editing */
list<GLfloat*> editPoses;
list<GLfloat> editTimes;
/* ----------------- */

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
/*--------------------------*/

// Joint manipulation
int JOINT = 0;
GLfloat jointAngles[NUM_JOINTS];
fstream jointsFile;

GLuint  texture;
GLubyte image[texHeight][texWidth][4];

// calback functions
void myMouseCB(int button, int state, int x, int y);
void myMotionCB(int x, int y);
void reshapeCB( int width, int height );
void idleFunc();
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
void loadJoints(void);
void saveJoints(void);
void zoomCamera(void);
void rotateCamera(int,int);
void panCamera( int );

void cubicCoeffs( float *, float *);
void resetAnimation(void);
void saveAnimation(void);
float calcAngle( float **, int);
bool loadAnimation(void);
void addKeyframe(void);
void addPoseToAnimation(void);
void playAnimation(void);
void reduceJoint( float& );
void clearLoadedAnimation(void);

// Main method sets up for openGL infinite loop
int main ( int argc, char **argv ) {
	defaultJoints( jointAngles );
	
	glutInit(&argc, argv);
	glutInitDisplayMode ( GLUT_SINGLE | GLUT_RGB );
	glutInitWindowSize( START_WIDTH, START_HEIGHT );		
	glutInitWindowPosition( 100, 100 );
	glutCreateWindow("3Dobj");
	
	// setup callbacks
	glutMouseFunc( myMouseCB );
	glutMotionFunc(myMotionCB);
	glutReshapeFunc(reshapeCB);
	glutDisplayFunc(display);
	glutIdleFunc(idleFunc);

	// Setup right click menu
	glutCreateMenu(rightClickMenu);
	glutAddMenuEntry("Bend neck", 0);
	glutAddMenuEntry("Bend over (chest)", 1);
	glutAddMenuEntry("Bend over (waist)", 2);
	glutAddMenuEntry("Lift leg (Left)", 3);	
	glutAddMenuEntry("Lift leg (Right)", 4);
	glutAddMenuEntry("Bend knee (Left)", 5);
	glutAddMenuEntry("Bend knee (Right)", 6);
	glutAddMenuEntry("Bend ankle (Left)", 7);
	glutAddMenuEntry("Bend ankle (Right)", 8);
	glutAddMenuEntry("Lift shoulder (Left)", 9);
	glutAddMenuEntry("Lift shoulder (Right)", 10);
	glutAddMenuEntry("Bend elbow (Left)", 11);
	glutAddMenuEntry("Bend elbow (Right)", 12);
	glutAddMenuEntry("Bend wrist (Left)", 13);
	glutAddMenuEntry("Bend wrist (Right)", 14);
	glutAddMenuEntry("Deselect joint", 15);
	glutAddMenuEntry("Save animation", 16);
	glutAddMenuEntry("Rotate camera", 17);
	glutAddMenuEntry("Pan camera", 18);
	glutAddMenuEntry("Zoom camera", 19);
	glutAddMenuEntry("Load animation", 20);
		
	// add to rightc
	glutAddMenuEntry("Load pose", 21);
	glutAddMenuEntry("Save pose", 22);
	glutAddMenuEntry("Add pose to current animation", 23);
	glutAddMenuEntry("Play Animation", 24);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
	
	setupLights();
	generateTex();

	glutMainLoop();
	return 0;
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

	if( MOVING_JOINTS && JOINT < NUM_JOINTS) {
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
		0.5*height / START_HEIGHT, 
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
	glRotatef( jointAngles[2], 1.0, 0.0, 0.0 );
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
	glRotatef( 90.0f, 1.0, 0.0, 0.0 );
	glRotatef( jointAngles[1], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, -1.5f );
	glutSolidCone( 0.5, 2.0, 10.0, 10.0 );
}

void drawRightArm() {
	glPushMatrix();

	// upper arm
	glTranslatef( -0.75f, 0.0f, 0.0f );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[10], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.0, 10.0, 10.0 );

	// lower arm
	glTranslatef( 0.0f, 0.0f, 0.8f );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[12], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 1.0, 10.0, 10.0 );

	glTranslatef( 0.0f, 0.0f, 1.0f );
	glRotatef( jointAngles[14], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, 0.25f );
	glutSolidSphere( 0.125, 10.0, 10.0 );

	glPopMatrix();
}

void drawLeftArm() {
	glPushMatrix();

	// upper arm
	glTranslatef( 0.75f, 0.0f, 0.0f );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );

	glRotatef( jointAngles[9], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.0, 10.0, 10.0 );

	// lower arm
	glTranslatef( 0.0f, 0.0f, 0.8f );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[11], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 1.0, 10.0, 10.0 );

	glTranslatef( 0.0f, 0.0f, 1.0f );
	glRotatef( jointAngles[13], 1.0, 0.0, 0.0 );
	glTranslatef( 0.0f, 0.0f, 0.25f );
	glutSolidSphere( 0.125, 10.0, 10.0 );

	glPopMatrix();}

void drawHead() {
	glRotatef( jointAngles[0], 1.0, 0.0, 0.0 );	
	glTranslatef( 0.0f, 0.0f, -0.75f );
	glutSolidCone( 0.35, 1.0, 10.0, 10.0 );
}

void drawLowerBody() {
	glPopMatrix();
	drawRightLeg();
	drawLeftLeg();
}

void drawRightLeg() {
	glPushMatrix();

	// upper leg
	glRotatef( 90.0f, 1.0, 0.0, 0.0 );
	glRotatef( jointAngles[4], 1.0, 0.0, 0.0 );
	glTranslatef( -0.45, 0.0, 0.0 );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glutSolidCone( 0.4, 2.0, 10.0, 10.0 );
	
	// lower leg
	glTranslatef( 0.0, 0.0, 1.2 );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[6], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.5, 10.0, 10.0 );
	
	// foot
	glTranslatef( 0.0, 0.0, 1.45 );
	glRotatef( -90.0f, 1.0, 0.0, 0.0 );
	glRotatef( jointAngles[8], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.125, 0.5, 10.0, 10.0 );	
	glPopMatrix();
}

void drawLeftLeg() {
	glPushMatrix();

	// upper leg
	glRotatef( 90.0f, 1.0, 0.0, 0.0 );
	glRotatef( jointAngles[3], 1.0, 0.0, 0.0 );
	glTranslatef( 0.45, 0.0, 0.0 );
	glRotatef( 12.0, 0.0, 1.0, 0.0 );
	glutSolidCone( 0.4, 2.0, 10.0, 10.0 );
	
	// lower leg
	glTranslatef( 0.0, 0.0, 1.2 );
	glRotatef( -12.0, 0.0, 1.0, 0.0 );
	glRotatef( jointAngles[5], 1.0, 0.0, 0.0 );
	glutSolidCone( 0.25, 1.5, 10.0, 10.0 );

	// foot
	glTranslatef( 0.0, 0.0, 1.45 );
	glRotatef( -90.0f, 1.0, 0.0, 0.0 );
	glRotatef( jointAngles[7], 1.0, 0.0, 0.0 );
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

	if( i == 16 ) {
		saveAnimation();
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

	if( i == 20 ) {
		loadAnimation();
		return;
	}

	if( i == 21 ) {
		loadJoints();
		return;
	}

	if( i == 22 ) {
		saveJoints();
		return;
	}

	if( i == 23 ) {
		addPoseToAnimation();
		return;
	}

	if( i == 24 ) {
		playAnimation();
		return;
	}

	MOVING_JOINTS = true;
	JOINT = i;
}

/* Default angles for joints if no file is used */
void defaultJoints( GLfloat *jointAngles ) {
	for( int i = 0; i < NUM_JOINTS; i++ ) {
		jointAngles[i] = 0.0f;
	}
}

void loadJoints() {
	string filename;
	cout << "Type the name of a pose file" << endl;
	cin  >> filename;
	
	#ifdef DEBUG
	cout << "Attempting to open " << filename << endl;  
	#endif
	jointsFile.open( filename.c_str() );

	for( int i = 0; i < NUM_JOINTS; i++) {
		jointsFile >> jointAngles[i];
	}

	if( jointsFile.fail() ) {
		cout << "Invalid input file" << endl;
	} else {
		cout << "Loaded file successfully" << endl;
		display();
	}

	jointsFile.close();
}

void saveJoints() {
	string outFileName;
	ofstream outFile;
	cout << "Type a file name to save your pose" << endl;
	cin  >> outFileName;
	#ifdef DEBUG
	cout << "Attempting to save " << outFileName << endl;
	#endif
	outFile.open( outFileName.c_str());
	for( int i = 0; i < NUM_JOINTS; i++ ) {
		outFile << jointAngles[i] << endl;
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

/* generates coefficients for a cubic spline */
void cubicCoeffs( float *cubic, float *pointsEtc ) {
	for( int i = 0; i < 4; i++ ) {
		cubic[i] = 0.0f;
		for( int j = 0; j < 4; j++ ) {
			cubic[i] +=  matrix[i][j] * pointsEtc[j];
		}
	}
}

void idleFunc() {
	if( !animationPlaying ) {
		return;
	}

#ifdef STEPPLAYBACK
	t += 0.1f;
#else
	t = (clock() - animationStart) / (float) CLOCKS_PER_SEC;
#endif

	if( t >= t1 ) {			
		/* If there are more keyframes, continue */
		if( remainingPlaybackPoses > 0 ) {
			t0 = t1;
			t1 = poseTimes.front();
			poseTimes.pop_front();
			playbackPoses.push_back( pose0 );
			pose0 = pose1;
			pose1 = playbackPoses.front();
			playbackPoses.pop_front();
			remainingPlaybackPoses--;
			cubic = cubics.front();
			cubics.pop_front();
			cubics.push_back( cubic );
		/* Otherwise end animation */
		} else {
			playbackPoses.push_back( pose0 );
			playbackPoses.push_back( pose1 );
			// clearLoadedAnimation();
			pose0 = playbackPoses.front();
			playbackPoses.pop_front();
			pose1 = playbackPoses.front();
			playbackPoses.pop_front();
			resetAnimation();
		}
	}
	
	/* change value of all the joints */
	for( int i = 0; i < NUM_JOINTS; i++ ) {
		jointAngles[i] = calcAngle( cubic, i );
	}
	
	display();
}

/* Taken from notes on keyframing, generates 
	a 'u' value between 0.0f and 1.0f */
float InvLerp( float t, float t0, float t1 ) {
	return ( t - t0 ) / ( t1 - t0 );
}

float calcAngle( float **cubic, int joint ) {
	float u = InvLerp( t, t0, t1 );
	float retval = 
		cubic[joint][0]*u*u*u + cubic[joint][1]*u*u + 
		cubic[joint][2]*u + cubic[joint][3];

	return retval;
}

bool loadAnimation() {
	string fname;
	cout << "Type name of animation file to load." << endl;
	cin  >> fname;
	ifstream animFile( fname.c_str() );
	list<GLfloat*> posesFromFile;
	GLfloat tn = 0.0f;
	GLfloat *cpose; // = new GLfloat[NUM_JOINTS];
	int numPoses;
	animFile >> numPoses;

	clearLoadedAnimation();

	for( int i = 0; i < numPoses; i++ ) {
		cpose = new GLfloat[NUM_JOINTS];
		animFile >> tn;
		poseTimes.push_back( tn );
		for( int i = 0; i < NUM_JOINTS; i++ ) {
			animFile >> cpose[i];
		}
		playbackPoses.push_back( cpose );
		posesFromFile.push_back( cpose );
	}

	t0 = poseTimes.front(); 
	poseTimes.pop_front();
	t1 = poseTimes.front(); 
	poseTimes.pop_front();

	// check for fail, empty everything
	if( animFile.fail() ) {
		printf("Failed to load animation \n");
		clearLoadedAnimation();
		return false;
	}

	pose1 = posesFromFile.front();
	posesFromFile.pop_front();

	// Generate all the cubics
	for( int i = 0; i < numPoses-1; i++ ) {
		pose0 = pose1;
		pose1 = posesFromFile.front();
		posesFromFile.pop_front();
		float **cubic;
		cubic = new float*[NUM_JOINTS];
		for( int j = 0; j < NUM_JOINTS; j++ ) {
			cubic[j] = new float[4];
			float pointsEtc[4];
			pointsEtc[0] = pose0[j];
			pointsEtc[1] = pose1[j];
			pointsEtc[2] = 0;
			pointsEtc[3] = 0;
			cubicCoeffs( cubic[j], pointsEtc );
		}
		cubics.push_back( cubic );
	}
	
	pose0 = playbackPoses.front();
	playbackPoses.pop_front();
	pose1 = playbackPoses.front();
	playbackPoses.pop_front();

	cubic = cubics.front();
	cubics.pop_front();
	cubics.push_back( cubic );

	resetAnimation();

	animationLoaded = ! animFile.fail();
	return animationLoaded;
}

void playAnimation() {
	if( animationLoaded ) {
		animationStart = clock();
		animationPlaying = true;
	} else {
		cout << "No animation is currently loaded. " << endl;
		animationPlaying = loadAnimation();
	}
}

void saveAnimation() {
	string fname;
	cout << "Type the name of a file to save the animation" << endl;
	cin  >> fname;
	ofstream file( fname.c_str(), ofstream::binary );
	int numIts = editPoses.size();

	if( editTimes.size() != editPoses.size() ) {
		printf("poses and timestamps unequal \n");
	}

	file << numIts << endl;

	for( int i = 0; i < numIts; i++ ) {
		file << editTimes.front() << endl;
		editTimes.pop_front();
		GLfloat *pose = editPoses.front();
		editPoses.pop_front();
		for( int j = 0; j < NUM_JOINTS; j++ ) {
			file << pose[j] << endl;
		}
	}
	file.close();
}

void addPoseToAnimation() {
	GLfloat *newPose = new float[NUM_JOINTS];
	for( int i = 0; i < NUM_JOINTS; i++ ) {
		newPose[i] = jointAngles[i];
	}
	editPoses.push_back( newPose );
	if( editTimes.size() == 0 ) {
		cout << "Setting time index of first frame to zero." << endl;
		editTimes.push_back( 0.0f );
	} else {
		float timeIndex;
		cout << "Enter a time index (float in seconds) " << endl;
		cin  >> timeIndex;
		editTimes.push_back( timeIndex );
	}
}

void resetAnimation() {
	remainingPlaybackPoses = playbackPoses.size();
	animationPlaying = false;
}

void clearLoadedAnimation() {
	while( poseTimes.size() < 0 ) {
		poseTimes.pop_front();
	}

	while( playbackPoses.size() < 0 ) {
		GLfloat *tmp = playbackPoses.front();
		playbackPoses.pop_front();
		delete[] tmp;
	}
	
	while( cubics.size() < 0 ) {
		GLfloat **tmp = cubics.front();
		cubics.pop_front();
		for( int i = 0; i < NUM_JOINTS; i++ ) {
			delete[] tmp[i];
		}
	}

	animationLoaded = false;
}
