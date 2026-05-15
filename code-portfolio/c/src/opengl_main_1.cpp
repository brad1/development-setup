#include <windows.h>
#include <list>
#include <stdio.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <glut.h>

#include "shape.h"

using std::list;

#define _DEBUG_

// a queue of all shapes to be rendered to screen
struct shapesList *queue;

list<struct vertex> vertexBuffer;

enum drawState {NONE, SELECTING, SELECTED, DRAGGING, DRAWING, 
	SCALING, PIVOT_SELECT, ROTATING };

drawState state = NONE;

int SCREEN_WIDTH = 540;
int SCREEN_HEIGHT = 540;

// coordinates for the selection box
int selectSrcX;
int selectSrcY;
int selectDstX;
int selectDstY;

// coordinates for a drag operation
int dragSrcX;
int dragSrcY;
int dragDstX;
int dragDstY;

// coordinates of te pivot point for rotate and scale
int pivotX;
int pivotY;

// calback functions
void myKeyboardCB(unsigned char key, int x, int y);
void myMouseCB(int button, int state, int x, int y);
void myMotionCB(int x, int y);
void reshapeCB( int width, int height );
void display();

// callback helpers
void mousePress(int, int);
void mouseRelease(int, int);
void startDragging(int x, int y);
void startSelecting(int x, int y);
void postVertex( int x, int y);

// converts mouse y coordinate to be consistent with the display
void mouseToScreen( int& );
void rightClickMenu(int);


// draw helpers
void drawTriangle();
void drawCircle();
void drawRectangle();
void drawPolygon();

void executeDrag();
void executeScale();
void executeRotate();

void constructBox( struct box *b );


// Main method sets up for openGL infinite loop
int main ( int argc, char **argv ) {
	glutInitDisplayMode ( GLUT_SINGLE | GLUT_RGB );
	glutInitWindowPosition( 100, 100 );
	glutInitWindowSize( SCREEN_WIDTH, SCREEN_HEIGHT );
	glutCreateWindow("Project 1");
	
	/* Set clearing color to black, render polys in wireframe,
	 * and set coordinate system bounds to 10.0 by 10.0 */
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	//glOrtho(0.0, 10.0 , 0.0, 10.0, -1.0, 1.0);
	glOrtho(0.0, SCREEN_WIDTH, 0.0, SCREEN_HEIGHT, -1.0, 1.0);

	glutKeyboardFunc( myKeyboardCB );
	glutMouseFunc( myMouseCB );
	glutMotionFunc(myMotionCB);
	glutReshapeFunc(reshapeCB);
	glutDisplayFunc(display);

	// Setup right click menu
	glutCreateMenu(rightClickMenu);
	glutAddMenuEntry("Select points for a shape", 1);
	glutAddMenuEntry("Cancel current action", 2);
	glutAddMenuEntry("Draw circle", 3);
	glutAddMenuEntry("Draw rectangle", 4);	
	glutAddMenuEntry("Draw triangle", 5);
	glutAddMenuEntry("Draw polygon", 6);
	glutAddMenuEntry("Scale figure", 7);
	glutAddMenuEntry("Rotate figure", 9);
	glutAddMenuEntry("Move pivot (scale/rotate)", 8);
	glutAttachMenu(GLUT_RIGHT_BUTTON);

	queue = newshapesList();
	pivotX = 0;
	pivotY = 0;

	glutMainLoop();
	return 0;
}

void myKeyboardCB(unsigned char key, int x, int y) {
	printf("%c\n", key );
	return;
}

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

void myMotionCB(int x, int y) {
	if( state == SELECTING ) {
		display();
		mouseToScreen( y );

		glColor3f (0.0f, 1.0f, 0.0f);
	
		glBegin( GL_POLYGON );
			glVertex3f( selectSrcX, selectSrcY, 0.0f );
			glVertex3f( selectSrcX, y, 0.0f );
			glVertex3f( x, y, 0.0f );
			glVertex3f( x, selectSrcY, 0.0f );
		glEnd();

		glFlush();
	}
}

