#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdbool.h>
#include <math.h>

#define PORT 6969
#define BUFFER_SIZE 128*1024

//[ external functions
extern void str_to_base10f(char *str, float *num, int base);
extern void base10f_to_str(float num, char *str, int base);
extern float asm_fadd(float a, float b);
extern float asm_fsub(float a, float b);
extern float asm_fmul(float a, float b);
extern float asm_fdiv(float a, float b);
//]

void send_response(int csocket, const char *response);
void handle_request(int csocket, const char *request);

void signal_handler(int sig);

static int server_fd = -1;
static volatile sig_atomic_t shutdown_requested = 0;

int main() {

    //[ Setup interrupt signal handlers
    struct sigaction sa;
    sa.sa_handler = signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;

    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
    //]

    // Make a localhost TCP server
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == 0) {
        perror("socket failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // If server_fd is already in use, re-use it
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Give the server_fd an address
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Accept client connection requests
    if (listen(server_fd, 3) < 0) {
        perror("listen");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    printf("Server running on http://localhost:%d\n", PORT);
    printf("Press Ctrl+C to shut down gracefully\n");

    // Mainloop
    int client_socket;
    while (!shutdown_requested) {
        client_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen);

        if (client_socket < 0) {
            if (shutdown_requested) {
                printf("Server shutdown requested, stopping accept loop\n");
                break;
            }
            perror("accept");
            continue;
        }

        char buffer[BUFFER_SIZE] = {0};
        read(client_socket, buffer, BUFFER_SIZE);

        handle_request(client_socket, buffer);
        close(client_socket);
    }

    if (server_fd != -1) {
        close(server_fd);
        printf("Server socket closed\n");
    }

    printf("Server shutdown complete\n");
    return 0;
}


void send_response(int csocket, const char *response) {
    char http_response[BUFFER_SIZE];
    snprintf(http_response, sizeof(http_response),
        "HTTP/1.1 200 OK\r\n"
        "Content-Type: application/json\r\n"
        "Access-Control-Allow-Origin: *\r\n"
        "Content-Length: %zu\r\n"
        "\r\n"
        "%s",
        strlen(response), response);
    send(csocket, http_response, strlen(http_response), 0);
}

void handle_request(int csocket, const char *request) {
    printf("Raw request:\n%s\n", request);

    // Calculate operation
    if (strstr(request, "GET /calculate")) {
        char op;
        char sa[64+1], sb[64+1];
        int base_l, base_r;

        // Extract operation and operands from query string
        if (sscanf(request, "GET /calculate?op=%c&a=%[^&]&b=%[^&]&bl=%d&br=%d", &op, sa, sb, &base_l, &base_r) == 5) {
            printf("\n");
            printf("op: %c\n", op);
            printf("sa, sb: %s, %s\n", sa, sb);
            printf("base[l|r]: %d, %d\n", base_l, base_r);

            float a, b;
            str_to_base10f(sa, &a, base_l);
            str_to_base10f(sb, &b, base_l);
            printf("a, b: %f, %f\n", a, b);

            float result;
            switch(op) {
                case '+': result = asm_fadd(a, b); break;
                case '-': result = asm_fsub(a, b); break;
                case '*': result = asm_fmul(a, b); break;
                case '/': result = asm_fdiv(a, b); break;
                default:
                    send_response(csocket, "{\"error\":\"Invalid operation\"}");
                    return;
            }
            printf("result: %f\n", result);

            char cres_l[64+1];
            char cres_r[64+1];
            base10f_to_str(result, cres_l, base_l);
            base10f_to_str(a, sa, base_r);
            base10f_to_str(b, sb, base_r);
            base10f_to_str(result, cres_r, base_r);
            printf("cres_r: %s\n", cres_r);

            char response[512];
            snprintf(response, sizeof(response),
                "{ \"cres_l\":\"%s\", \"cnum1\":\"%s\", \"cnum2\":\"%s\", \"cres_r\":\"%s\" }",
                cres_l, sa, sb, cres_r
            );
            send_response(csocket, response);
            return;
        }
    }

    // Serve HTML file for root path
    if (strstr(request, "GET / ")) {
        FILE *file = fopen("gui.html", "r");
        if (file) {
            fseek(file, 0, SEEK_END);
            long size = ftell(file);
            fseek(file, 0, SEEK_SET);

            char *html = malloc(size + 1);
            fread(html, 1, size, file);
            fclose(file);

            char http_response[BUFFER_SIZE + size];
            snprintf(http_response, sizeof(http_response),
                "HTTP/1.1 200 OK\r\n"
                "Content-Type: text/html\r\n"
                "Content-Length: %ld\r\n"
                "\r\n"
                "%s",
                size, html);

            send(csocket, http_response, strlen(http_response), 0);
            free(html);
            return;
        }
    }

    // Default 404 response
    send_response(csocket, "{\"error\":\"Not found\"}");
}


void signal_handler(int sig) {
    printf("\nReceived signal %d. Shutting down gracefully...\n", sig);
    shutdown_requested = 1;

    if (server_fd != -1) {
        close(server_fd);
        server_fd = -1;
    }
}

