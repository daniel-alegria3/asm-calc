#include <stdio.h>

//[
void str_to_base10f(char *str, float *num, int base)
{
    int dig;
    int dot_found = 0;
    int sign = 1;
    float f = 0;
    float div = 1.0;

    for (char *c = str; *c != '\0'; ++c) {
        switch (*c) {
            case ' ': dig = -1; break;
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
            case '-': dig = -1; sign = -1; break; // TODO?: check if negative sign is the first thing
            case '.': dig = -1; dot_found = 1; break;
        }
        if (dig == -1)
            continue;
        if (!dot_found) {
            f *= base;
            f += dig;
        } else {
            div *= base;
            f += dig/div;
        }
    }

    *num = f * sign;
}


void base10f_to_str(float num, char *str, int base)
{
    if (num == 0) {
        str[0] = '0';
        str[1] = '\0';
        return;
    }
    if (base < 2 || base > 16) {
        str[0] = '\0';
        return;
    }

    int dec;
    float f;
    int is_negative = 0;
    char buffer[128+1];
    char DIGITS[] = "0123456789ABCDEF";

    if (num < 0) {
        is_negative = 1;
        num = -num;
    }
    dec = num;
    f = num - dec;

    int i = 0;
    if (dec == 0) {
        buffer[i++] = '0';
    } else while (dec > 0) {
        buffer[i++] = DIGITS[dec % base];
        dec /= base;
    }

    if (is_negative) {
        buffer[i++] = '-';
    }

    // reverse the string
    for (int j = 0, k = i-1; j < i; ++j, --k) {
        str[j] = buffer[k];
    }

    // Decimal part
    if (f > 0.0f) {
        str[i++] = '.';

        int precision = 6;
        int digit;
        while (precision-- > 0 && f > 0.0f) {
            f *= base;
            digit = (int)f;
            str[i++] = DIGITS[digit];
            f -= digit;
        }
    }

    str[i] = '\0';
}
//]


float asm_fadd(float a, float b) {return a+b;}
float asm_fsub(float a, float b) {return a-b;}
float asm_fmul(float a, float b) {return a*b;}
float asm_fdiv(float a, float b) {return a/b;}

