format ELF64

section '.data' writable
    ; str_to_base10f
    base rq 1
    dig rd 1
    dot_found rb 1
    is_negative rb 1

    ; base10f_to_str
    base2 rq 1
    is_negative2 rb 1
    DIGITS db "0123456789ABCDEF", 0
    buffer rb 128+1

    ; xmm float constants
    align 4
    XMM_FLOAT_ZERO dd 0.0
    XMM_FLOAT_ONE dd 1.0
    ; XMM_NEGATE_FLOAT_MASK dq?? 0xE80000000

section '.text' executable

    public str_to_base10f
    public base10f_to_str

    public asm_fadd
    public asm_fsub
    public asm_fmul
    public asm_fdiv

str_to_base10f:
    ; rdi -> char *str
    ; rsi -> float *num
    ; rdx -> int base
    enter 0,0

    mov rbx, rsi
    mov rsi, rdi
    mov [base], rdx
    ; rbx -> float *num
    ; rsi -> char *str
    ; [base] -> int base

    ;[ init vars
    mov [dot_found], 0
    mov [is_negative], 0
    xorps xmm0, xmm0; f
    movss xmm1, [XMM_FLOAT_ONE]; div
    ;]

.str_loop:
    lodsb; al -> char ch
    cmp al, 0
    jz .exit_str_loop

    call switch_char

    cmp [dig], -1
    jz .str_loop

    cvtsi2ss xmm2, dword [base]
    cvtsi2ss xmm3, dword [dig]

    cmp [dot_found], 1
    jz ._dot_found
    mulss xmm0, xmm2
    addss xmm0, xmm3
    jmp ._dot_found_end
    ._dot_found:
    mulss xmm1, xmm2
    divss xmm3, xmm1
    addss xmm0, xmm3
    ._dot_found_end:

    jmp .str_loop
.exit_str_loop:

    cmp [is_negative], 1
    jnz .end
    mov eax, 80000000h  ; Sign bit mask for 32-bit float
    movd xmm4, eax      ; Move mask to xmm4
    xorps xmm0, xmm4    ; Flip sign bit of xmm0

.end:
    movss [rbx], xmm0

    leave
    ret

base10f_to_str:
    ; xmm0 -> float num
    ; rdi -> char *str
    ; rsi -> int base

    mov [base2], rsi ; -> base
    mov rsi, 0       ; -> i

    comiss xmm0, [XMM_FLOAT_ZERO]
    jnz .is_zero_end
    mov [rdi+rsi], byte '0'
    inc rsi
    jmp .end
    .is_zero_end:

    cmp [base2], 2
    jl .end
    cmp [base2], 16
    jg .end

    mov [is_negative2], 0
    comiss xmm0, [XMM_FLOAT_ZERO]
    jnb .float_neg_end
    mov [is_negative2], 1
    mov eax, 80000000h  ; Sign bit mask for 32-bit float
    movd xmm1, eax      ; Move mask to xmm4
    xorps xmm0, xmm1    ; Flip sign bit of xmm0
    .float_neg_end:

    xor rcx, rcx
    cvttss2si ecx, xmm0 ; decimal
    cvtsi2ss xmm1, ecx
    subss xmm0, xmm1

    ; rdi -> char *str
    ; ecx -> int dec
    ; xmm0 -> float f
    ; [base2] -> int base
    ; rsi -> int i

    lea rbx, [buffer]
    ; rbx -> char *buffer

    cmp ecx, 0
    jnz .buff_loop_begin
    mov [rbx+rsi], byte '0'
    inc rsi
    jmp .buff_loop_end
    .buff_loop_begin:
    push rdi
    lea rdi, [DIGITS]
    .buff_loop:
    mov eax, ecx
    cdq
    idiv [base2]
    mov ecx, eax

    mov al, [rdi+rdx]

    mov [rbx+rsi], al
    inc rsi

    cmp ecx, 0
    jg .buff_loop
    pop rdi
    .buff_loop_end:

    cmp [is_negative2], 0
    jz ._is_negative_end
    mov [rbx+rsi], byte '-'
    inc rsi
    ._is_negative_end:

    ;; Reverse the string
    mov rcx, 0 ; ecx -> int j
    mov rdx, rsi ; edx -> int k
    sub rdx, 1
    .reverse_loop:
    mov al, [rbx+rdx]
    mov [rdi+rcx], al
    inc rcx
    dec rdx
    cmp rcx, rsi
    jl .reverse_loop

    ;; Decimal part
    comiss xmm0, [XMM_FLOAT_ZERO]
    jna .decimal_part_end

    mov [rdi+rsi], byte '.'
    inc rsi

    mov rcx, 6 ; int precision
    lea rbx, [DIGITS]
    xor rdx, rdx; int digit

    .div_loop:
    cmp rcx, 0
    jng .div_loop_end
    comiss xmm0, [XMM_FLOAT_ZERO]
    jna .div_loop_end
    dec rcx

    cvtsi2ss xmm1, [base2]
    mulss xmm0, xmm1
    cvttss2si edx, xmm0
    mov al, [rbx+rdx]

    mov [rdi+rsi], al
    inc rsi

    cvtsi2ss xmm1, edx
    subss xmm0, xmm1

    jmp .div_loop

    .div_loop_end:
    .decimal_part_end:

