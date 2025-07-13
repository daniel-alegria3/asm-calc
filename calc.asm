format ELF64

section '.text' executable

public str_to_num
public num_to_str

public asm_fadd
public asm_fsub
public asm_fmul
public asm_fdiv

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

