#include <iostream>
#include <fstream>
#include <string>
#include "json-c/json.h"
using namespace std;

int main(){
    struct json_object * json;
    struct json_object * temp;
    fstream flex;
    
    json = json_object_from_file("./blocked_list.json");
    json = json_object_object_get(json, "blocked_table_list");

    for (int i = 0; i < json_object_array_length(json); i++){
        temp = json_object_array_get_idx(json, i);
        cout << json_object_to_json_string(temp);
    }

    flex.open("../scanner.l", ios::in|ios::out);
    if (flex){
        cout << "open flex file success." << endl;
    }
    else{
        cout << "open flex file fail." << endl;
    }

    flex.close();
    return 0;
}

// int main(){
//       FILE *fp;
//       char ch;
//       if((fp=fopen("../scanner.l","r"))==NULL){
//           printf("open file error!!\n");
//           system("PAUSE");
//           exit(0);
//       }    

//      while((ch=getc(fp))!=EOF){
//            printf("%c ",ch);
//       }

//       fclose(fp);
//       system("PAUSE");
//       return 0;
// }