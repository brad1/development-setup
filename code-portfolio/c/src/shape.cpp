#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <glut.h>
#include <math.h>
#include <stdio.h>

#include "shape.h"

// draw a shape on the screen
void displayShape( struct shape *);

// helpers for displayShape
void drawCircle( struct shape *);
void drawRectangle( struct shape *);
void drawPolygon( struct shape *);
void drawTriangle( struct shape *);

// constructors for new shapes
struct shape *newPolygon( struct vertex *, int );
struct shape *newCircle( struct vertex, struct vertex );
struct shape *newTriangle( struct vertex *);
struct shape *newRectangle( struct vertex, struct vertex);

// helper code for the public enqueueing calls
void enqueue( struct shapesList *, struct shape * );

// helper for the highlighting function
void checkVertices( struct shape *current, struct box *b);

// code that performs transformations on hitboxed vertices/shapes
void updatePosition( struct shape *current, struct box *b, int dx, int dy );
void updateScale( struct shape *current, struct box *b, float dx, float dy, float px, float py );
void updateRotate( struct shape *current, struct box *b, float dx, float dy, float px, float py );

enum shapeType {CIRCLE, RECTANGLE, POLY, TRI};

struct shape {
	shapeType type;
	int numVertices;
	struct vertex *verts;
	struct shape *nextInLine;
};

struct shapesList {
	struct shape *firstInLine;
	struct shape *lastInLine;
};

struct shapesList *newshapesList() {
	struct shapesList *retval = 
		(struct shapesList *) malloc( sizeof( struct shapesList ) );
	retval->firstInLine = NULL;
	retval->lastInLine = NULL;
	return retval;
}

void displayShape( struct shape *s ) {
	
	switch( s->type ) {
		case CIRCLE :
			drawCircle( s );
			break;
		case RECTANGLE :
			drawRectangle( s );
			break;
		case POLY :
			drawPolygon( s );
			break;
		case TRI :
			drawTriangle( s );
			break;
	}
}

void enqueueTriangle( struct shapesList *sl, struct vertex *verts) {
	struct shape *toEnqueue = newTriangle( verts );
	enqueue( sl, toEnqueue );
}

void enqueuePolygon( struct shapesList *sl, struct vertex *verts, int numVertices ) {
	struct shape *toEnqueue = newPolygon( verts, numVertices );
	enqueue( sl, toEnqueue );
}

void enqueueCircle( struct shapesList *sl, struct vertex v0, struct vertex v1) {
	struct shape *toEnqueue = newCircle( v0, v1 );
	enqueue( sl, toEnqueue );
}

void enqueueRectangle( struct shapesList *sl, struct vertex v0, struct vertex v1) {
	struct shape *toEnqueue = newRectangle( v0, v1 );
	enqueue( sl, toEnqueue );
}

struct shape *newTriangle( struct vertex *verts) {
	struct shape *retval = (struct shape *) malloc( sizeof( struct shape ) );
	retval->numVertices = 3;
	retval->type = TRI;
	retval->verts = (struct vertex *) malloc( 3 * sizeof( struct vertex ) );
	retval->verts[0] = verts[0];
	retval->verts[1] = verts[1];
	retval->verts[2] = verts[2];
	retval->nextInLine = NULL;
	return retval;
}

struct shape *newPolygon( struct vertex *verts, int numVertices ) {
	struct shape *retval = (struct shape *) malloc( sizeof( struct shape ) );
	retval->numVertices = numVertices;
	retval->type = POLY;
	retval->verts = (struct vertex *) malloc( numVertices * sizeof( struct vertex ) );
	for( int i = 0; i < numVertices; i++ ) {
		retval->verts[i] = verts[i];	
	}
	retval->nextInLine = NULL;
	return retval;
}

struct shape *newCircle( struct vertex v0, struct vertex v1) {
	struct shape *retval = (struct shape *) malloc( sizeof( struct shape ) );
	retval->numVertices = 2;
	retval->type = CIRCLE;
	retval->verts = (struct vertex *) malloc( 2 * sizeof( struct vertex ) );
	retval->verts[0] = v0;	
	retval->verts[1] = v1;
	retval->nextInLine = NULL;
	return retval;
}

