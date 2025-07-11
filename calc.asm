format ELF64

section '.text' executable

public asm_add
public asm_sub
public asm_mul
public asm_div
public asm_fdiv

asm_add:
    mov eax, edi
    add eax, esi
    ret

asm_sub:
    mov eax, edi
    sub eax, esi
    ret

asm_mul:
    mov eax, edi
    imul eax, esi
    ret

asm_div:
    mov eax, edi
    cqo                 ; Sign-extend EAX into EDX:EAX
    idiv esi            ; Divide EDX:EAX by ESI
    ret

asm_fdiv:
    divss xmm0, xmm1  ; Scalar Single-precision divide
    ret

