#include <stdio.h>
#include <stdlib.h>
#include "json-c/json.h"

int main(){
    printf("Hello");
    struct json_object * json_policy_array;
    json_policy_array = json_object_from_file("./blocked_list.json");
    printf("%s\n",json_object_to_json_string(json_policy_array));

    return 0;
}