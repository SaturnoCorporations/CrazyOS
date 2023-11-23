%INCLUDE "lib\memory.lib"

[BITS SYSTEM]
[ORG KERNEL]

;Crazy Kernel V1.3

jmp SYSCALLS 

%INCLUDE "lib\Curmanipulation.codf"
%INCLUDE "lib\VIDEOCFG.codf"
%INCLUDE "LanguageConfig\LANGUAGE.cocf"
%INCLUDE "lib\DRAWER.codf"
%INCLUDE "lib\TIMEMANIPULATION.codf"
%INCLUDE "lib\THEMEMANAGER.codf"
%INCLUDE "lib\SHELLMANAGER.codf"
%INCLUDE "lib\DESKTOPMANAGER.codf"
%INCLUDE "lib\INOUTDEVICES.codf"
%INCLUDE "lib\MOUSELIB.codf"


SYSCALLS:
	call ConfigSeg
	call ConfigSta
	CursorReset
	call VideoConfigure
	call DrawBackground
	call PrintEffect
	call LoadingBar	
	call LoadingBarEffect
	call SYSCALLS2
jmp $

ConfigSeg:
	cld
	mov ax, es
	mov ds, ax
ret

ConfigSta:
	cli
	mov ax, 7D00h
	mov ss, ax
	mov sp, 3000h
	sti
ret
	
PrintString:
	pusha
	mov ah, 09h
	mov bh, [PAGINATION]
	mov cx, 1
	mov al, [si]
	print:
		int 10h
		IncLine
		inc si
		IncRow
		mov ah, 09h
		mov al, [si]
		cmp al, 0
		jne print
	popa
ret

PrintEffect:
	mov si, SysMesage1
	mov bl, 15
	mov byte[Line], 2
	mov byte[Row], 2
	CursorUpload
	call PrintString
	call Print2Prep
ret

Print2Prep:
	mov dh, byte[Line]
	sub dh, 14
	mov byte[Line], dh
	xor dh, dh
	mov dh, byte[Row]
	add dh, 2
	mov byte[SaveRow], dh
	mov bh, byte[SaveRow]
	mov byte[Row], bh 
	CursorUpload
	mov si, SysMesage2
	call PrintString2
	xor dh, dh
	mov dh, byte[Line]
	add dh, 1
	mov byte[Line], dh
	xor bh, bh
	mov bh, [SaveRow]
	mov byte[Row], bh
	CursorUpload
	mov si, SysMesage3
	call PrintString2
	call CursorReset
ret


PrintString2:
	pusha
	mov ah, 09h
	mov bh, [PAGINATION]
	mov cx, 1
	mov al, [si]
	print2:
		int 10h
		inc si
		IncRow
		mov ah, 09h
		mov al, [si]
		cmp al, 0
		jne print2
	popa
ret

LoadingBarEffect:
	mov ax, 0
	mov bx, word[BackHeight]
	sub bx, 9
	mov word[LoadingBarPositionY], bx
	mov byte[LoadingBarColor], 32
	BarEffectloop:
		inc ax
		mov word[LoadingBarWidht], ax
		pusha
		in al, 0x64
		out 0x64, al
		in al, 0x60
		cmp al, 0x41
		je SysMenu
		Timer 0000h, 3A98h, 1
		popa
		pusha
		call PutYourPosition
		popa
		cmp ax, word[BackWidht]
		jne BarEffectloop
ret











;Step 2








SYSCALLS2:
	call VideoConfigure
	call DrawBackground
	mov byte[Line], 12
	mov byte[Row], 5
	CursorUpload
	mov bl, 14
	mov si, SysMesage4
	call PrintString3
	mov byte[Line], 13
	mov byte[Row], 5
	CursorUpload
	mov bl, 14
	mov si, SysMesage5
	call PrintString3
	mov word[LoadingBarColor], 17
	call LoadingBar
	call LoadingBarEffect
	call SYSCALLS3
ret





PrintString3:
	pusha
	mov ah, 09h
	mov bh, [PAGINATION]
	mov cx, 1
	mov al, [si]
	print3:
		int 10h
		inc si
		IncRow
		mov ah, 09h
		mov al, [si]
		cmp al, 0
		jne print3
	popa
ret













;Step 3


SYSCALLS3:
	call BaseUI
	call DrawSquary
	mov bl, 255
	jmp KeyPress
ret


BaseUI:
	call ThemeTypeChanger
	call VideoConfigure
	call DrawBackgroundWallpaper
	call TaskBar
	call IconsBar
	call ShowHour
	call LoadIconsInBar
	call DrawRecycleBin
ret

SysMenu:
	Timer 0000h, 1388h, 30
	mov byte[Line], 0
	mov byte[Row], 0
	CursorUpload
		call VideoConfigure
		call DrawBackground
		mov bl, 13
		mov si, SysMenu1
		call PrintString2
		mov byte[Line], 1
		mov byte[Row], 0
		CursorUpload
		mov si, SysMenu2
		call PrintString2
		mov byte[Row], 0
		mov byte[Line], 2
		CursorUpload
		mov si, SysMenu3
		call PrintString2
		mov byte[Row], 0
		mov byte[Line], 3
		CursorUpload
		mov bl, 4
		mov si, SysMenu4
		call PrintString2
		mov byte[Row], 0
		mov byte[Line], 4
		CursorUpload
		mov si, SysMenu5
		call PrintString2
		SysMenuLoop:
			in al, 0x64
			out 0x64, al
			in al, 0x60
			cmp al, 0x3B
			je SysMenuOpt1
			cmp al, 0x3C
			je SysMenuOpt2
			cmp al, 0x01
			je SysMenuOpt3
			cmp al, 0x5B
			je SysMenuOpt4
jmp SysMenuLoop

SysMenuOpt1:
	mov ah, 53h
	mov al, 07h
	mov bx, 0001h
	mov cx, 03h
int 15h
;mov byte[ErrorType]
;call RedScreenOfDeath	
	 
SysMenuOpt2:
	mov byte[Line], 0
	mov byte[Row], 0
	CursorUpload
	call VideoConfigure
	call DrawBackground
	mov bl, 1
	mov si, SysInfo1
	call PrintString2
	mov byte[Line], 1
	mov byte[Row], 0
	CursorUpload
	mov si, SysInfo2
	call PrintString2
	mov byte[Line], 2
	mov byte[Row], 0
	CursorUpload
	mov si, SysInfo3
	call PrintString2
	mov bl, 3
	mov byte[Line], 3
	mov byte[Row], 0
	CursorUpload
	mov si, SysInfo4
	call PrintString2
	SysINFOLoop:
		in al, 0x64
		out 0x64, al
		in al, 0x60
		cmp al, 0x01
		je SysMenu
		jne SysINFOLoop
	
SysMenuOpt3:
	mov ax, 0040h
	mov ds, ax
	mov ax, 1234h
	mov [0072h], ax
	jmp 0FFFFh:0000h
	
SysMenuOpt4:
	call VideoConfigure
	call DrawBackground
	jmp SYSCALLS3