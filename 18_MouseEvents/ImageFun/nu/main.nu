;; file main.nu
;; discussion Entry point for a Nu program.
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(set random (NuBridgedFunction functionWithName:"random" signature:"l"))
(function min (a b) (if (< a b) then a else b))
(function max (a b) (if (> a b) then a else b))

(class AppController is NSObject
     (ivar (id) stretchView)
     
     (- (void)showOpenPanel:(id)sender is
        (set op (NSOpenPanel openPanel))
        (op beginSheetForDirectory:nil
            file:nil
            types:(NSImage imageFileTypes)
            modalForWindow:(@stretchView window)
            modalDelegate:self
            didEndSelector:"openPanelDidEnd:returnCode:contextInfo:"
            contextInfo:nil))
     
     (- (void)openPanelDidEnd:(id)op
        returnCode:(int)returnCode
        contextInfo:(void *)ci is
        (if (eq returnCode NSOKButton)
            (set path (op filename))
            (set image ((NSImage alloc) initWithContentsOfFile:path))
            (@stretchView setImage:image))))

(class StretchView is NSView
     (ivar (id) path (id) image (float) opacity (NSPoint) downPoint (NSPoint) currentPoint)
     
     (- (id)initWithFrame:(NSRect)frame is
        (unless (super initWithFrame:frame) (return nil))
        ;;     	srandom(time(NULL))
        (set @path ((NSBezierPath alloc) init))
        (@path setLineWidth:3.0)
        (set p (self randomPoint))
        (@path moveToPoint:p)
        (15 times:
            (do (i)
                (set p (self randomPoint))
                (@path lineToPoint:p)))
        (@path closePath)
        (set @opacity 1.0)
        self)
     
     (- (NSPoint)randomPoint is
        (set bounds (self bounds))
        (list (+ (bounds first) (% (random) ((bounds third) intValue)))
              (+ (bounds second) (% (random) ((bounds fourth) intValue)))))
     
     (- (void)drawRect:(NSRect)rect is
        (set bounds (self bounds))
        ((NSColor greenColor) set)
        (NSBezierPath fillRect:bounds)
        ((NSColor whiteColor) set)
        (@path fill)
        (if @image
            (set imageRect (append '(0 0) (@image size)))
            (set drawingRect (self currentRect))
            (puts "drawing image in #{imageRect} #{drawingRect}")
            (@image drawInRect:drawingRect
                    fromRect:imageRect
                    operation:NSCompositeSourceOver
                    fraction:@opacity)))
     
     (- (void)mouseDown:(id)event is
        (set p (event locationInWindow))
        (set @downPoint (self convertPoint:p fromView:nil))
        (set @currentPoint @downPoint)
        (self setNeedsDisplay:YES))
     
     (- (void)mouseDragged:(id)event is
        (set p (event locationInWindow))
        (set @currentPoint (self convertPoint:p fromView:nil))
        (self autoscroll:event)
        (self setNeedsDisplay:YES))
     
     (- (void)mouseUp:(id)event is
        (set p (event locationInWindow))
        (set @currentPoint (self convertPoint:p fromView:nil))
        (self setNeedsDisplay:YES))
     
     (- (NSRect)currentRect is
        (set minX (min (@downPoint first) (@currentPoint first)))
        (set minY (min (@downPoint second) (@currentPoint second)))
        (set maxX (max (@downPoint first) (@currentPoint first)))
        (set maxY (max (@downPoint second) (@currentPoint second)))
        (list minX minY (- maxX minX) (- maxY minY)))
     
     (- (void)setImage:(id)i is
        (set @image i)
        (set imageSize (i size))
        (set @downPoint '(0 0))
        (set @currentPoint imageSize)
        (self setNeedsDisplay:YES))
     
     (- (float)opacity is @opacity)
     
     (- (void)setOpacity:(float)f is
        (set @opacity f)
        (self setNeedsDisplay:YES)))

(set SHOW_CONSOLE_AT_STARTUP nil)

;; @class ApplicationDelegate
;; @discussion Methods of this class perform general-purpose tasks that are not appropriate methods of any other classes.
(class ApplicationDelegate is NSObject
     
     ;; This method is called after Cocoa has finished its basic application setup.
     ;; It instantiates application-specific components.
     ;; In this case, it constructs an interactive Nu console that can be activated from the application's Window menu.
     (- (void) applicationDidFinishLaunching:(id) sender is
        (set $console ((NuConsoleWindowController alloc) init))
        (if SHOW_CONSOLE_AT_STARTUP ($console toggleConsole:self))))

;; install the delegate and keep a reference to it since the application won't retain it.
((NSApplication sharedApplication) setDelegate:(set $delegate ((ApplicationDelegate alloc) init)))

;; this makes the application window take focus when we've started it from the terminal (or with nuke)
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)