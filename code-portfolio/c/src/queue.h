#include "base_type.h"
struct queue;
struct queue *new_queue();
void queue_init(struct queue *q); 
void enqueue(struct queue *q, struct base_type *obj); 
struct base_type *dequeue(struct queue *q );


