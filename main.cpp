#include "sql_statement_parser/y.tab.h"

#include "stdlib.h"
#include "stdio.h"

int main(){
    int result = exec_parser("select fdsf from fdsf where x=(select fdsf from users);");
    printf("%d", result);
}