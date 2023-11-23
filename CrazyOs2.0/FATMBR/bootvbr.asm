[BITS 16]
[ORG 0x0000]

TOTALSECTORS EQU 0x00EE2000;00EFF800
TRACK_PER_HEAD EQU 971
NUM_HEADS EQU 255
SECTORS_PER_TRACK EQU 63

jmp Boot_Begin

BUFFER_NAME db "MSDOS5.0";compatibilidade
BPB:
	BytesPerSector dw 0x0200 ;512 Bytes por setor
	SectorsPerCluster db 1 ;Setores por Cluster
	ReservedSectors dw 4;setores reservados + setores escondidos
	TotalFATs db 2;2 fat original + copia
	MaxRootEntries dw 0x0200 ;512 entradas de diretórios
	TotalSectorSmall dw 0x0000 ;Cilindros x Setores(FAT16)
	MediaDescriptor db 0xF8 ;tipo de midia disquete
	SectorsPerFAT dw 246 ;setores por fat
	SectorsPerTrack dw SECTORS_PER_TRACK ;setores por trilha
	NumHeads dw NUM_HEADS	;Quantidade de cbeçotes
	HiddenSectors dd 0x00000003 ;setores escondidos
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
		
DAPSTART DW 0x0000
FATSTART DW 0x0000
ROOTDIRSTART EQU (BUFFER_NAME)
ROOTDIRSIZE EQU (BUFFER_NAME+4)

BAD_CLUSTER EQU 0xFFF7
END_OF_CLUSTER1 EQU 0xFFF8
END_OF_CLUSTER2 EQU 0xFFFF
FCLUSTER_ENTRY EQU 0x001A
FSIZE_ENTRY EQU 0x001C
ROOT_SEGMENT EQU 0x07C0
FAT_SEGMENT EQU 0x17C0
KERNEL_SEGMENT EQU 0x0800
DIRECTORY_SIZE EQU 32
EXT_LENGHT EQU 3
NAME_LENGHT EQU 8

Extension db "COB" ;CrazyOs Binary
ClusterFile dw 0x0000
FileFound db 0
		
Boot_Begin:
	cli
	mov ax, ROOT_SEGMENT
	mov ds, ax
	mov es, ax
	mov ax, 0x0000
	mov ss, ax
	mov sp, 0x6000
	sti
	
	mov byte[DriveNumber], byte dl
	mov ax, 02h
	int 0x10
	
	call LoadRootDirectory
	call LoadFAT
	call SearchFile
	mov dl, byte[DriveNumber]
	
	jmp KERNEL_SEGMENT:0x0000
	
LoadRootDirectory:
	xor cx, cx
	mov ax, word[ReservedSectors]
	add ax, word[HiddenSectors]
	mov word[FATSTART], ax ;Fat Start=7
	
	mov ax, DIRECTORY_SIZE
	mul word[MaxRootEntries]
	div word[BytesPerSector]
	mov word[ROOTDIRSIZE], ax 
	mov cx, ax ;tamanho diretorio raiz = 32 Setores
	
	xor ax, ax
	mov al, byte[TotalFATs]
	mul word[SectorsPerFAT]
	add ax, word[FATSTART ;iniciodiretorio = 499
	mov word[ROOTDIRSTART], ax ;499
	
	push ax
	add ax, cx
	mov word[DATASTART], ax ;531
	mov ax, ROOT_SEGMENT
	mov es, ax
	pop ax
	
	mov bx, 0x0200
	call ReadLogicalSectors
ret

LoadFAT:
	mov ax, FAT_SEGMENT
	mov es, ax
	
	mov ax, word[FATSTART]
	mov cx, (246/2) ; 123
	call ReadLogicalSectors
ret

SearchFile:
	mov ax, ROOT_SEGMENT
	mov es, ax
	mov cx, word[MaxRootEntries]
ret
	
BOOT_FAILED:
	int 0x18
	
MBR_SIG:
	TIMES 510 - ($-$$) DB 0
	DB 0x55, 0xAA

