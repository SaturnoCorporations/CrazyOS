[BITS 16]
[ORG 0x0000]

FAT_SECTORS EQU 246-1
ENTRY_SIZE EQU 32
SECTOR_SIZE EQU 512
RESERVED EQU 7

Boot_MBR:

FAT1:
	_FirstSector1:
		db 0xF8, 0xFF, 0xFF, 0xFF
		times (SECTOR_SIZE) - (4) DB 0
	_RestSector1:
		times (FAT_SECTORS * SECTOR_SIZE) DB 0
		
FAT2:
	_FirstSector2:
		db 0xF8, 0xFF, 0xFF, 0xFF
		times (SECTOR_SIZE) - (4) DB 0
	_RestSector2:
		times (FAT_SECTORS * SECTOR_SIZE) DB 0
		
FAT_ROOTDIRECTORY:
	
	db 0x20,  0x20,  0x20,  0x20,  0x20,  0x20,  0x20,  0x20
	db 0x20,  0x20,  0x20,  0x00,  0x00,  0x00,  0x00,  0x00
	db 0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00
	db 0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00
	
	times (SECTOR_SIZE * ENTRY_SIZE) - (ENTRY_SIZE * 1) db 0
	
Data_Area:

	times (1024 * 1024 * ENTRY_SIZE) - (Data_Area - Boot_MBR) - (SECTOR_SIZE * RESERVED) DB 0
	
End_Of_Disk:
	db '*EOD'