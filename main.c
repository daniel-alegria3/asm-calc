#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdbool.h>

#define PORT 6969
#define BUFFER_SIZE 128*1024

//[ external assembly functions
extern void str_to_base10f(char *str, float *num, int base);
extern void base10f_to_str(float num, char *str, int base);
extern float asm_fadd(float a, float b);
extern float asm_fsub(float a, float b);
extern float asm_fmul(float a, float b);
extern float asm_fdiv(float a, float b);
//]

void send_response(int client_socket, const char *response);
void handle_request(int client_socket, const char *request);

static int server_fd = -1;
static volatile sig_atomic_t shutdown_requested = 0;
void signal_handler(int sig);
void setup_signal_handlers();

int main() {
    int client_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    setup_signal_handlers();

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Set SO_REUSEADDR to avoid "Address already in use" errors
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    printf("Server running on http://localhost:%d\n", PORT);
    printf("Press Ctrl+C to shut down gracefully\n");

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

// TODO: delete this function after using it as reference
void _num_to_str(int num, char *str, int base)
{
    char digits[] = "0123456789ABCDEF";
    char buffer[32+1]; // enough for 32-bit int in binary + null
    int i = 0, j;

    if (base < 2 || base > 16) {
        str[0] = '\0';
        return;
    }

    if (num == 0) {
        str[0] = '0';
        str[1] = '\0';
        return;
    }

    int is_negative = 0;
    if (num < 0 && base == 10) {
        is_negative = 1;
        num = -num;
    }

    while (num > 0) {
        buffer[i++] = digits[num % base];
        num /= base;
    }

    if (is_negative) {
        buffer[i++] = '-';
    }

    // reverse the string
    for (j = 0; j < i; ++j) {
        str[j] = buffer[i - j - 1];
    }
    str[i] = '\0';
}


void send_response(int client_socket, const char *response) {
    char http_response[BUFFER_SIZE];
    snprintf(http_response, sizeof(http_response),
        "HTTP/1.1 200 OK\r\n"
        "Content-Type: application/json\r\n"
        "Access-Control-Allow-Origin: *\r\n"
        "Content-Length: %zu\r\n"
        "\r\n"
        "%s",
        strlen(response), response);
    send(client_socket, http_response, strlen(http_response), 0);
}

void handle_request(int client_socket, const char *request) {
    // Parse request (simplified - in real code use proper parsing)
    printf("Raw request:\n%s\n", request);  // Add this line
    if (strstr(request, "GET /calculate")) {
        // Extract operation and operands from query string
        // This is simplified - in a real app you'd properly parse the URL
        char op;
        char sa[64+1], sb[64+1];
        int base;
        bool is_base_input = false; // TODO: pass this through GET request from html file

        int d;
        if ((d = sscanf( request, "GET /calculate?op=%c&a=%[^&]&b=%[^&]&base=%d", &op, sa, sb, &base)) == 4) {
            printf("\n");
            printf("op: %c\n", op);
            printf("sa, sb: %s, %s\n", sa, sb);
            printf("base: %d\n", base);

            float a, b;
            if (is_base_input) {
                str_to_base10f(sa, &a, base);
                str_to_base10f(sb, &b, base);
            } else {
                str_to_base10f(sa, &a, 10);
                str_to_base10f(sb, &b, 10);
            }
            printf("a, b: %f, %f\n", a, b);

            float result;
            switch(op) {
                case '+': result = asm_fadd(a, b); break;
                case '-': result = asm_fsub(a, b); break;
                case '*': result = asm_fmul(a, b); break;
                case '/': result = asm_fdiv(a, b); break;
                default:
                    send_response(client_socket, "{\"error\":\"Invalid operation\"}");
                    return;
            }
            printf("result: %f\n", result);

            char sresult[64+1];
            if (is_base_input) {
                base10f_to_str(result, sresult, 10);
            } else {
                base10f_to_str(result, sresult, base);
            }
            printf("sresult: %s\n", sresult);

            char response[512];
            snprintf(response, sizeof(response),
                "{ \"res\":%f, \"cnum1\":\"%s\", \"cnum2\":\"%s\", \"cres\":\"%s\" }",
                result, sa, sb, sresult
            );
            send_response(client_socket, response);
            return;
        }
    }

    // Serve HTML file for root path
    if (strstr(request, "GET / ")) {
        FILE *file = fopen("index.html", "r");
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

            send(client_socket, http_response, strlen(http_response), 0);
            free(html);
            return;
        }
    }

    // Default 404 response
    send_response(client_socket, "{\"error\":\"Not found\"}");
}


void signal_handler(int sig) {
    printf("\nReceived signal %d. Shutting down gracefully...\n", sig);
    shutdown_requested = 1;

    if (server_fd != -1) {
        close(server_fd);
        server_fd = -1;
    }
}

void setup_signal_handlers() {
    struct sigaction sa;
    sa.sa_handler = signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;

    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
}

