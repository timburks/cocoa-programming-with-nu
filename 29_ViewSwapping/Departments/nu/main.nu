;; file main.nu
;; discussion Entry point for a Nu program.
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class ManagingViewController is NSViewController
     (ivar (id) managedObjectContext)
     (- (void)setManagedObjectContext:(id)moc is
        (set @managedObjectContext moc)))

(class EmployeeViewController is ManagingViewController
     (- (id)init is
        (unless (super initWithNibName:"EmployeeView" bundle:nil)
                (return nil))
        (self setTitle:"Employees")
        self))

(class DepartmentViewController is ManagingViewController
     (- (id)init is
        (unless (super initWithNibName:"DepartmentView" bundle:nil)
                (return nil))
        (self setTitle:"Departments")
        self))

(class MyDocument is NSPersistentDocument
     (ivar (id) box (id) popUp (id) viewControllers)
     
     (- (void)prepareViewControllers is
        (set @viewControllers (array (((DepartmentViewController alloc) init)
                                      set:(managedObjectContext:(self managedObjectContext)))
                                     (((EmployeeViewController alloc) init)
                                      set:(managedObjectContext:(self managedObjectContext))))))
     
     (- (id)init is
        (unless (super init) (return nil))
        (self prepareViewControllers)
        self)
     
     (- (void)windowControllerDidLoadNib:(id)windowController is
        (super windowControllerDidLoadNib:windowController)
        (set menu (@popUp menu))
        (@viewControllers eachWithIndex:
             (do (vc i)
                 (set mi ((NSMenuItem alloc) initWithTitle:(vc title) action:"changeViewController:" keyEquivalent:""))
                 (mi setTag:i)
                 (menu addItem:mi)
                 (NSLog "added #{mi} to #{menu}")))
        (self displayViewController:(@viewControllers objectAtIndex:0))
        (@popUp selectItemAtIndex:0))
     
     (- (void)displayViewController:(id)vc is
        (set w (@box window))
        (set ended (w makeFirstResponder:w))
        (unless ended
                (NSBeep)
                (return))
        (set v (vc view))
        (set currentSize ((((@box contentView) frame) cdr) cdr))
        (set newSize (((v frame) cdr) cdr))
        (set deltaWidth (- (newSize first) (currentSize first)))
        (set deltaHeight (- (newSize second) (currentSize second)))
        (set windowFrame (w frame))
        (set windowFrame (list (windowFrame first)
                               (- (windowFrame second) deltaHeight)
                               (+ (windowFrame third) deltaWidth)
                               (+ (windowFrame fourth) deltaHeight)))
        (@box setContentView:nil)
        (w setFrame:windowFrame display:YES animate:YES)
        (@box setContentView:v)
        ;; Put the view controller in the responder chain
        (v setNextResponder:vc)
        (vc setNextResponder:@box))
     
     (- (void)changeViewController:(id)sender is
        (self displayViewController:(@viewControllers objectAtIndex:(sender tag))))
     
     (- (id)windowNibName is "MyDocument"))

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