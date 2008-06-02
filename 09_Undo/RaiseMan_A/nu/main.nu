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
        (self setEmployees:(array))
        self)
        
    (- (void) startObservingPerson: (id) person is
        (person addObserver:self
                 forKeyPath:"personName"
                    options:NSKeyValueObservingOptionOld
                    context:nil)
        (person addObserver:self
                 forKeyPath:"expectedRaise"
                    options:NSKeyValueObservingOptionOld
                    context:nil))
                    
    (- (void) stopObservingPerson: (id) person is
        (person removeObserver:self forKeyPath:"personName")
        (person removeObserver:self forKeyPath:"expectedRaise"))

    (- (void) insertObject: (id) p inEmployeesAtIndex: (int) r is
        ;; Register the undo
        (set undo (self undoManager))
        ((undo prepareWithInvocationTarget:self) 
            removeObjectFromEmployeesAtIndex:r)
        (unless (undo isUndoing)
            (undo setActionName:"Insert Person"))
        ;; Add the person to the array
        (self startObservingPerson:p)
        (@employees insertObject:p atIndex:r))

    (- (void) removeObjectFromEmployeesAtIndex: (int) r is
        (set p (@employees r))
        (set undo (self undoManager))
        ((undo prepareWithInvocationTarget:self)
            insertObject:p inEmployeesAtIndex:r)
        (unless (undo isUndoing)
            (undo setActionName:"Delete Person"))
        (self stopObservingPerson:p)
        (@employees removeObjectAtIndex:r))

    (- (void) setEmployees: (id) arr is
        (@employees each:(do (p) (self stopObservingPerson:p)))
        (set @employees arr)
        (@employees each:(do (p) (self startObservingPerson:p))))

    (- (void) changeKeyPath: (id) keyPath ofObject: (id) obj toValue:(id) newValue is
        (obj setValue:newValue forKeyPath:keyPath))
      
    (- (void) observeValueForKeyPath: (id) keyPath ofObject: (id) obj
                              change: (id) change context: (id) context is
        (set undo (self undoManager))
        (set oldValue (change objectForKey:NSKeyValueChangeOldKey))
        (if (eq oldValue (NSNull null))
            (set oldValue nil))
        (NSLog "oldValue = #{oldValue}")
        ((undo prepareWithInvocationTarget:self)
            changeKeyPath:keyPath ofObject:obj toValue:oldValue)
        (undo setActionName:"Edit"))

     (- (id) windowNibName is "MyDocument")
     
     (- (void) windowControllerDidLoadNib: (id) aController is
        (super windowControllerDidLoadNib:aController)
        ;; Add any code here that needs to be executed once the windowController has loaded the document's window.
        ))

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
