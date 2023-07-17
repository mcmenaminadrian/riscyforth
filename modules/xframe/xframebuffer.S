# x11 framebuffer module
# copyright, Adrian McMenamin, (c) 2023
# reuse licensed under V2 of the GNU GPL
  .include "../../macros.S"
  .section .bss
    .comm NEXTMOD, 8
    .comm x11_display, 8

  .section .text
  .balign 8

  #initialisation code for this module
  starter_xframebuffer:
	PUSH ra
	call getNextAddress	#get the address for tail return
	la t0, NEXTMOD
	sd a0, 0(t0)		#store the tail return address
	la a0, XOPENDISPLAY	#get address of this module
	addi a0, a0, -56
	PUSH a0
	li t3, 0xFFFFFFFFFFFFF000
	and a0, a0, t3
	li a1, 0x100
	li a2, 0x7	#rw permissions
	call mprotect
	POP a0
	addi a1, a0, 16
	PUSH a1
	call getDictionary
	POP a1
	sd a0, 0(a1)		#update lead word
	la a0, XDEFAULTGC	#new end of dictionary
	addi a0, a0, -56
	call setDictionary	#return new tail of dictionary to caller
	#setup extension writing - commented out for now
#	la a0, WA_TWOLITERAL
#	la a1, extender_2literal
#	call  setExtenders
#	la a0, WA_TO
#	la a1, extender_2to
#	call setExtenders
	POP ra
	fence.i
	ret

	CODEEND XOPENDISPLAY, 0x01
	#( -- n)
	li a0, 0
	call XOpenDisplay
	la t0, x11_display
	sd a0, 0(t0)
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XBLACKPIXEL, XOPENDISPLAY, 0x01
	#(n -- n)
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	call XBlackPixel
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XWHITEPIXEL, XBLACKPIXEL, 0x01
	#(n -- n)
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	call XWhitePixel
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XDEFAULTSCREEN, XWHITEPIXEL, 0x01
	#(-- n)
	la t0, x11_display
	ld a0, 0(t0)
	call XDefaultScreen
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XDEFAULTGC, XDEFAULTSCREEN, 0x01
	#(n -- n)
	ld a1, 0(sp)
	la t0, x11_display
	ld a0, 0(t0)
	call XDefaultGC
	sd a0, 0(sp)
	TAILMOD t1


.section .init_array
.balign 8
.8byte starter_xframebuffer
