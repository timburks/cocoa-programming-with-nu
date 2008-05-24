;; file main.nu
;; discussion Entry point for a Nu program.
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class MyDocument is NSDocument
     (ivar (id) tableView (id) filenames)
     
     (- (id)windowNibName is "MyDocument")
     
     (- (void)windowControllerDidLoadNib:(id) aController is
        (super windowControllerDidLoadNib:aController)
        (@tableView reloadData))
     
     (- (BOOL)readFromURL:(id)absoluteURL ofType:(id)typeName error:(id *)outError is
        (set filename (absoluteURL path))
        (set task ((NSTask alloc) init))
        (task setLaunchPath:"/usr/bin/zipinfo")
        (task setArguments:(array "-1" filename))
        (task setStandardOutput:(set outPipe ((NSPipe alloc) init)))
        (task launch)
        (set data ((outPipe fileHandleForReading) readDataToEndOfFile))
        (task waitUntilExit)
        (set status (task terminationStatus))
        (if (!= status 0)
            (unless (eq outError nil)
                    (set eDict (dict NSLocalizedFailureReasonErrorKey "zipinfo exited abnormally"))
                    (outError setValue:(NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:eDict)))
            (return NO))
        ;; Convert to a string
        (set aString ((NSString alloc) initWithData:data encoding:NSUTF8StringEncoding))
        ;; Break the string into lines
        (set @filenames (aString componentsSeparatedByString:"\n"))
        ;; In case of revert
        (@tableView reloadData)
        YES)
     
     (- (int)numberOfRowsInTableView:(id)tv is
        (@filenames count))
     
     (- (id)tableView:(id)tv objectValueForTableColumn:(id)tc row:(int)row is
        (@filenames objectAtIndex:row)))

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
