(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class AppController is NSObject
     (ivar (int) fido)
     (ivar-accessors) ;; The Nu equivalent of @synthesize
     
     (- (id) init is
        (super init)
        ;; Set the global variable $ac equal to the appController for easy access in the console.
        (set $ac self)
        (self setValue:5 forKey:"fido")
		(set n (self valueForKey:"fido"))
		(NSLog "fido = #{n}")
        self)

	(- (void) incrementFido: (id) sender is
		;; We don't need to call willChangeValueForKey or didChangeValueForKey
		(set @fido (+ @fido 1))
		(NSLog "fido is now #{@fido}")))

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
