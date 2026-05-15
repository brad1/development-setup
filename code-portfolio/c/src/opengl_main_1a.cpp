#include <windows.h>
#include <list>
#include <stdio.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

const int SCREEN_WIDTH = 540;
const int SCREEN_HEIGHT = 540;

void myKeyboardCB(unsigned char key, int x, int y);
void myMouseCB(int button, int state, int x, int y);
void myMotionCB(int x, int y);
void display();

int main ( int argc, char **argv ) {
	glutInitDisplayMode ( GLUT_SINGLE | GLUT_RGB );
	glutInitWindowPosition( 100, 100 );
	glutInitWindowSize( SCREEN_WIDTH, SCREEN_HEIGHT );
	glutCreateWindow("Assignment 1");
	
	/* Set clearing color to black, render polys in wireframe,
	 * and set coordinate system bounds to 10.0 by 10.0 */
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glOrtho(0.0, 10.0 , 0.0, 10.0, -1.0, 1.0);

	glutKeyboardFunc( myKeyboardCB );
	glutMouseFunc( myMouseCB );
//	glutMotionFunc(myMotionCB);
	glutDisplayFunc(display);

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
				printf("Press\n");
				break;
			case 1 :
				printf("Release\n");
				break;
		}
	}

	return;
}

void myMotionCB(int x, int y) {
	return;
}

/**
* Redraw the screen
*/
void display() {	
	/* clear screen */
    glClear (GL_COLOR_BUFFER_BIT);

    glColor3f (1.0, 1.0, 1.0);
	glPointSize(5.0);

	/* Draw two white points */
	glBegin(GL_POINTS);
        glVertex3f(0.5, 0.5, 0.0);
        glVertex3f(0.2, 0.5, 0.0);
    glEnd();

	glColor3f (1.0, 0.0, 0.0);

	/* Draw a red triangle above te points */
	glBegin( GL_TRIANGLES );        
		glVertex3f(0.5, 1.0, 0.0);
		glVertex3f(0.2, 1.0, 0.0);
		glVertex3f(0.5, 2.0, 0.0);
	glEnd();

	/* Draw a red triangle strip above the triangle */
	glBegin( GL_TRIANGLE_STRIP );
		glVertex3f(0.2, 2.5, 0.0);
		glVertex3f(0.2, 3.5, 0.0);	
		glVertex3f(0.5, 2.5, 0.0);		
		glVertex3f(0.5, 3.5, 0.0);		
		glVertex3f(0.7, 2.5, 0.0);
		glVertex3f(0.8, 3.5, 0.0);
	glEnd();

	/* Draw a red triangle fan above the strip */
	glBegin( GL_TRIANGLE_FAN );        
		glVertex3f(0.2, 3.8, 0.0);
		glVertex3f(0.2, 4.8, 0.0);	
		glVertex3f(0.3, 4.8, 0.0);		
		glVertex3f(0.45, 4.75, 0.0);		
		glVertex3f(0.54, 4.64, 0.0);
		glVertex3f(0.63, 4.53, 0.0);
	glEnd();

	glColor3f (0.0, 0.0, 1.0);

	/* Draw a blue quadrilateral above the fan */
	glBegin(GL_QUADS);
        glVertex3f(0.2,  5.0, 0.0);
        glVertex3f(0.6, 5.0, 0.0);
		glVertex3f(0.6, 5.2, 0.0);
		glVertex3f(0.2,  5.2, 0.0);
    glEnd();

	/* Draw a blue quad strip above the quad */
	glBegin(GL_QUAD_STRIP);
        glVertex3f(0.2,  5.7, 0.0);
        glVertex3f(0.6, 5.7, 0.0);
		glVertex3f(0.2,  5.9, 0.0);
		glVertex3f(0.6, 5.9, 0.0);
		glVertex3f(0.1, 6.1, 0.0);
		glVertex3f(0.7, 6.1, 0.0);
		glVertex3f(0.2, 6.2, 0.0);
		glVertex3f(0.6, 6.2, 0.0);
    glEnd();

	glColor3f (1.0, 1.0, 0.0);

	/* Draw a yellow star above the quad strip */
    glBegin( GL_LINE_LOOP );
        glVertex3f(0.2, 6.4, 0.0);
        glVertex3f(0.9, 7.2, 0.0);
		glVertex3f(1.6, 6.4, 0.0);
        glVertex3f(0.3, 6.9, 0.0);
		glVertex3f(1.5, 6.9, 0.0);
    glEnd();

	/* Draw a yellow trapezoid above the star */
	glBegin( GL_POLYGON );
        glVertex3f(0.2, 7.4, 0.0);
        glVertex3f(0.3, 7.9, 0.0);
		glVertex3f(0.9, 8.2, 0.0);
		glVertex3f(1.5, 7.9, 0.0);
		glVertex3f(1.6, 7.4, 0.0);
    glEnd();

	glColor3f (1.0, 0.5, 0.0);

	/* Draw thick orange lines at the bottom of the screen */
	glLineWidth(3.0);
	glBegin( GL_LINES );
        glVertex3f(2.2, 0.4, 0.0);
        glVertex3f(2.3, 0.9, 0.0);
		glVertex3f(2.9, 1.2, 0.0);
		glVertex3f(3.5, 0.9, 0.0);
		glVertex3f(3.6, 0.4, 0.0);
    glEnd();
	glLineWidth(1.0);

	/* Draw an open trapezoid beside the lines */
	glBegin( GL_LINE_STRIP );
        glVertex3f(4.2, 0.4, 0.0);
        glVertex3f(4.3, 0.9, 0.0);
		glVertex3f(4.9, 1.2, 0.0);
		glVertex3f(5.5, 0.9, 0.0);
		glVertex3f(5.6, 0.4, 0.0);
    glEnd();

	/* Begin drawing an uppercase 'B' */
	glColor3f (0.0, 1.0, 0.0);

	/* Bottom half */
	glBegin(GL_TRIANGLE_FAN);
        glVertex3f(5.0, 4.5, 0.0);
        glVertex3f(5.0, 3.5, 0.0);
		glVertex3f(7.0, 3.5, 0.0);
		glVertex3f(7.4, 4.0, 0.0);
		glVertex3f(7.5, 4.5, 0.0);
		glVertex3f(7.4, 5.0, 0.0);
		glVertex3f(6.5, 5.5, 0.0);
		glVertex3f(5.0, 5.5, 0.0);
    glEnd();

	/* Lower half */
	glBegin(GL_TRIANGLE_FAN);
		glVertex3f(5.0, 6.0, 0.0);
		glVertex3f(5.0, 5.5, 0.0);
		glVertex3f(6.2, 5.6, 0.0);
		glVertex3f(6.5, 6.0, 0.0);
		glVertex3f(6.2, 6.4, 0.0);
		glVertex3f(5.0, 6.5, 0.0);
    glEnd();


    glFlush ();
	return;
}