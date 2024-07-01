%include "lib.inc"
%include "dict.inc"
%include "words.inc"

%define keysize 8
%define size_buff 256

section .bss
buff: resb size_buff					; create buffer allocation

section .rodata
	input_error: db "Well, well, well. Your input is incorrect", 0
	not_found: db "Well, well, well. There is no such key", 0


section .text

global _start

_start:		
	mov rdi, buff 		; Read an address of buff to rdi			
	mov rsi, size_buff	; Write buffer size to rsi		
	call read_word		; Read the word or return 0, that it is impossible		
	test rax, rax 
	jz .input_error 	; Rax == 0?		
	
	mov rdi, buff 		; Read a word to rdi		
	mov rsi, element	; Write key to rsi		
	call find_word		; Find the word or return 0		
	test rax, rax
	jz .not_found 		

	mov rdi, rax       	; Read an address of key to rdi		
	add rdi, keysize         	
	push rdi
	call string_length 	; Get string length
	pop rdi				 			
	add rdi, keysize    
	inc rdi   		             
	jmp .end

	.input_error:
		mov rdi, input_error 	; Input error
		jmp .enderr

	.not_found:
		mov rdi, not_found 	; Found error	
		jmp .enderr

		
	.enderr:
		call print_error 	; Print error message	
		xor rdi, rdi			
		call exit

	.end:
		call print_string 		
		call print_newline		
		call exit
