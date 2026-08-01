#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

/*
 * Thread timing comparison on Raspberry Pi 5 with and without PREEMPT_RT.
 *
 * Compiled and tested on Ubuntu 26.04 LTS.
 */

int spawn_fifo_thread(
    pthread_t *thread,
    void *(*thread_fn)(void *),
    void *thread_arg,
    int priority
);

static void *first_thread_function(void *arg)
{
    (void)arg;

    /* Background work goes here. */

    return NULL;
}

int main(void)
{
    printf("start of main\n");

    pthread_t first_thread;
    int rc = spawn_fifo_thread(&first_thread, first_thread_function, NULL, 50);

    printf("spawn_fifo_thread returned %i\n", rc);
    printf("end of main\n");

    return rc == 0 ? 0 : 1;
}

int set_attr(pthread_attr_t *attr, int priority)
{
    int rc = pthread_attr_init(attr);
    if (rc != 0) {
        return rc;
    }

    rc = pthread_attr_setinheritsched(attr, PTHREAD_EXPLICIT_SCHED);
    if (rc != 0) {
        pthread_attr_destroy(attr);
        return rc;
    }

    rc = pthread_attr_setschedpolicy(attr, SCHED_FIFO);
    if (rc != 0) {
        pthread_attr_destroy(attr);
        return rc;
    }

    struct sched_param param = {0};
    param.sched_priority = priority;

    rc = pthread_attr_setschedparam(attr, &param);
    if (rc != 0) {
        pthread_attr_destroy(attr);
        return rc;
    }

    return 0;
}

int spawn_fifo_thread(
    pthread_t *thread,
    void *(*thread_fn)(void *),
    void *thread_arg,
    int priority
)
{
    pthread_attr_t attr;
    int rc = set_attr(&attr, priority);
    if (rc != 0) {
        printf("early exit from spawn_fifo_thread\n");
        return rc;
    }

    rc = pthread_create(thread, &attr, thread_fn, thread_arg);
    pthread_attr_destroy(&attr);
    if (rc != 0) {
        printf("early exit from spawn_fifo_thread\n");
        return rc;
    }

    pthread_join(*thread, NULL);

    return 0;
}
