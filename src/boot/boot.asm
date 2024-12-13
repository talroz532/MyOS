[BITS 16]
[ORG 0x7c00]

CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

start:
    jmp main

main:
    cli ; clear interrupts
    xor ax, ax ; initialize registers
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00 ; set stack pointer at 0x7c00
    sti ; enable interrupts
    jmp load_protectedMode ; Load protected mode func


; Include gdt.asm directly
%include "./src/boot/gdt.asm"


load_protectedMode:
    cli ; clear interrupts
    lgdt [gdt_descriptor] ; load GDT struct
    mov eax, cr0 ;enable protected mode by changing the value of cr0 low bit
    or al, 1
    mov cr0, eax
    mov eax, cr0
    test al, 1 ; Check if the lowest bit of CR0 is set (Protected Mode)
    jz pm_error ; If not, jump to pm_error

    jmp CODE_OFFSET:protectedMode_main ;Far jump to switch to protected mode

; Display error message
gdt_error:
    mov si, error_msg_gdt
    call print
    cli
    hlt

; Display error message
pm_error:
    mov si, error_msg_pm
    call print
    cli
    hlt

[BITS 32]
protectedMode_main: ; Switching to 32-bit PM from 16
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x10000
    mov esp, ebp

    ; Enabling A20 line for memory access above 1MB
    in al, 0x92  ; Read from the system control port
    or al, 2     
    out 0x92, al ; Write the modified value back to the port

    jmp $


; Print function for error messages
print:
    lodsb ; loads byte at ds:si to AL register and increments SI
    cmp al, 0x0
    je done
    mov ah, 0x0E
    int 0x10
    jmp print

done:
    cli
    hlt ; Stop further CPU execution

error_msg_gdt: db 'Error: GDT loading failed!', 0
error_msg_pm: db 'Error: Failed to enter protected mode!', 0




times 510 - ($ - $$) db 0
dw 0xAA55
