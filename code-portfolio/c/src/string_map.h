#ifndef __STRING_MAP_H__
#define __STRING_MAP_H__
 
#include<stdlib.h>

struct string_map;

struct string_map *new_string_map();
void free_string_map(struct string_map *);
void *string_map_search( struct string_map *tree, char *key); 
void string_map_insert( struct string_map *tree, void *data, char *key); 
void string_map_delete(struct string_map *tree, char *key);

#endif//__BST_H__
