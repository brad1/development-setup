#ifndef __BASE_TYPE_H__
#define __BASE_TYPE_H__

struct base_type; 

int isValid(void *);
int isDefinedState(void *);
int isLocked(void *);
char* getType(void *);

void base_type_setInvalid(void *obj);

void *_new( char * type_name, char * alloc_type, int size );
struct base_type *base_new( char * type_name, char * alloc_type, int size );

void *base_get_subtype(struct base_type *);

  
#endif
