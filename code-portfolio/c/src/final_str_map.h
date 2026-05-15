#ifndef __FINAL_STRING_MAP_H__
#define __FINAL_STRING_MAP_H__

#include"base_type.h"

struct final_str_map;
struct final_str_map *new_bst();
void final_str_map_insert( struct final_str_map *, struct base_type *, char *);
struct base_type *final_str_map_get(struct final_str_map *, char *); 

#endif
