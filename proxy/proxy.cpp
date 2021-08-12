#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<unistd.h>

#define MAXLINE 4096

void send(const char* ip_address, int port, const char* sql_statement);

int main(int argc, char** argv){
    int  listenfd, connfd, sendfd;
    struct sockaddr_in  receive_address;

    char  buff[4096];
    int  n;

    if( (listenfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ){
        printf("create socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    memset(&receive_address, 0, sizeof(receive_address));
    receive_address.sin_family = AF_INET;
    receive_address.sin_addr.s_addr = htonl(INADDR_ANY);
    receive_address.sin_port = htons(6666);

    if( bind(listenfd, (struct sockaddr*)&receive_address, sizeof(receive_address)) == -1){
        printf("bind socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    if( listen(listenfd, 10) == -1){
        printf("listen socket error: %s(errno: %d)\n",strerror(errno),errno);
        return 0;
    }

    printf("======waiting for client‘s request======\n");
    while(1){
        if( (connfd = accept(listenfd, (struct sockaddr*)NULL, NULL)) == -1){
            printf("accept socket error: %s(errno: %d)",strerror(errno),errno);
            continue;
        }
        n = recv(connfd, buff, MAXLINE, 0);
        buff[n] = '\0';
        printf("recv msg from client: %s\n", buff);
        close(connfd);

        send("192.168.11.165", 20000, buff);
    }
    close(listenfd);
    return 0;
}

void send(const char* ip_address, int port, const char* sql_statement){
    int   sockfd, n;
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