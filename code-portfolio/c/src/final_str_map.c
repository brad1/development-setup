#include"stdlib.h"
#include"base_type.h"
#include"final_str_map.h"

int compareTo(char *c1, char *c2);

struct bnode {
    struct base_type *data;
    char *key;
    struct bnode *left;
    struct bnode *right;
};

struct final_str_map {
    struct bnode *root;
    struct bnode *flyweight;
    int size;
    int depth;
    int insert_count;
    int duplicate_insertion;
    long int access_count;
};

struct final_str_map *new_final_str_map() {
    struct final_str_map *retval = (struct final_str_map*) _new( "final_str_map", "persistent", sizeof(struct final_str_map));
    retval->flyweight = (struct bnode *) _new("bnode", "persistent", sizeof(struct bnode)); 
    retval->root = NULL;
    retval->size = 0;
    retval->depth = 0;
    retval->insert_count = 0;
    retval->access_count = 0;
    retval->duplicate_insertion = 0;
    base_type_setInvalid( (struct base_type *) retval->flyweight);
    return retval;
}

void insert( struct final_str_map *b, struct bnode *node, void *data, char *key) {
    int repeat = 1;
    while(repeat) {  
        repeat = 0; 
        struct bnode **maybe_allocate = &(b->flyweight);
        if( compareTo(key, node->key) < 0) {
            maybe_allocate = &node->left;
        } else if( compareTo(key, node->key ) > 0) {
            maybe_allocate = &node->right;
        } 
    
        if( *maybe_allocate == NULL ) {
            *maybe_allocate = (struct bnode*) _new("bnode", "persistent", sizeof(struct bnode));
            (*maybe_allocate)->key = key;
            (*maybe_allocate)->data = data;
            (*maybe_allocate)->right = b->flyweight;
            (*maybe_allocate)->left  = b->flyweight;
        } else if( *maybe_allocate == b->flyweight ) {
            b->duplicate_insertion++;
        } else {
            node = *maybe_allocate;
            repeat = 1;
        }
    }
}

void final_str_map_insert( struct final_str_map *b, struct base_type *data, char *key) {
    if( b->root == NULL ) {
        b->root = (struct bnode*) _new("bnode", "persistent", sizeof(struct bnode)); 
        b->root->key = key;
        b->root->data = data;
    } else {
        insert( b, b->root, data, key );
    }
}

int compareTo(char *c1, char *c2) {
    int i = 0;
   while(c1[i] != '\n' && c2[i] != '\n' ) {
       if(c1[i] != c2[i]) {
           return c1[i] - c2[i];
       }
       i++;
   }
   if(c1[i] == c2[i]) {
       return 0;
   } else if(c1[i] == '\n') {
       return 1;
   } else {
       return -1;
   }
}

struct base_type *final_str_map_get(struct final_str_map *b, char *key) {
    if(b->root == NULL ) {
        return NULL;
    }
    int repeat = 1;
    struct bnode *curr = b->root;
    while(repeat) {  
        repeat = 0; 
        if( compareTo(key, curr->key) < 0) {
            curr = curr->left;
            repeat = 1;
        } else if( compareTo(key, curr->key ) > 0) {
            curr = curr->right;
            repeat = 1;
        } 
    
        if( curr == b->flyweight ) {
            repeat = 0; 
        }
    }
    return curr->data;
}
        

