%include "lib.inc"
%define keysize 8
global find_word
section .text


find_word: 
	push r12
	push r13
	mov r12, rdi
	mov r13, rsi
    .loop:
        test r13, r13       
        jz .notfound
                                 
        mov rdi, r12

        lea rsi, [r13 + keysize] ; Calculate the address of the next element
	mov rsi, [rsi] ; Load the value at the calculated address into rsi
        
	call string_equals  ; returns 1 if equal, else 0

        test rax, rax       
        jnz .found          

        mov r13, [r13]      ; Move to the next element
        jmp .loop

    .found:
        mov rax, r13        ; Return the address of the key
        jmp .ret
        
    .notfound:
        xor rax, rax        ; Set 0
    .ret:
    	pop r13
    	pop r12
    	ret

        
