#define MAXLINE 4096

#include "sql_statement_parser/y.tab.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#include <cstdio>
#include <string>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <array>
using namespace std;

// exec command line and return the result
string exec(const char* cmd);

int main(){
    int  listenfd, connfd;
    struct sockaddr_in  server_info;
    struct sockaddr_in  client_info;
    unsigned int addrlen = sizeof(client_info);
    string result;

    // database config
    string HOSTNAME = "localhost";
    string PASSWORD = "Tiva1135";
    string DB_NAME = "test";
    string DB_USER = "SA";

    char  buff[MAXLINE];
    int  n;

    if( (listenfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ){
        printf("create socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    memset(&server_info, 0, sizeof(server_info));
    server_info.sin_family = AF_INET;
    server_info.sin_addr.s_addr = htonl(INADDR_ANY);
    server_info.sin_port = htons(6666);

    if( bind(listenfd, (struct sockaddr*)&server_info, sizeof(server_info)) == -1){
        printf("bind socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    if( listen(listenfd, 10) == -1){
        printf("listen socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    printf("======waiting for client‘s request======\n");
    while(1){
        if( (connfd = accept(listenfd, (struct sockaddr*)&client_info, &addrlen)) == -1){
            printf("accept socket error: %s(errno: %d)",strerror(errno),errno);
            continue;
        }
        n = recv(connfd, buff, MAXLINE, 0);
        buff[n] = '\0';

        char ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(client_info.sin_addr), ip, INET_ADDRSTRLEN);

        const char* sql_statement = buff;
        const char* config_file = "./config/blocked_list.json";

        printf("recv msg from %s : %s\n", ip, sql_statement);

        int parse_result = exec_parser(sql_statement, config_file);

        string sql_statement_str(sql_statement);
        string command = "mssql-cli -S " + HOSTNAME + " -d " + DB_NAME + " -U " + DB_USER + " -P " + PASSWORD + " -Q \"" + sql_statement_str + "\"";

        if(parse_result == 0){    // parse success
            result = exec(command.c_str());
            cout << "database result : " << endl << result << endl;
        }
        else{               // parse failed
            result = "flex and bison parsed failed";
        }
        send(connfd, result.c_str(), result.length(), 0);
        close(connfd);
    }
    close(listenfd);
    return 0;
}

string exec(const char* cmd) {
    array<char, 128> buffer;
    string result;
    unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        throw runtime_error("popen() failed!");
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}