struct shape *newRectangle( struct vertex v0, struct vertex v2) {
	struct shape *retval = (struct shape *) malloc( sizeof( struct shape ) );
	retval->numVertices = 4;
	retval->type = RECTANGLE;
	retval->verts = (struct vertex *) malloc( 4 * sizeof( struct vertex ) );
	retval->verts[0] = v0;	
	retval->verts[1].coords[0] = v0.coords[0];
	retval->verts[1].coords[1] = v2.coords[1];
	retval->verts[1].coords[2] = 0.0f;
	retval->verts[2] = v2;	
	retval->verts[3].coords[0] = v2.coords[0];
	retval->verts[3].coords[1] = v0.coords[1];
	retval->verts[3].coords[2] = 0.0f;
	retval->nextInLine = NULL;
	return retval;
}



void drawCircle( struct shape *s ) {
	float x1, y1, x2, y2;
	x1 = s->verts[0].coords[0];
	y1 = s->verts[0].coords[1];
	x2 = s->verts[1].coords[0];
	y2 = s->verts[1].coords[1];
	float dx = x2-x1;
	float dy = y2-y1;
	float radius = sqrt( dx*dx + dy*dy );

	/* Code taken from the project spec */
	float vectorY1 = y1+radius;
	float vectorX1 = x1;
	glBegin(GL_LINE_STRIP);
	for( float angle = 0; angle <= (2.0f * 3.14159); angle += 0.01f ) {
		glVertex2d( vectorX1, vectorY1 );
		vectorX1 = x1 + (radius *(float)sin((double)angle));
		vectorY1 = y1 + (radius *(float)cos((double)angle));
	}
	glEnd();
	/*----------------------------------*/

}


void drawRectangle( struct shape *s) {
	struct vertex v0 = s->verts[0];
	struct vertex v1 = s->verts[1];
	struct vertex v2 = s->verts[2];
	struct vertex v3 = s->verts[3];
	
	glBegin( GL_QUADS );
		glVertex3f( v0.coords[0], v0.coords[1], v0.coords[2] );
		glVertex3f( v1.coords[0], v1.coords[1], v1.coords[2] );
		glVertex3f( v2.coords[0], v2.coords[1], v2.coords[2] );
		glVertex3f( v3.coords[0], v3.coords[1], v3.coords[2] );
	glEnd();
}

void drawPolygon( struct shape *s ) {
glBegin( GL_POLYGON );
	for( int i = 0; i < s->numVertices; i++ ) {
		float *coords = s->verts[i].coords;
		glVertex3f( coords[0], coords[1], coords[2] );
	}
glEnd();
}

void drawTriangle( struct shape *s ) {
	struct vertex *verts = s->verts;

	float *coord_0 = verts[0].coords;
	float *coord_1 = verts[1].coords;
	float *coord_2 = verts[2].coords;

	glBegin( GL_TRIANGLES );        
		glVertex3f(coord_0[0], coord_0[1], coord_0[2]);
		glVertex3f(coord_1[0], coord_1[1], coord_1[2]);
		glVertex3f(coord_2[0], coord_2[1], coord_2[2]);
	glEnd();
}

void displayAll( struct shapesList *queue) {
	struct shape *current = queue->firstInLine;
	while( current != NULL ) {
		displayShape( current );
		current = current->nextInLine;
	}
}

void displayWithDrag( struct shapesList *queue, struct box *b, int dx, int dy ) {	
	struct shape *current = queue->firstInLine;
	while( current != NULL ) {
		updatePosition( current, b, dx, dy );
		displayShape( current );
		current = current->nextInLine;
	}
}

void displayWithScale( struct shapesList *queue, struct box *b, float dx, float dy, float px, float py ) {
	struct shape *current = queue->firstInLine;
	while( current != NULL ) {
		updateScale( current, b, dx, dy, px, py );
		displayShape( current );
		current = current->nextInLine;
	}
}

void displayWithRotate( struct shapesList *queue, struct box *b, float dx, float dy, float px, float py ) {
	struct shape *current = queue->firstInLine;
	while( current != NULL ) {
		updateRotate( current, b, dx, dy, px, py );
		displayShape( current );
		current = current->nextInLine;
	}
}

