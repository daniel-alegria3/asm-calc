#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

// Declare assembly functions
extern int asm_add(int a, int b);
extern int asm_sub(int a, int b);
extern int asm_mul(int a, int b);
extern int asm_div(int a, int b);
extern float asm_fdiv(float a, float b);

void send_response(int client_socket, const char *response);
void handle_request(int client_socket, const char *request);
void num_to_str(char *str, int num, int base);

#define PORT 6969
#define BUFFER_SIZE 128*1024

int main() {
    int server_fd, client_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    printf("Server running on http://localhost:%d\n", PORT);

    while (1) {
        if ((client_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
            perror("accept");
            continue;
        }

        char buffer[BUFFER_SIZE] = {0};
        read(client_socket, buffer, BUFFER_SIZE);

        handle_request(client_socket, buffer);
        close(client_socket);
    }

    return 0;
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
        char sa[32+1], sb[32+1];
        int base;

        int a, b;
        int result;

        int d;
        if ((d = sscanf( request, "GET /calculate?op=%c&a=%[^&]&b=%[^&]&base=%d", &op, sa, sb, &base)) == 4) {
            a = strtol(sa, NULL, base);
            b = strtol(sb, NULL, base);
            switch(op) {
                case '+': result = asm_add(a, b); break;
                case '-': result = asm_sub(a, b); break;
                case '*': result = asm_mul(a, b); break;
                case '/': result = asm_fdiv(a, b); break;
                default:
                    send_response(client_socket, "{\"error\":\"Invalid operation\"}");
                    return;
            }

            printf("\n\ndebug: %d, %s, %d, %s, %d\n", base, sa, a, sb, b);
            char sresult[32+1];
            num_to_str(sresult, result, base);
            printf("\n\ndebug2: %s\n", sresult);

            char response[128];
            snprintf(response, sizeof(response), "{\"result\":%s, \"base\":%d }", sresult, base);
            send_response(client_socket, response);
            return;
        }
        printf("AFTER DEBUG: %d\n", d);
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

void num_to_str(char *str, int num, int base)
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

