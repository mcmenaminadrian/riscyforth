loadmodule ./modules/xframe/xfb.so

variable screen
variable win
variable gc

variable bpixel
variable wpixel
variable rootw

: winname S" My Window" drop ;
: iconname S" HI" drop ;


: showx11
." Starting..."
XOPENDISPLAY 0= abort" Cannot connect to X11"
XDEFAULTSCREEN screen !
screen @ XBLACKPIXEL bpixel !
screen @ XWHITEPIXEL wpixel !
." Point A" CR
XDEFAULTROOTWINDOW rootw !
." Point B" CR
rootw @ 0 0 200 300 5 wpixel @ bpixel @ XCREATESIMPLEWINDOW win !
win @ 0= if abort" Failed to create X11-window" then ." X11-window created." CR
." Point C" CR
win @ winname iconname 0 0 0 0 0 XSETWMPROPERTIES
." Point D" CR
win @ 0 XSELECTINPUT
." Point E" CR
win @ 0 0 XCREATEGC gc !
." Point F" CR
gc @ wpixel @ XSETBACKGROUND
." Point G" CR
gc @ bpixel @ XSETFOREGROUND
." Point H" CR
win @ XCLEARWINDOW
." Point I" CR
win @ XMAPRAISED
;