void highlight( struct shapesList *sl, struct box* b ) {
	struct shape *current = sl->firstInLine;
	while( current != NULL ) {
		checkVertices( current, b);
		current = current->nextInLine;
	}
	glFlush();
}

void enqueue( struct shapesList *sl, struct shape *s ) {
	if( sl->firstInLine == NULL ) {
		sl->firstInLine = s;
		sl->lastInLine = s;
	} else {
		sl->lastInLine->nextInLine = s;
		sl->lastInLine = s;
	}
}

void updatePosition( struct shape *current, struct box *b, int dx, int dy ) {
	int sz = current->numVertices;

	if( current->type == CIRCLE ) { // Unique case, analyze center only....
		sz = 1;
	}

	int left = b->x1;
	int right = b->x2;
	int up = b->y2;
	int down = b->y1;

	for( int i = 0; i < sz; i++ ) {
		int x = current->verts[i].coords[0];
		int y = current->verts[i].coords[1];

		if( left < x && x < right ) {
			if( down < y && y < up ) {
				current->verts[i].coords[0] += dx;
				current->verts[i].coords[1] += dy;

				if( current->type == CIRCLE ) { // but translate both vertices
					current->verts[1].coords[0] += dx;
					current->verts[1].coords[1] += dy;
				}
			}
		}
	}
}

void updateScale( struct shape *current, struct box *b, float dx, float dy, float px, float py ) {
	int left  = b->x1;
	int right = b->x2;
	int up    = b->y2;
	int down  = b->y1;

	int x = current->verts[0].coords[0];
	int y = current->verts[0].coords[1];

	if( left < x && x < right ) {
		if( down < y && y < up ) {
			int sz = current->numVertices;

			for( int i = 0; i < sz; i++ ) {
				float x = current->verts[i].coords[0];
				float y = current->verts[i].coords[1];
				
				// distance from pivot
				float distX = x - px;
				float distY = y - py;

				// move vertices closer to or further from pivot
				float distXscaled = distX + distX * dx/40.0;
				float distYscaled = distY + distY * dy/40.0;

				current->verts[i].coords[0] -= distX;
				current->verts[i].coords[1] -= distY;
				
				current->verts[i].coords[0] += distXscaled;
				current->verts[i].coords[1] += distYscaled;

			}
		}
	}


}

void updateRotate( struct shape *current, struct box *b, float dx, float dy, float px, float py ) {
	int tmp = (int)dx % 360;
	float angle = (float) tmp;
	angle /= 360;
	angle *= 3.141592;

	int left  = b->x1;
	int right = b->x2;
	int up    = b->y2;
	int down  = b->y1;

	int x = current->verts[0].coords[0];
	int y = current->verts[0].coords[1];

	if( left < x && x < right ) {
		if( down < y && y < up ) {
			int sz = current->numVertices;

			for( int i = 0; i < sz; i++ ) {
				float x = current->verts[i].coords[0];
				float y = current->verts[i].coords[1];
				
				// distance from pivot
				float distX = x - px;
				float distY = y - py;

				// distance from pivot after rotate
				float distXrot = distX*cos(angle) - distY*sin(angle);
				float distYrot = distX*sin(angle) + distY*cos(angle);

				// update point
				current->verts[i].coords[0] = px + distXrot;
				current->verts[i].coords[1] = py + distYrot;
			}
		}
	}

	
}

void checkVertices( struct shape *current, struct box *b) {
	int sz = current->numVertices;

	if( current->type == CIRCLE ) { // Unique case, analyze center only....
		sz = 1;
	}

	int left  = b->x1;
	int right = b->x2;
	int up    = b->y2;
	int down  = b->y1;

	for( int i = 0; i < sz; i++ ) {
		int x = current->verts[i].coords[0];
		int y = current->verts[i].coords[1];

		if( left < x && x < right ) {
			if( down < y && y < up ) {
				glColor3f (1.0, 0.0, 0.0);
				glPointSize(5.0);
				glBegin( GL_POINTS );
					glVertex3f( x, y, 0.0f);
				glEnd();
			}
		}
	}
}
