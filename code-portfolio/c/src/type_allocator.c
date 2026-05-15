#include"system.h"
#include"type_allocator.h"
#include"stdlib.h"
#define __CHARSET_SIZE 52

char ready = 0;

int char_idx_direct_map(char letter) {
    if( letter < 65 ) return -1;
    if( letter > 121) return -1;
    if( letter < 91 ) return letter - 65;
    if( letter > 96 ) return letter - 71;
}

struct trienode;

struct trienode {
    struct trienode *nextChar[__CHARSET_SIZE];
    int id;
};

struct trienode root;
int outOfIds;

void tn_clear(struct trienode *tn) {
    int i = 0;
    for( ; i < __CHARSET_SIZE; i++) {
        tn->nextChar[i] = 0;
    }
}

void ta_init() {
    if(ready == 1) {
        return;
    }
    tn_clear(&root);
    root.id = 0; // use to indicate next id to be assigned
    outOfIds = 0;
    ready = 1;
}

int getTypeIdFromString( char *str ) {
    int i = 0;
    struct trienode *curr = &root;
    while( str[i] != '\n' ) {
        int idx = char_idx_direct_map(str[i]);
        if(idx == -1) {
            return -1;
        }
        if( curr->nextChar[idx] == NULL) {
            if( outOfIds ) {
                systemLog("Ran out of type ids :(");
                systemStop();
            }
            curr->nextChar[idx] = 
              (struct trienode *) pmalloc(sizeof(struct trienode));
            tn_clear(curr->nextChar[idx]);
            curr->nextChar[idx]->id = root.id++; // see above
            if(root.id < 0 ) { // overflow
                outOfIds = 1;
            }
        }
        curr = curr->nextChar[idx];
    }
    return curr->id;
}
