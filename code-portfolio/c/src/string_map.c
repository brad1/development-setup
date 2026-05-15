#include"string_map.h"
#include<stdlib.h>
#include<stdio.h>

#define __DEBUG__
FILE * file;

char strComp(char *lhs, char *rhs) {
    int i = 0;
    while(rhs[i] == lhs[i] && lhs[i] != '\n' && rhs[i] != '\n') {
        i++;
    }
    return lhs[i] - rhs[i];
}

struct bnode {
    void *data;
    char *key;
    struct bnode *left;
    struct bnode *right;
};

struct string_map {
    struct bnode *flyweight;
    int size;
    int depth;
    int insert_count;
    int delete_count;
    long int access_count;
};

struct string_map *new_string_map() {
    file = fopen("log", "w");
    fclose(file);
    file = fopen("log", "a+");
    struct string_map * retval = (struct string_map *) malloc(sizeof(struct string_map)); 
    retval->flyweight = (struct bnode *) malloc(sizeof(struct bnode)); 
    retval->flyweight->right = NULL;
    retval->flyweight->left  = NULL;
    retval->flyweight->key = "";
    retval->size = 0;
    retval->depth = 0;
    retval->insert_count = 0;
    retval->delete_count = 0;
    retval->access_count = 0;
    return retval;
}

void free_string_map(struct string_map *b ) {
    fclose(file);
    free(b);
}

struct bnode *new_bnode(void *data, char *key) {
    struct bnode *retval = malloc(sizeof(struct bnode));
    retval->right = NULL;
    retval->left  = NULL;
    retval->key   = key;
    retval->data  = data;
}

struct bnode **getNextNode(struct bnode *parent, char * key) {
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "searching down one level\n");
    fclose(file);
    #endif
    if(strComp(key, parent->key) < 0) {
        return &(parent->left);
    } else if ( 0 < strComp(key, parent->key)) {
        return &(parent->right);
    } else {
        exit(0);
    }
}
    
struct bnode **string_map_node_search( struct string_map *tree, char *key) {
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "searching for a node\n");
    fclose(file);
    #endif
    struct bnode **current = getNextNode(tree->flyweight, key);
    while(1) { 
        if( current == NULL ) {
            return NULL;
        } else if( *current == NULL ) {  
            return NULL;
        } else if( strComp(key, (**current).key) < 0 ) {
            current = &((**current).left);
        } else if( 0 < strComp( key, ((**current).key)) ) {
            current = &((**current).right);
        } else {
            #ifdef __DEBUG__
            file = fopen("log", "a+");
            fprintf(file, "entry found\n");
            fclose(file);
            #endif
            tree->access_count++;
	        return current;
        }
    }
}

void *string_map_search( struct string_map *tree, char *key) {
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "string_map_search\n");
    fclose(file);
    #endif
    struct bnode **b = string_map_node_search(tree,key);
    if( b == NULL) return NULL;
    if(*b == NULL) return NULL;
    return (**b).data;
}

void string_map_insert( struct string_map *tree, void *data, char *key) {
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "inserting\n");
    fclose(file);
    #endif
    struct bnode **node = getNextNode(tree->flyweight, key); 
    char repeat = 1;
    while(repeat) {
        if(*node == NULL) {
            *node = new_bnode(data, key); 
            repeat = 0;
        } else {
            node = getNextNode(*node, key);
        }
    }
}

void string_map_replace(struct bnode **);

void string_map_replace_midval(struct bnode **toReplace) {
    struct bnode **replaceWith;
    replaceWith = &((**toReplace).left);
    while(((**replaceWith).right) != NULL) {
        replaceWith = &((**replaceWith).right);
    }
    string_map_replace(replaceWith);
}

void string_map_replace(struct bnode **toReplace) {
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "replacing a node\n");
    fclose(file);
    #endif
    struct bnode *r = (**toReplace).right;
    struct bnode *l = (**toReplace).left;
    if(r != NULL && l != NULL) {
        string_map_replace_midval(toReplace);
    } else if( r != NULL ) {
        *toReplace = r; 
    } else if( l != NULL ) {
        *toReplace = l; 
    } else {
        ;
    }    
}

void string_map_delete(struct string_map *tree, char *key) { 
    #ifdef __DEBUG__
    file = fopen("log", "a+");
    fprintf(file, "string_map_delete\n");
    fclose(file);
    #endif
    struct bnode **toDelete = string_map_node_search(tree, key);
    if(toDelete != NULL) {
        if(*toDelete != NULL) {
            string_map_replace(toDelete);
            free(*toDelete);
        }
    }
}
