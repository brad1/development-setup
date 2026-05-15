#include<stdlib.h>
#include"system.h"
#include<stdio.h>

#define __P_MEM_SIZE 65536 // 64K
#define __T_MEM_SIZE 8192  // 8K

struct system;
struct system sys;
FILE * syslog;

unsigned char p_mem[ __P_MEM_SIZE ];
unsigned char t_mem[ __T_MEM_SIZE ];

struct system {
    unsigned char *p_mem_base;
    unsigned char *p_mem_curr;
    unsigned char *p_mem_limit;
    unsigned char *t_mem_base;
    unsigned char *t_mem_curr;
    unsigned char *t_mem_limit;
};

void mem_init() {
    sys.p_mem_base = p_mem;
    sys.p_mem_curr = p_mem;
    sys.p_mem_limit = p_mem + __P_MEM_SIZE - 1;
    sys.p_mem_base = t_mem;
    sys.p_mem_curr = t_mem;
    sys.p_mem_limit = t_mem + __T_MEM_SIZE - 1;
}

void sys_start() {
    printf("Initializinp system");
    syslog = fopen("systemLog", "w");
    if( syslog == 0 ) {
        printf("Could not open the system log");
    } // after this print errors to system log

    mem_init();    
    ta_init();
    sched_start();
}

void systemLog(char *str) {
    // fprintf(syslog, str);
    // fprintf(syslog, "\n");
}

void systemStop() {
    exit(1);
}

// simple allocator, no free blocks or free block  propagation
void * pmalloc( int size ) {
    sys.p_mem_curr += size;
    if( sys.p_mem_curr > sys.p_mem_limit ) {
        sys.p_mem_curr -= size;
        return NULL;
    } else {
        return sys.p_mem_curr;
    }
}