void display() {	
	/* clear screen */
    glClear (GL_COLOR_BUFFER_BIT);
	glColor3f (1.0f, 1.0f, 1.0f);
	displayAll( queue );

	// for each vertex:
	//  is it within the selection rectangle?
	//  if so, draw a small circle around it.
	//  maybe add it to an array of vertices to move?


    glFlush ();
	// ADD DOUBLE BUFFERING
	return;
}

void mousePress( int x, int y ) {
	mouseToScreen(y);

	switch( state ) {
		case SELECTED :
			startDragging(x,y);
			break;
		case NONE :
			startSelecting(x,y);
			break;
		case DRAWING :
			postVertex(x,y);
			break;
		case SCALING :
			dragSrcX = x;
			dragSrcY = y;
			break;
		case PIVOT_SELECT :
			display();
			pivotX = x;
			pivotY = y;
			glColor3f (0.0f, 0.0f, 1.0f);
			glPointSize(5.0);
			glBegin( GL_POINTS );
				glVertex3f( x, y, 0.0f);
			glEnd();
			glFlush();
			break;
		case ROTATING :
			dragSrcX = x;
			dragSrcY = y;
			break;
	}
}

void mouseRelease( int x, int y ) {
	mouseToScreen(y);

	if( state == SELECTING  ) {		
		#ifdef _DEBUG_
		printf( "Done selecting area\n" );
		#endif
		state = SELECTED;
		
		selectDstX = x;
		selectDstY = y;

		struct box b;
		constructBox(&b);

		highlight( queue, &b );
	}

	if( state == DRAGGING ) {
		#ifdef _DEBUG_
		printf( "Done dragging vertices\n" );
		#endif
		state = NONE;
		dragDstX = x;
		dragDstY = y;
		executeDrag();
	}

	if( state == SCALING ) {
		#ifdef _DEBUG_
		printf( "Scaling figure now\n" );
		#endif
		state = NONE;
		dragDstX = x;
		dragDstY = y;
		executeScale();
	}

	if( state == ROTATING ) {
		#ifdef _DEBUG_
		printf( "Rotating figure now\n" );
		#endif
		state = NONE;
		dragDstX = x;
		dragDstY = y;
		executeRotate();
	}

	if( state == PIVOT_SELECT ) {
#ifdef _DEBUG_
		printf( "Pivot placed \n" );
#endif
		state = NONE;
	}
}           

void reshapeCB( int width, int height ) {
	SCREEN_WIDTH = width;
	SCREEN_HEIGHT = height;
}

void rightClickMenu(int i) {
	switch(i) {
	case 1 :
		state = DRAWING;
		break;
	case 2:
		#ifdef _DEBUG_
		printf( "Action canceled\n" );
		display();
		#endif
		vertexBuffer.clear();
		state = NONE;
		break;
	case 3:
		drawCircle();
		break;
	case 4:
		drawRectangle();
		break;
	case 5:
		drawTriangle();
		break;
	case 6:
		drawPolygon();
		break;
	case 7:
		state = SCALING;
		break;
	case 8:
		state = PIVOT_SELECT;
		break;
	case 9 :
		state = ROTATING;
		break;
	}
}

void mouseToScreen( int& y) {
	y = SCREEN_HEIGHT - y;
}

void postVertex( int x, int y) {

	glColor3f (1.0, 0.0, 0.0);
	glPointSize(5.0);
	glBegin( GL_POINTS );
	glVertex3f( x, y, 0.0f);
	glEnd();
	glFlush();	

	struct vertex v;
	v.coords[0] = x;
	v.coords[1] = y;
	v.coords[2] = 0;
	vertexBuffer.push_back(v);

#ifdef _DEBUG_
	int sz = vertexBuffer.size();
	printf( "Posting vertex, %d entries in buffer \n", sz );
#endif	
}

void startDragging( int x, int y ) {
#ifdef _DEBUG_
	printf( "Dragging vertices\n" );
#endif		
	state = DRAGGING;
	dragSrcX = x;
	dragSrcY = y;
}

