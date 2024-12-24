
print:
    lodsb
    cmp al, 0x0
    je done
    mov ah,0x0E
    int 0x10
    jmp print

done:
    mov al, 0X0A ;add new line
    mov ah, 0x0E
    int 0x10
    mov al, 0x0D ;add carriage return
    mov ah, 0x0E
    int 0x10
    ret
