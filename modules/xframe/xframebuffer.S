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

	CODEHEADER XCREATESIMPLEWINDOW, XDEFAULTSCREEN, 0x01
	# (n n n n n n n n -- n)
	# display, parent, x, y, width, height, border_width, border, background
	la t0, x11_display
	ld a0, 0(t0)	# display
	ld a1, 0(sp)	# parent
	ld a2, 8(sp)	# x
	ld a3, 16(sp)	# y
	ld a4, 24(sp)	# width
	ld a5, 32(sp)	# height
	ld a6, 40(sp)	# border_width
	ld a7, 48(sp)	# border
	addi sp, sp, 56	# stack now points to background
	call XCreateSimpleWindow
	sd a0, 0(sp)	# return window
	TAILMOD t1

	CODEHEADER XSETWMPROPERTIES, XCREATESIMPLEWINDOW, 0x01
	#( n n n n n n n n --- )
	# display, window, window_name, icon_name, argv, argc, normal_hint, wm_hints, class_hints
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)	# window
	ld a2, 8(sp)	# window_name (XTextProperty*)
	ld a3, 16(sp)	# icon name (XTestProperty*)
	ld a4, 24(sp)	# argv (char**)
	ld a5, 32(sp)	# argc
	ld a6, 40(sp)	# normal hints (normal_hints*)
	ld a7, 48(sp)	# wm_hints (specifies WMHints*)
	addi sp, sp, 56	# stack now points to class_hints (XClassHint*)
	call XSetWMProperties
	addi sp, sp, 8
	TAILMOD t1

	CODEHEADER XSELECTINPUT, XSETWMPROPERTIES, 0x01
	#(n n --)
	# display, window, event_mask
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)	# window
	ld a2, 8(sp)	# event_mask
	call XSelectInput
	addi sp, sp, 16
	TAILMOD t1

	CODEHEADER XCREATEGC, XSELECTINPUT, 0x01
	#(n n n - n)
	# display, drawable, valuemask, values
	# returns graphics context
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)	# drawable
	ld a2, 8(sp)	# valuemask
	ld a3, 16(sp)	# values
	call XCreateGC
	addi sp, sp, 16
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XSETBACKGROUND, XCREATEGC, 0x01
	#(n n --)
	# display, gc, background
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	ld a2, 8(sp)
	call XSetBackground
	addi sp, sp, 12
	TAILMOD t1 

	CODEHEADER XSETFOREGROUND, XSETBACKGROUND, 0x01
	#(n n --)
	# display, gc, foreground
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	ld a2, 8(sp)
	call XSetForeground
	addi sp, sp, 12
	TAILMOD t1 

	CODEHEADER XCLEARWINDOW, XSETFOREGROUND, 0x01
	#(n --)
	# display, window
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	call XClearWindow
	addi sp, sp, 8
	TAILMOD t1
	
	CODEHEADER XMAPRAISED, XCLEARWINDOW 0x01
	#(n --)
	# display, window
	la t0, x11_display
	ld a0, 0(t0)
	ld a1, 0(sp)
	call XMapRaised
	addi sp, sp, 8
	TAILMOD t1

	CODEHEADER XDEFAULTROOTWINDOW, XMAPRAISED, 0x01
	#(-- n)
	la t0, x11_display
	ld a0, 0(t0)
	call XDefaultRootWindow
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER XDEFAULTGC, XDEFAULTROOTWINDOW, 0x01
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
