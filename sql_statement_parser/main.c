#include "y.tab.h"

#include "stdlib.h"
#include "stdio.h"

#ifdef YYDEBUG
    yydebug = 0;    //if yydebug = 1, it will show the degug info in command line
#endif

int main(){
    char sql_statement[256];
    while(gets(sql_statement)){
        exec_parser(sql_statement, "../config/blocked_list.json");
    }
    return 0;
}