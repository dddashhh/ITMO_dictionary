global exit
global string_length
global print_string
global print_error 
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy


section .text
 
 
; Принимает код возврата и завершает текущий процесс
exit: 
    xor rax, rax
    mov al, BYTE [rdi] 
    syscall             
    ret

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0  
    je .ret                 
    inc rax                  
    jmp .loop                
.ret:
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
	push rdi
	test rdi, rdi
    call string_length
	pop rdi
	mov rdx, rax
	mov rsi, rdi
	mov rax, 1
	mov rdi, rax     
	syscall
	ret

; Принимает код символа и выводит его в stdout
print_char:
	push rdi
	mov rax, 1       
	mov [rsp], rdi
	mov rdi, rax
	mov rsi, rsp
	mov rdx, rax
	syscall
	pop rdi
  	ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov al, 0xA    ; ASCII code for newline character
    call print_char
    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r10, 10          
	xor rcx, rcx
    mov rax, rdi        
    sub rsp, 33         
    mov rcx, 20         
    mov byte[rsp+rcx], 0    
.loop:
    xor rdx, rdx    
    div r10          
    add dl, '0'      
    dec rcx
    mov byte[rsp+rcx], dl       
    test rax, rax      
    jne .loop       
.print:
    add rcx, rsp    
    mov rdi, rcx    
    call print_string   
    add rsp, 33
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    cmp rdi, 0     
    jge .not_negative       
    push rdi        
    mov rdi, '-'    
    call print_char 
    pop rdi         
    neg rdi         
.not_negative:
    call print_uint     
    ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rcx, rcx                
.loop:
    mov al, byte[rdi+rcx]   
    cmp al, byte[rsi+rcx]   
    jne .not_equals         
    test al, al               
    je .equals
    inc rcx         
    jmp .loop       
.equals:
    mov rax, 1      
    ret
.not_equals:
    xor rax, rax      
	ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
	push 0
    mov eax, 0       
    mov edi, 0       
    mov rsi, rsp     
    mov edx, 1       
    syscall
    pop rax
    ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    push r12		                
    mov r12, rdi										
    push r13		                
    mov r13, rdi
    push r14		                
    mov r14, rsi
.space: 				
    call read_char
    cmp al, 0x9
    je .space
    cmp al, 0xA
    je .space
    cmp al, 0x20
    je .space
.symbols: 	    						
    test rax, rax               
	je .stop
    cmp al, 0x9
    je .stop
    cmp al, 0xA
    je .stop
    cmp al, 0x20
    je .stop
    dec r14 					
    test r14, r14
    jz .long
    mov byte[r13], al 			 
    inc r13
    call read_char
    jmp .symbols
.stop:
    mov byte[r13], 0 			
    sub r13, r12				
    mov rdx, r13
    mov rax, r12
    jmp .ret
.long:
    xor rax, rax
.ret:
    pop r12
    pop r13
    pop r14
    ret
 

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint: 				
    xor rax, rax
    xor rdx, rdx
    xor rcx, rcx
.loop:
    mov dl, byte[rdi + rcx]        
	cmp dl, "0"                     
    js .ret
    cmp dl, "9"
    jg .ret
    sub dl, "0"					    
    imul rax, 10				    
    add rax, rdx
    inc rcx
    jmp .loop
.ret:
	mov rdx, rcx
    ret





; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    cmp byte[rdi], "-" 	
    jne parse_uint 			
    cmp byte [rdi], "+"
    je .plus
    cmp byte[rdi], 0x2F
    jg .minus			
.minus: 					
	inc rdi
    call parse_uint
	neg rax
	inc rdx
	ret
.plus:
	inc rdi
    call parse_uint
	ret 

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
  xor rax, rax      
.loop:
    cmp rax, rdx
    jge .long   
    mov cl, byte [rdi + rax] 
	cmp cl, '0'             
    je .ret
    mov byte [rsi + rax], cl 
    test cl, cl
    jz .ret 
    inc rax
    jmp .loop  
.long:
    xor rax, rax
.ret:
    ret

; Принимает указатель на строку, выводит в stderr
print_error:
    push rdi            
    call string_length  
    pop rsi             
    mov rdx, rax        
    mov rax, 1          ;installing the pointer
    mov rdi, 0x2	;stdout          
    syscall
    ret
