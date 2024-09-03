.model small
.stack 100h
.data
    prompt db "Enter a decimal number between 0-999: $"
    binaryValue db "Binary Value : $" 
    hexValue db "Hexa Value : ","$"
    romanValue db "Roman Value : ",10,13,"$" 
    new_line db 10,13,'$'
    number dw 0
    hex  db  "0123456789ABCDEF"
    result db 5 dup(0)
    
.code
main proc
    
    ; .startup
    mov ax, @data  
    mov ds, ax
    
    ; Display the prompt
    mov ah, 09h          
    lea dx, prompt
    int 21h
    
    mov bl, 10
    
input_loop:
    ;loop to read the decimal number
    mov dx, 0
    mov ah, 01h
    int 21h
    cmp al, 13          ; Check for 'Enter' key (carriage return)
    je convert_to_binary   ;jumb if equal
    sub al, 48          ; This converts the ASCII value of the digit to its actual integer value by subtracting 48 (30h), which is the ASCII code for '0'
    mov ah, 0
    mov dx, ax
    mov ax, number
    mul bl
    add ax, dx
    mov number, ax
    
    jmp input_loop
    
convert_to_binary:
    mov ah, 9
    lea dx, new_line
    int 21h
    
    mov ax, number
    mov cx, 0
    mov dx, 0
    
binary_conversion:
    cmp ax, 0
    je print_binary
    
    mov bx, 2          ;ax =ax/2 ... shift right.
    div bx
    push dx            ; Save the binary digit to the stack
    inc cx             ; Count the number of digits
    mov dx, 0
    jmp binary_conversion

print_binary:
    mov ah, 9
    lea dx, binaryValue
    int 21h
    xor bx, bx         
    
binary_output_loop:
    cmp cx, 0
    je print_hex
    
    pop dx
    add dx, 48         ; Convert digit to ascii
    
    mov ah, 2          ; Print digit saved in dl
    int 21h
    
    dec cx
    shl bx, 1          ; Shift left BX to store the binary digit
    test dl, '1'
    jz skip_add
    inc bx             ; Add 1 if the binary digit is 1
skip_add:
    jmp binary_output_loop

print_hex:
    mov ah, 09h
    lea dx, new_line
    int 21h
    
    mov ah, 09h 
    lea dx, hexValue
    int 21h
    mov bx,number
    
    call PrintHex
    call romanAll

PrintHex proc
    ; Extract the high nibble of BH
    mov al, bh
    shr al, 4
    call ConvertToHex

    ; Extract the low nibble of BH
    mov al, bh
    and al, 0Fh               ; mask with 0Fh
    call ConvertToHex

    ; Extract the high nibble of BL
    mov al, bl
    shr al, 4
    call ConvertToHex

    ; Extract the low nibble of BL
    mov al, bl
    and al, 0Fh
    call ConvertToHex

    ret
PrintHex endp

ConvertToHex proc
    cmp al, 9
    jbe DigitIsNumber
    add al, 7              ; For 'A'-'F'
DigitIsNumber:
    add al, '0'            ; Convert to ASCII

    ; Print the character
    mov dl, al
    mov ah, 02h
    int 21h

    ret 
ConvertToHex endp



romanAll proc
    lea dx, new_line
    mov ah, 09h
    int 21h
    lea dx, romanValue
    mov ah, 09h
    int 21h
    push bx
    mov ax, bx
    mov cx, 100
    xor dx, dx
    div cx ; ax = bx/100
    mov bx, ax
    cmp bx, 0
    je tens  
    call romanHundred
    push dx  
    lea dx, result
    mov ah, 09h
    int 21h
    pop dx
    
    tens:
        mov ax, dx
        xor dx, dx
        mov cx, 10
        div cx ; ax = dx/10
        mov bx, ax
        cmp bx, 0 
        je ones 
        call romanTens
        push dx  
        lea dx, result
        mov ah, 09h
        int 21h 
        pop dx
    ones:
        mov bx, dx
        cmp bx, 0
        je finishAll 
        call roman 
        lea dx, result
        mov ah, 09h
        int 21h
        
        
    finishAll:
        jmp end_program
        pop bx
        romanAll endp


