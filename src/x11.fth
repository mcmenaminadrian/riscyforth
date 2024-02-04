loadmodule ./modules/xframe/xfb.so

variable screen
variable win
variable gc

variable bpixel
variable wpixel
variable rootw
variable wmdelete
variable countup

: winname S" HELLO WORLD" ;
: iconname S" HI" drop ;


: showx11
DECIMAL
." Starting..." CR
48 CELLS ALLOCATE 0= IF wmdelete ! ELSE abort" memory allocation failed" THEN
hex wmdelete @ . decimal
0 win !
0 gc !
-1 screen !
XOPENDISPLAY 0= abort" Cannot connect to X11"
XDEFAULTSCREEN screen !
." Screen:" screen @ . CR
screen @ XROOTWINDOW rootw !
screen @ XBLACKPIXEL bpixel !
screen @ XWHITEPIXEL wpixel !
WPIXEL @ [ hex FF0000 decimal ]  1 400 400 90 120 rootw @ XCREATESIMPLEWINDOW win !
hex 28043 decimal win @ XSELECTINPUT
win @ XMAPWINDOW
screen @ XDEFAULTGC gc !
0 countup !
BEGIN
TRUE
WHILE
wmdelete @  XNEXTEVENT
100 100 200 200 gc @ win @ XFILLRECTANGLE
countup s>d <# #s #> . 50 10 gc @  win @ XDRAWSTRING
countup @ 1+ countup !
REPEAT
wmdelete @ FREE
XCLOSEDISPLAY
;

