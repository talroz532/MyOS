[BITS 16]
[ORG 0x7c00]

CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

main:
    jmp gdt_error
    cli                  ; Clear interrupts
    xor ax, ax           ; Initialize registers
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00       ; Set stack pointer at 0x7c00
    sti

    mov si, msg_boot     ; Set SI to point to the string
    call print          ; Call print function

load_protectedMode:

    cli ; clear interrupts
    lgdt [gdt_descriptor] ; load GDT struct
    mov eax, cr0 ; Enable Protected Mode by changing CR0 low bit
    or eax, 1
    mov cr0, eax

    ; Ensure Protected Mode is enabled
    mov eax, cr0
    test al, 1
    jz gdt_error

    jmp CODE_OFFSET:protectedMode_main ; Far jump to flush prefetch queue

[BITS 32]
protectedMode_main:

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

    ; Verify A20 line
    mov ax, 0x1234
    mov [0x00007E00], ax
    cmp ax, [0x00007E00]
    jne pm_error

    mov [0x00107E00], ax
    cmp ax, [0x00107E00]
    jne pm_error

    jmp $ ; Hang if everything is successful

gdt_error:
    mov si, error_msg_gdt
    call print
    jmp $

pm_error:
    mov si, error_msg_pm
    call print
    jmp $

%include "src/boot/boot_print.asm"
%include "src/boot/gdt.asm"

msg_boot: db 'Start loading Boot...', 0x0
error_msg_gdt: db 'Error: GDT loading failed!', 0x0
error_msg_pm: db 'Error: Failed in Protected Mode initialization!', 0x0

times 510 - ($ - $$) db 0
dw 0xAA55
