struct bnode {
    void *data;
    int key;
    struct bnode *left;
    struct bnode *right;
}

struct bst {
    struct bnode *root;
    struct bnode *flyweight;
    int size;
    int depth;
    int insert_count;
    int delete_count;
    long int access_count;
}

struct bst *new_bst() {
    struct bst *retval = (struct bst *) sys_new( "bst", "persistent", sizeof(struct bst));
    retval->flyweight = (struct bnode *) pmalloc(1); // don't access members, they won't be there!
    return retval;
}

void *search( struct bst *b, struct bnode *node, int key) {
    int repeat = 1;
    while(repeat) {  
        if( key < node->key ) {
            node = &node->left;
            if( node == NULL ) return NULL;
        } else if( node->key < key ) {
            node = &node->right;
            if( node == NULL ) return NULL;
        } else {
            b->access_count++;
            repeat = 0;
        }
    }
}

void insert( struct bst *b, struct bnode *node, void *data, int key) {
    int repeat = 1;
    while(repeat) {  
        repeat = 0; 
        struct bnode **maybe_allocate = &(b->flyweight);
        if( key < node->key ) {
            maybe_allocate = &node->left;
        } else if( node->key < key ) {
            maybe_allocate = &node->right;
        } 
    
        if( *maybe_allocate == NULL ) {
            *maybe_allocate = pmalloc(sizeof(struct bnode));
            *maybe_allocate->key = key;
            *maybe_allocate->data = data;
            b->insert_count++;
        } else if( *maybe_allocate == b->flyweight ) {
            b->dupicate_insertion++;
        } else {
            node = *maybe_allocate;
            repeat = 1;
        }
    }
}

void *bst_search( struct bst *b, int key) {
    if( b->root == NULL ) {
        return NULL;
    } else {
        search( b, root, key );
    }
}

void bst_insert( struct bst *b, void *data, int key) {
    if( b->root == NULL ) {
        b->root = pmalloc(sizeof(struct bnode));
        b->root->key = key;
        b->root->data = data;
    } else {
        insert( b, root, data, key );
    }
}
