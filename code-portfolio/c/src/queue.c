#include "stdlib.h"
#include "base_type.h"
#include "queue.h"

struct queue;

struct node {
    struct node *next;
    struct base_type *entry;
};

struct queue {
    struct node *front;
    struct node *back;
    struct node sentinel;
};

struct queue * new_queue() {
    struct queue *retval = (struct queue*)
        _new("queue", "persistent", sizeof(struct queue));
    queue_init(retval);
    return retval;
}

void queue_init(struct queue *q) {
    q->sentinel.next = &(q->sentinel);
    q->sentinel.entry = NULL; // change to a logger object
    q->front = &(q->sentinel);
}

void enqueue(struct queue *q, struct base_type *obj) {
    struct node *toAdd = (struct node *) pmalloc(sizeof(struct node));
    toAdd->next = &(q->sentinel);
    q->back->next = toAdd;
    q->back = toAdd;
}

struct base_type *dequeue(struct queue *q ) {
    struct base_type *retval = q->front->entry;
    q->front = q->front->next;
    return retval;
}


