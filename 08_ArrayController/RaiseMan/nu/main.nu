(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class Person is NSObject
     (ivar (id) personName (float) expectedRaise)
     (ivar-accessors)
     
     (- (id) init is
        (super init)
        (set @expectedRaise 5.0)
        (set @personName "New Person")
        self)
     
     (- (void) setNilValueForKey: (id) key is
        (if (key isEqual:"expectedRaise")
            (self setExpectedRaise:0.0)
            (else (super setNilValueForKey:key)))))

(class MyDocument is NSDocument
     (ivar (id) employees)
     
     (- (id) init is
        (super init)
        (set @employees (array))
        (return self))
     
     (- (id)windowNibName is "MyDocument")
     
     (- (void)windowControllerDidLoadNib:(id)windowController is
        (super windowControllerDidLoadNib:windowController)
        ;; user interface preparation code
        )
     
     (- (void) setEmployees: (id) a is
        (set @employees a)))

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