void startSelecting( int x, int y ) {
#ifdef _DEBUG_
	printf( "Selecting area\n" );
#endif
	state = SELECTING;
	selectSrcX = x;
	selectSrcY = y;
}

void drawTriangle() {
	if( vertexBuffer.size() != 3 ) {
		#ifdef _DEBUG_
		printf("ERROR: need exactly 3 vertices \n");
		#endif
		return;
	}
	
	struct vertex verts[3];
	for( int i = 0; i < 3; i++ ) {
		verts[i] = vertexBuffer.front();
		vertexBuffer.pop_front();
	}

	enqueueTriangle( queue, verts );
	display();
	state = NONE;
}

void drawRectangle() {	
	if( vertexBuffer.size() != 2 ) {
		#ifdef _DEBUG_
		printf("ERROR: need exactly 2 vertices (Rectangle)\n");
		#endif	
		return;
	}

	struct vertex verts[2];
	for( int i = 0; i < 2; i++ ) {
		verts[i] = vertexBuffer.front();
		vertexBuffer.pop_front();
	}

	enqueueRectangle( queue, verts[0], verts[1] );
	display();
	state = NONE;
}


void drawCircle() {
	if( vertexBuffer.size() != 2 ) {
		#ifdef _DEBUG_
		printf("ERROR: need exactly 2 vertices (Circle)\n");
		#endif
		return;
	}
	
	struct vertex verts[2];
	for( int i = 0; i < 2; i++ ) {
		verts[i] = vertexBuffer.front();
		vertexBuffer.pop_front();
	}

	enqueueCircle( queue, verts[0], verts[1] );
	display();
	state = NONE;
}

void drawPolygon() {
	int sz = vertexBuffer.size();
	if( sz < 3  ) {
		#ifdef _DEBUG_
		printf("ERROR: need more vertices \n");
		#endif
		return;
	}

	struct vertex *verts = (struct vertex*) malloc( sz*sizeof( struct vertex ) );
	for( int i = 0; i < sz; i++ ) {
		verts[i] = vertexBuffer.front();
		vertexBuffer.pop_front();
	}

	enqueuePolygon( queue, verts, sz );
	display();
	state = NONE;
}

void swap( int& a, int& b ) {
	int temp = a;
	a = b;
	b = temp;
}

void executeDrag() {
#ifdef _DEBUG_
	printf("	Redrawing vertices \n");
#endif	

	struct box b;
	constructBox( &b );

	int dx = dragDstX - dragSrcX;
	int dy = dragDstY - dragSrcY;

	glClear (GL_COLOR_BUFFER_BIT);
	glColor3f (1.0f, 1.0f, 1.0f);
	displayWithDrag( queue, &b, dx, dy );
	glFlush();
}

void executeScale() {
#ifdef _DEBUG_
	printf("	Rescaling figure \n");
#endif	

	struct box b;
	constructBox( &b );

	float dx = (float) dragDstX - dragSrcX;
	float dy = (float) dragDstY - dragSrcY;

	glClear (GL_COLOR_BUFFER_BIT);
	glColor3f (1.0f, 1.0f, 1.0f);
	displayWithScale( queue, &b, dx, dy, pivotX, pivotY );
	glFlush();
}

void executeRotate() {
#ifdef _DEBUG_
	printf("	Rotating figure \n");
#endif	

	struct box b;
	constructBox( &b );

	float dx = (float) dragDstX - dragSrcX;
	float dy = (float) dragDstY - dragSrcY;

	glClear (GL_COLOR_BUFFER_BIT);
	glColor3f (1.0f, 1.0f, 1.0f);
	displayWithRotate( queue, &b, dx, dy, pivotX, pivotY );
	glFlush();
}

void constructBox( struct box *b ) {
	b->x1 = selectSrcX;
	b->x2 = selectDstX;
	b->y1 = selectSrcY;
	b->y2 = selectDstY;

	if( b->x2 < b->x1 ) {
		swap( b->x1, b->x2 );
	}

	if( b->y2 < b->y1 ) {
		swap( b->y1, b->y2 );
	}
}
