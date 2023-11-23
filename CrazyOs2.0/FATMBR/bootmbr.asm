[ORG 0x0600]

TOTALSECTORS EQU 0x00EE2000;00EFF800
TRACK_PER_HEAD EQU 971
NUM_HEADS EQU 255
SECTORS_PER_TRACK EQU 63

jmp BootStrap

BUFFER_NAME db "MSDOS5.0";compatibilidade
BPB:
	BytesPerSector dw 0x0200 ;512 Bytes por setor
	SectorsPerCluster db 1 ;Setores por Cluster
	ReservedSectors dw 7 ;setores reservados + setores escondidos
	TotalFATs db 2;2 fat original + copia
	MaxRootEntries dw 0x0200 ;512 entradas de diretórios
	TotalSectorSmall dw 0x0000 ;Cilindros x Setores(FAT16)
	MediaDescriptor db 0xF8 ;tipo de midia disquete
	SectorsPerFAT dw 246 ;setores por fat
	SectorsPerTrack dw SECTORS_PER_TRACK ;setores por trilha
	NumHeads dw NUM_HEADS ;Quantidade de cbeçotes
	HiddenSectors dd 0x00000000 ;setores escondidos
	TotalSectorsLarge dd TOTALSECTORS ; setores largos(FAT 32)
EBPB:
	DriveNumber db 0x80 ;primeira ordem de boot
	Flags db 0x00 ;reservdo para winnt
	Signature db 0x28 ;assinatura
	BUFFER_VOLUME_ID dd 0x00000000 ;id do volume
	VolumeLabel db "CrazyOs    " ;label do disc
	SystemID db "FAT16   " ; fililesystem
	
DAPSizeOfPacket db 10h
DAPReserved db 00h
DAPTransfer dw 0001h
DAPBuffer dd 00000000h
DAPStart dq 0000000000000000h

PartOffset dw 0x0000


BootStrap: 
	cli ;disable interuptions
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, ax
	.CopyLower
		mov cx, 0x0100
		mov si, 0x7C00
		mov di, 0x0600
		rep movsw
		jmp 0:LowStart
		
LowStart:
	sti
	mov byte[DriveNumber], dl
	.CheckPartitions:
		mov bx, PART1
		mov cx, 4
		.CKPTLoop:
			mov al, byte[bx]
			test al, 0x80
			jnz .CKPTFound
			add bx, 0x10
			loop .CKPTLoop
			jmp ERROR
		.CKPTFound:
			mov word[PartOffset], bx
			add bx, 8
		.ReadVBR:
			mov EAX, DWORD[bx]
			mov bx, 0x7C00
			mov cx, 1
			call ReadSectors
			
		.JumpToVBR:
			cmp word[0x7DFE], 0xAA55
			jne ERROR
			mov si, word[PartOffset]
			mov dl, byte[DriveNumber]
			jmp 0x7C00
			
	ReadSectors:
		mov word[DAPBuffer], bx
		mov word[DAPBuffer+2], es
		mov word[DAPStart], ax
	_MAIN:
		mov di, 0x0005
	_SECTORLOOP:
		push ax
		push bx
		push cx
		
		push si
		mov ah, 42h
		mov dl, 0x80 
		mov si, DAPSizeOfPacket
		int 13h
		pop si
		jnc _SUCCESS 
		xor ax, ax ;bios reset disk
		int 13h
		dec di
		
		pop cx
		pop bx
		pop ax
		
		jnz _SECTORLOOP
		jmp ERROR
		
	_SUCCESS:
		pop cx
		pop bx
		pop ax
		
		add bx, word[BytesPerSector]
		cmp bx, 0x0000
		jne _NEXTSECTOR
		
		push ax
		mov ax, es
		add ax, 0x1000
		mov es, ax
		pop ax
		
	_NEXTSECTOR:
		inc ax
		mov word[DAPBuffer], bx
		mov word[DAPStart], ax
		loop _MAIN
ret

ERROR:
	int 18h

;Codigo de incialização
	
TIMES 0x1BE-($-$$) DB 0

OFFSETL EQU 3;1536 bites de deslocmento
LBASIZE EQU (TOTALSECTORS - (OFFSETL + 1));0xEE1FFC tamaho logico da partição

;Partition Table

PART1:

	FLAG: db 0x80;inicializavel
	HCS_BEGIN: db 0x00, 0x00, 0x03;cabeçote 0, 0, 3 
	PART_TYPE: db 0x0B;fat
	HCS_DINAL db 0xFE 0xCA 0xFF ;254, 970, 63
	LBA_BEGIN dd OFFSETL;deslocamento
	PART_SIZE dd LBASIZE ;Tamanhoo de setores lba


PT2   dd 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;Partição 2
PT3   dd 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;Partição 3
PT4   dd 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;Partição 4

MBR_SIGNATURE:
	
	TIMES 510-($-$$) DB 0
	DW 0xAA55