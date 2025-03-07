section .data
    prompt1 db "Enter the first string (3 characters): ", 0
    prompt1_len equ $ - prompt1

    prompt2 db "Enter the second string (3 characters): ", 0
    prompt2_len equ $ - prompt2

    newline db 10

section .bss
    str1 resb 4   ; Buffer for the first string (3 chars + null terminator)
    str2 resb 4   ; Buffer for the second string (3 chars + null terminator)
    output resb 2 ; Buffer for ASCII output (1 digit + newline)

section .text
    global _start

_start:
    ; Prompt for the first string
    mov eax, 4         ; sys_write
    mov ebx, 1         ; stdout
    mov ecx, prompt1   ; Message to print
    mov edx, prompt1_len
    int 0x80           ; Call kernel

    ; Read the first string
    mov eax, 3         ; sys_read
    mov ebx, 0         ; stdin
    mov ecx, str1      ; Buffer to store the string
    mov edx, 4         ; Max bytes to read (3 chars + newline)
    int 0x80           ; Call kernel

    ; Prompt for the second string
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, prompt2_len
    int 0x80

    ; Read the second string
    mov eax, 3
    mov ebx, 0
    mov ecx, str2
    mov edx, 4
    int 0x80

    ; Initialize variables
    xor ebx, ebx       ; Bit difference count = 0
    mov esi, str1      ; Address of str1
    mov edi, str2      ; Address of str2
    mov ecx, 3         ; Length of the strings (3 chars)

compare_loop:
    mov al, [esi]      ; Load byte from str1
    xor al, [edi]      ; XOR with byte from str2
    call count_bits    ; Count set bits in AL
    inc esi            ; Move to next byte in str1
    inc edi            ; Move to next byte in str2
    loop compare_loop  ; Repeat for all bytes

    ; Convert bit count (EBX) to ASCII
    add bl, '0'        ; Convert to ASCII ('0' + count)
    mov [output], bl   ; Store in output buffer
    mov [output+1], byte 10 ; Add newline

    ; Print result
    mov eax, 4         ; sys_write
    mov ebx, 1         ; stdout
    mov ecx, output    ; Buffer to print
    mov edx, 2         ; Length (1 digit + newline)
    int 0x80           ; Call kernel

    ; Exit
    mov eax, 1         ; sys_exit
    xor ebx, ebx       ; Exit code 0
    int 0x80           ; Call kernel

; Count 1s in AL (Hamming weight)
count_bits:
    xor edx, edx       ; Clear counter
bit_count_loop:
    test al, 1         ; Check LSB
    jz skip_inc
    inc edx            ; Increment count if bit is 1
skip_inc:
    shr al, 1          ; Shift right
    jnz bit_count_loop ; Repeat if AL is not zero
    add ebx, edx       ; Add count to total
    ret