romanHundred proc
    cmp bx, 1
    je firstVal
    cmp bx, 2
    je secondVal
    cmp bx, 3
    je thirdVal
    cmp bx, 4
    je fourthVal
    cmp bx, 5
    je fiveVal
    cmp bx, 6
    je sixVal
    cmp bx, 7
    je sevenVal
    cmp bx, 8
    je eightVal      
    mov byte ptr result, 'C' 
    mov byte ptr result+1, 'M' 
    mov byte ptr result+2, '$' 
    jmp finish 
    firstVal:
        mov byte ptr result, 'C'  
        mov byte ptr result+1, '$'
        jmp finish 
    secondVal:
       mov byte ptr result, 'C' 
       mov byte ptr result+1, 'C' 
       mov byte ptr result+2, '$'
        jmp finish
    thirdVal:
        mov byte ptr result, 'C' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C' 
        mov byte ptr result+3, '$'
        jmp finish
    fourthVal:
        mov byte ptr result, 'C' 
        mov byte ptr result+1, 'D'
        mov byte ptr result+2, '$'
        jmp finish 
    fiveVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, '$'
        jmp finish
    sixVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, '$'
        jmp finish 
    sevenVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C'
        mov byte ptr result+3, '$' 
        jmp finish
    eightVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C'
        mov byte ptr result+3, 'C'
        mov byte ptr result+4, '$'
    finish: 
        ret
        romanHundred endp

romanTens proc
    cmp bx, 1
    je firstVal2
    cmp bx, 2
    je secondVal2
    cmp bx, 3
    je thirdVal2
    cmp bx, 4
    je fourthVal2
    cmp bx, 5
    je fiveVal2
    cmp bx, 6
    je sixVal2
    cmp bx, 7
    je sevenVal2
    cmp bx, 8
    je eightVal2      
    mov byte ptr result, 'X'
    mov byte ptr result+1, 'C'
    mov byte ptr result+2, '$'
    jmp finish2 
    firstVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, '$'
        jmp finish2 
    secondVal2:
    mov byte ptr result, 'X'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, '$'
        jmp finish2
    thirdVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, '$'
        jmp finish2
    fourthVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, 'L'
        mov byte ptr result+2, '$'
        jmp finish2 
    fiveVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, '$'
        jmp finish2
    sixVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, '$'
        jmp finish2 
    sevenVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, '$'
        jmp finish2
    eightVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, 'X'
        mov byte ptr result+4, '$'
    finish2:
        ret
        romanTens endp


roman proc
    cmp bx, 1
    je firstVal3
    cmp bx, 2
    je secondVal3
    cmp bx, 3
    je thirdVal3
    cmp bx, 4
    je fourthVal3
    cmp bx, 5
    je fiveVal3
    cmp bx, 6
    je sixVal3
    cmp bx, 7
    je sevenVal3
    cmp bx, 8
    je eightVal3      
    mov byte ptr result, 'I'
    mov byte ptr result+1, 'X'
    mov byte ptr result+2, '$'
    jmp finish3 
    firstVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, '$'
        jmp finish3 
    secondVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, '$'
        jmp finish3
    thirdVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, '$'
        jmp finish3
    fourthVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'V'
        mov byte ptr result+2, '$'
        jmp finish3 
    fiveVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, '$'
        jmp finish3
    sixVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, '$'
        jmp finish3 
    sevenVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, '$'
        jmp finish3
    eightVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, 'I'
        mov byte ptr result+4, '$'
    finish3:
        ret
        roman endp

end_program:
    mov ah, 09h
    lea dx, new_line
    int 21h
    mov ah, 4Ch
    int 21h

end main
