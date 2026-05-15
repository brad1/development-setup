#include"stdlib.h"
#include"base_type.h"
#include"type_allocator.h"
#include"system.h"

// Status masks:
#define __OBJECT_IS_VALID 0x00000001
#define __OBJECT_IS_DEFST 0x00000002
#define __OBJECT_IS_LOCKD 0x00000004

struct base_type {
    int type_id;
    int parent_type_id;
    int status_bits;
};

void *_new( char * type_name, char * alloc_type, int size ) {
    return base_get_subtype(base_new(type_name, alloc_type, size));
} 

struct base_type *base_new(char *type, char *alloc_type, int size) {
    struct base_type *retval = NULL;
    if(alloc_type == "persistent") {
        retval = (struct base_type *) pmalloc(size + sizeof(struct base_type));
    } 
    if(retval != NULL) {
        retval->type_id = getTypeIdFromString(type);
        retval->status_bits = 0;
    } else {
        systemLog("unknown allocator type requested");
        systemStop();
    }
    return retval;   
}

int base_type_id(struct base_type *bt) {
    return bt->type_id;
}

int isValid(void *obj) {
    obj -= sizeof(struct base_type);
    struct base_type *base = (struct base_type *) obj;
    return __OBJECT_IS_VALID & base->status_bits;
}

int isDefinedState(void *obj) {
    struct base_type *base = (struct base_type *) 
        (obj - sizeof(struct base_type));
    return __OBJECT_IS_DEFST & base->status_bits;
}

int isLocked(void *obj) {
    struct base_type *base = (struct base_type *) 
        (obj - sizeof(struct base_type));
    return __OBJECT_IS_LOCKD & base->status_bits;
}

void base_type_setInvalid(void *obj) {
    obj -= sizeof(struct base_type);
    struct base_type *base = (struct base_type *) obj;
    base->status_bits &= ~(__OBJECT_IS_VALID );
}

void *base_get_subtype(struct base_type *bt) {
    return (void *) (bt + sizeof(struct base_type));
}
    
