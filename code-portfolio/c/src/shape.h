struct vertex {
	float coords[3];
};

struct box {
	int x1;
	int y1;
	int x2;
	int y2;
};

struct shapesList;

struct shapesList *newshapesList(void);

// add one of the specified shapes to the draw queue
void enqueueTriangle( struct shapesList *, struct vertex *verts);
void enqueuePolygon( struct shapesList *, struct vertex *vertices, int numVertices );
void enqueueCircle( struct shapesList *, struct vertex v0, struct vertex v1);
void enqueueRectangle( struct shapesList *, struct vertex v0, struct vertex v1);

// have the queue display all shapes it contains
void displayAll( struct shapesList * );

// processes every shape, if vertex inside the hitbox applies the 
// specified transformation
void displayWithDrag( struct shapesList *, struct box *, int, int );

void displayWithScale( struct shapesList *, struct box *, 
					  float, float, float, float );

void displayWithRotate( struct shapesList *, struct box *, 
					   float, float, float, float );

// highlights the vertices within the hitbox
void highlight( struct shapesList *, struct box* );
