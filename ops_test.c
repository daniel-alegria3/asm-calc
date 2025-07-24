//[ TODO: delete this functions after using it as reference
#include <string.h>
#include <stdio.h>
#include <math.h>

void str_to_base10f(char *str, float *num, int base)
{
    char digits[] = "0123456789ABCDEF";

    int len = strlen(str)-1;
    if (len < 0) {
        str[0] = '\0';
        return;
    }

    int dec = 0;
    for (char *c = str; *c != '\0'; ++c) {
        int dig;
        switch (*c) {
            case '0': dig = 0; break;
            case '1': dig = 1; break;
            case '2': dig = 2; break;
            case '3': dig = 3; break;
            case '4': dig = 4; break;
            case '5': dig = 5; break;
            case '6': dig = 6; break;
            case '7': dig = 7; break;
            case '8': dig = 8; break;
            case '9': dig = 9; break;
            case 'a': case 'A': dig = 10; break;
            case 'b': case 'B': dig = 11; break;
            case 'c': case 'C': dig = 12; break;
            case 'd': case 'D': dig = 13; break;
            case 'e': case 'E': dig = 14; break;
            case 'f': case 'F': dig = 15; break;
        }
        dec += dig * powf(base, len);
        --len;
        // 0F9
    }

    *num = dec;
}


void base10f_to_str(float num, char *str, int base)
{
    int dec = num;
    char digits[] = "0123456789ABCDEF";
    char buffer[64+1]; // enough for 32-bit int in binary + null

    if (base < 2 || base > 16) {
        str[0] = '\0';
        return;
    }

    if (dec == 0) {
        str[0] = '0';
        str[1] = '\0';
        return;
    }

    int is_negative = 0;
    if (dec < 0 && base == 10) {
        is_negative = 1;
        dec = -dec;
    }

    int i = 0;
    while (dec > 0) {
        buffer[i++] = digits[dec % base];
        dec /= base;
    }

    if (is_negative) {
        buffer[i++] = '-';
    }

    // reverse the string
    for (int j = 0; j < i; ++j) {
        str[j] = buffer[i - j - 1];
    }
    str[i] = '\0';
}
//]


float asm_fadd(float a, float b) {return a+b;}
float asm_fsub(float a, float b) {return a-b;}
float asm_fmul(float a, float b) {return a*b;}
float asm_fdiv(float a, float b) {return a/b;}

