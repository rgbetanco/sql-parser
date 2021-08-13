#define MAXLINE 4096

#include "sql_statement_parser/y.tab.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#include <string>
#include <iostream>
using namespace std;

// send data to another server
void send_data(const char* ip_address, int port, const char* sql_statement);

int main(){
    // listen on the port 
    int  listenfd, connfd;
    struct sockaddr_in  server_info;
    struct sockaddr_in  client_info;
    unsigned int addrlen = sizeof(client_info);

    char  buff[4096];
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

        const char* sql_statement = buff;
        const char* config_file = "./config/blocked_list.json";

        int parse_result = exec_parser(sql_statement, config_file);

        printf("recv msg from client: %s\n", sql_statement);

        if(parse_result == 0){    // parse success
            printf("success\n");
            char str[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &(client_info.sin_addr), str, INET_ADDRSTRLEN);
            printf("from ip %s\n", str);
            send(connfd, "success", strlen("success"), 0);
            send_data("192.168.11.165", 20000, sql_statement);
        }
        else{               // parse failed
            printf("failed\n");
            send(connfd, "failed", strlen("failed"), 0);
        }

        close(connfd);
    }
    close(listenfd);
    return 0;
}

void send_data(const char* ip_address, int port, const char* sql_statement){
    int sockfd;
    char  recvline[4096], sendline[4096];
    struct sockaddr_in  servaddr;

    if( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
        printf("create socket error: %s(errno: %d)\n", strerror(errno),errno);
        exit(0);
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(port);
    if( inet_pton(AF_INET, ip_address, &servaddr.sin_addr) <= 0){
        printf("inet_pton error for %s\n",ip_address);
        exit(0);
    }

    if( connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) < 0){
        printf("connect error: %s(errno: %d)\n",strerror(errno),errno);
        exit(0);
    }

    printf("send msg to server: %s\n", sql_statement);

    if( send(sockfd, sql_statement, strlen(sql_statement), 0) < 0){
        printf("send msg error: %s(errno: %d)\n", strerror(errno), errno);
        exit(0);
    }
    close(sockfd);
}