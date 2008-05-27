;; file main.nu
;; discussion Entry point for a Nu program.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(set SHOW_CONSOLE_AT_STARTUP nil)

(class BigLetterView is NSView
     (ivar (id) bgColor (id) string)
     (ivar-accessors)
     
     (- (id)initWithFrame:(NSRect)frame is
        (super initWithFrame:frame)
        (NSLog "initWithFrame:")
        (set @bgColor (NSColor yellowColor))
        (set @string " ")
        (set $view self)
        self)
     
     (- (void)drawRect:(NSRect)rect is
        (set bounds (self bounds))
        (@bgColor set)
        (NSBezierPath fillRect:bounds)
        (if (and (eq ((self window) firstResponder) self)
                 (NSGraphicsContext currentContextDrawingToScreen))
            (NSGraphicsContext saveGraphicsState)
            (NSSetFocusRingStyle NSFocusRingOnly)
            (NSBezierPath fillRect:bounds)
            (NSGraphicsContext restoreGraphicsState)))
     
     (- (BOOL)isOpaque is
        (NSLog "isOpaque")
        YES)
     
     (- (BOOL)acceptsFirstResponder is
        (NSLog "Accepting")
        YES)
     
     (- (BOOL)resignFirstResponder is
        (NSLog "Resigning")
        (self setNeedsDisplay:YES)
        YES)
     
     (- (BOOL)becomeFirstResponder is
        (NSLog "Becoming")
        (self setNeedsDisplay:YES)
        YES)
     
     (- (void)keyDown:(id)e is
        (self interpretKeyEvents:(NSArray arrayWithObject:e)))
     
     (- (void)insertText:(id)s is
        (self setString:s))
     
     (- (void)insertTab:(id)sender is
        ((self window) selectNextKeyView:nil))
     
     (- (void)insertBacktab:(id)sender is
        ((self window) selectPreviousKeyView:nil))
     
     (- (void)deleteBackward:(id)sender is
        (self setString:" ")))

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
