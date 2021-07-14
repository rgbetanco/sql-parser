#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "strmap.h"

#define NR_BUCKETS 1024

struct map {
    char *key;
    char *value;
};

int main(){
    /*
    char* string;
    char* one = "one";
    char* two = "two";
    strcat(one, two);
    //string = strdup(one);
    printf("%s", one);
    return 0;
    */
    StrMap *sm;
    char buf[255];
    int result;

    sm = sm_new(10);
    if (sm == NULL) {
        printf("fail");     /* Handle allocation failure... */
    }

    sm_put(sm, "application name", "Test Application");
    sm_put(sm, "application version", "1.0.0");
    sm_put(sm, "application dsfversion", "1.0fds.0");

    result = sm_get(sm, "application name", buf, sizeof(buf));
    if (result == 0) {
        printf("not found");/* Handle value not found... */
    }
    printf("value: %s\n", buf);
    sm_delete(sm);
}