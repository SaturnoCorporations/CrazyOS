%INCLUDE "lib\memory.lib"
[BITS SYSTEM]
[ORG BOOTLOADER]

jmp BootLoaderRoutines
%INCLUDE "lib\TIMEMANIPULATION.codf"

MSG1 db "Crazy Os Bootloader Loaded,Jumping to kernel...", 0

BootLoaderRoutines:
	call JumpLine
	mov si, MSG1
	call PrintString
	Timer 0000h, 88B8h, 100
	call LoadSystem
	jmp 0800h:KERNEL

LoadSystem:
	mov ah, 02h
	mov al, KERNEL_NUM_SECTORS ;Setores do Disco
	mov ch, 0
	mov cl, KERNEL_SECTOR
	mov dh, 0
	mov dl, 80h
	mov bx, 0800h
	mov es, bx
	mov bx, KERNEL
	int 13h
ret

PrintString:
	mov ah, 0eh
	mov al, [si]
	print:
		int 10h
		inc si
		mov al, [si]
		cmp al, 0
	jne print
ret

JumpLine:
	mov ah, 0eh
	mov al, 0ah
	int 10h
	mov al, 0dh
	int 10h
ret
	
times 510 - ($-$$) db 0
dw 0xAA55