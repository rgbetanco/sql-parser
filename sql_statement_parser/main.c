#include "y.tab.h"

#include "stdlib.h"
#include "stdio.h"

#ifdef YYDEBUG
    yydebug = 0;    //if yydebug = 1, it will show the degug info in command line
#endif

int main(){
    int result = exec_parser("select fdsf from fdsf where x=(select fdsf from users);", "../config/blocked_list.json");
    printf("%d", result);
}