.end:
    mov [rdi+rsi], byte 0
    ret


;;;;;;; ARITMETIC PROCEDURES
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
    xorps xmm2, xmm2
    comiss xmm1, xmm2
    jz .div_by_zero

    divss   xmm0, xmm1
    ret

    .div_by_zero:
    xorps   xmm0, xmm0
    ret

;;;;;;; HELPER PROCEDURES
switch_char:
    ; expects: al
    ; changes: [dig], [dot_found], [is_negative]
    cmp al, ' '
    jz .char_space
    cmp al, '0'
    jz .char_zero
    cmp al, '1'
    jz .char_one
    cmp al, '2'
    jz .char_two
    cmp al, '3'
    jz .char_three
    cmp al, '4'
    jz .char_four
    cmp al, '5'
    jz .char_five
    cmp al, '6'
    jz .char_six
    cmp al, '7'
    jz .char_seven
    cmp al, '8'
    jz .char_eight
    cmp al, '9'
    jz .char_nine
    cmp al, 'a'
    jz .char_ten
    cmp al, 'A'
    jz .char_ten
    cmp al, 'b'
    jz .char_eleven
    cmp al, 'B'
    jz .char_eleven
    cmp al, 'c'
    jz .char_twelve
    cmp al, 'C'
    jz .char_twelve
    cmp al, 'd'
    jz .char_thirteen
    cmp al, 'D'
    jz .char_thirteen
    cmp al, 'e'
    jz .char_fourteen
    cmp al, 'E'
    jz .char_fourteen
    cmp al, 'f'
    jz .char_fifteen
    cmp al, 'F'
    jz .char_fifteen
    cmp al, '-'
    jz .char_hiphen
    cmp al, '.'
    jz .char_dot
    jmp .switch_char_end

.char_space:
    mov [dig], -1
    jmp .switch_char_end
.char_zero:
    mov [dig], 0
    jmp .switch_char_end
.char_one:
    mov [dig], 1
    jmp .switch_char_end
.char_two:
    mov [dig], 2
    jmp .switch_char_end
.char_three:
    mov [dig], 3
    jmp .switch_char_end
.char_four:
    mov [dig], 4
    jmp .switch_char_end
.char_five:
    mov [dig], 5
    jmp .switch_char_end
.char_six:
    mov [dig], 6
    jmp .switch_char_end
.char_seven:
    mov [dig], 7
    jmp .switch_char_end
.char_eight:
    mov [dig], 8
    jmp .switch_char_end
.char_nine:
    mov [dig], 9
    jmp .switch_char_end
.char_ten:
    mov [dig], 10
    jmp .switch_char_end
.char_eleven:
    mov [dig], 11
    jmp .switch_char_end
.char_twelve:
    mov [dig], 12
    jmp .switch_char_end
.char_thirteen:
    mov [dig], 13
    jmp .switch_char_end
.char_fourteen:
    mov [dig], 14
    jmp .switch_char_end
.char_fifteen:
    mov [dig], 15
    jmp .switch_char_end
.char_hiphen:
    mov [dig], -1
    mov [is_negative], 1
    jmp .switch_char_end
.char_dot:
    mov [dig], -1
    mov [dot_found], 1
    jmp .switch_char_end

.switch_char_end:
    ret

