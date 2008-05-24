;; file main.nu
;; discussion Entry point for a Nu program.
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class AppController is NSObject
     (ivar (id) outputView (id) hostField (id) startButton (id) task (id) pipe)
     
     (- (void)startStopPing:(id)sender is
        (if @task
            (then (@task interrupt))
            (else (set @task ((NSTask alloc) init))
                  (@task setLaunchPath:"/sbin/ping")
                  (@task setArguments:(array "-c10" (@hostField stringValue)))
                  (set @pipe ((NSPipe alloc) init))
                  (@task setStandardOutput:@pipe)
                  (set fh (@pipe fileHandleForReading))
                  (set nc (NSNotificationCenter defaultCenter))
                  (nc removeObserver:self)
                  (nc addObserver:self
                      selector:"dataReady:"
                      name:NSFileHandleReadCompletionNotification
                      object:fh)
                  (nc addObserver:self
                      selector:"taskTerminated:"
                      name:NSTaskDidTerminateNotification
                      object:@task)
                  (@task launch)
                  (@outputView setString:"")
                  (fh readInBackgroundAndNotify))))
     
     (- (void)appendData:(id)d is
        (set s ((NSString alloc) initWithData:d encoding:NSUTF8StringEncoding))
        (set ts (@outputView textStorage))
        (ts replaceCharactersInRange:(list (ts length) 0) withString:s))
     
     (- (void)dataReady:(id)note is
        (set data ((note userInfo) valueForKey:NSFileHandleNotificationDataItem))
        (NSLog "dataReady:#{(data length)}")
        (if (data length)
            (self appendData:data))
        (if @task
            ((@pipe fileHandleForReading) readInBackgroundAndNotify)))
     
     (- (void)taskTerminated:(id)note is
        (NSLog "taskTerminated:")
        (set @task nil)
        (@startButton setState:0)))

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
