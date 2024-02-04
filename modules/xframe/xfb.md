# Describing the xfb (xfb.so) module

This module provides a Forth interface to the X11 libraries. Commands are described below

## x11_display

   Variable to hold the DISPLAY returned by XOPENDISPLAY


## XOPENDISPLAY

   ( -- n)

   Calls X11 `XOpenDisplay` with a NULL parameter and so returns the value of the DISPLAY environment variable.
   This word stores its result in `x11_display`.


## XBLACKPIXEL

   (n -- n)

   Calls `XBlackPixel`. Takes display value from `X11_display` and screen number from stack. Returns black pixel value for specified screen.


## XWHITEPIXEL

   (n -- n)

   Calls `XWhitePixel`. Takes display value from `X11_display` and screen number from stack. Returns white pixel value for specified screen.


## XDEFAULTSCREEN

    ( -- n)

    Calls `XDefaultScreen`. Takes display value from `x11_display`. Returns a default screen number.


## XCREATESIMPLEWINDOW

    (n n n n n n n n n -- n)

    Calls `XCreateSimpleWindow`. Takes display value from `x11_display`.

    Parameters (in order of increasing stack depth):

    - Parent
    - X
    - Y
    - Width
    - Height
    - Border_width
    - Border
    - Background
    - Foreground

    Returns window ID of its created window.


## XSETWMPROPERTIES

    (n n n n n n n n -- )

    Calls `XSetWMProperties`. Takes display value from `x11_display`.

    Parameters (in order of increasing stack depth):

    - Window
    - Window_name (pointer to a null terminated string)
    - icon_name (another pointer)
    - argv
    - argc
    - normal_hints
    - wm_hints
    - class_hints


## XFILLRECTANGLE

    (n n n n n -- )

    Calls `XFillRectangle`. Takes display value from `x11_display`.

    Parameters In order of increasing stack depth):

    - drawable
    - gc
    - x
    - y
    - width
    - height


## XDRAWSTRING

    (n, n, n, n, n -- )

    Calls `XDrawString`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - drawable
    - gc
    - x
    - y
    - string
    - length


## XNEXTEVENT

    (n -- )
    
    Calls `XNextEvent`. Takes display value form `x11_display`.
    
    Parameter: XEvent*


## XSELECTINPUT

    (n n -- )

    Calls `XSelectInput`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - window
    - event_mask


## XCREATEGC

    (n n n -- )

    Calls `XCreateGC`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - drawable
    - valuemask
    - values


## XSETBACKGROUND

   ( n n -- )

    Calls `XSetBackground`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - gc
    - background


## XSETFOREGROUND

   ( n n -- )

    Calls `XSetForeground`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - gc
    - foreground


## XCLEARWINDOW

   ( n -- )

    Calls `XClearWindow`. Takes display value form `x11_display`.
    
    Parameter: window


## XMAPRAISED

   ( n -- )

    Calls `XMapRaised`. Takes display value form `x11_display`.
    
    Parameter: window


## XDEFAULTROOTWINDOW

   (-- n)

    Calls `XDeafultRootWindow`. Takes display value form `x11_display`.

    Returns root window for the default screen


## XROOTWINDOW

   (n -- n)

    Calls `XRootWindow`. Takes display value form `x11_display`.

    Parameter: screen
    
    Returns root window for the specified screen


## XMAPWINDOW

   ( n -- )

    Calls `XMapWindow`. Takes display value form `x11_display`.
    
    Parameter: window


## XGETWMPROTOCOLS

   ( n n n -- n)

    Calls `XGetWMProtocols`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - window
    - protocols_return (Atom **)
    - count_return (int *)


## XINTERNATOM

   ( n n -- n)

    Calls `XInternAtom`. Takes display value form `x11_display`.
    
    Parameters In order of increasing stack depth):

    - atom_name
    - only_if_exists

    Returns atome idenifier associated with the atom name


## XFLUSH

    ( -- )

    Calls `XFlush`. Takes display value form `x11_display`.


## XDCLOSEDISPLAY

    ( -- )

    Calls `XCloseDisplay`. Takes display value form `x11_display`.


## XDEFAULTGC

    (n -- n)

    Calls `XDefualtGC`. Takes display value form `x11_display`.
    
    Parameter: screen_number

    Returns the default graphics context for the root window of the specified screen.
