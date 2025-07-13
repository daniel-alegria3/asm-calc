format ELF64

section '.text' executable

; public str_to_base10f
; public base10f_to_str

public asm_fadd
public asm_fsub
public asm_fmul
public asm_fdiv

str_to_base10f:
    ; TODO
    mov eax, 0x42888000
    movd xmm0, eax
    movss [rsi], xmm0
    ret

base10f_to_str:
    ; TODO
    mov eax, 65
    mov [rdi], eax
    mov eax, 0
    mov [rdi+1], eax
    ret

asm_fadd:
    addss xmm0, xmm1
    ret

asm_fsub:
    subss xmm0, xmm1
    ret

asm_fmul:
    mulss xmm0, xmm1
    ret

asm_fdiv:
    divss xmm0, xmm1
    ret

