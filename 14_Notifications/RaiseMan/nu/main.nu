;; file main.nu
;; discussion Entry point for a Nu program.

(import Cocoa)        ;; bridgesupport
(load "console")      ;; interactive console
	
(set BNRTableBgColorKey "TableBackgroundColor")
(set BNREmptyDocKey "EmptyDocumentFlag")
(set BNRColorChangedNotification "BNRColorChanged")

(class AppController is NSObject
	(ivar (id) preferenceController)
	 
	 (+ (void) initialize is
		(set defaultValues (NSMutableDictionary dictionary))
		(set colorAsData (NSKeyedArchiver archivedDataWithRootObject:(NSColor yellowColor)))
		(defaultValues setObject: colorAsData forKey: BNRTableBgColorKey)
		(defaultValues setObject: (NSNumber numberWithBool:YES) forKey:BNREmptyDocKey)
		((NSUserDefaults standardUserDefaults) registerDefaults:defaultValues)
		(NSLog "registered: #{defaultValues}"))
     
     (- (void)showPreferencePanel:(id)sender is
        (unless @preferenceController
                (set @preferenceController ((PreferenceController alloc) init)))
        (NSLog "Showing #{@preferenceController}")
        (@preferenceController showWindow:self))

	(- (BOOL) applicationShouldOpenUntitledFile:(id)sender is
	   (NSLog "applicationShouldOpenUntitledFile")
	   ((NSUserDefaults standardUserDefaults) boolForKey:BNREmptyDocKey)))
	
(class PreferenceController is NSWindowController
     (ivar (id) colorWell (id) checkbox)
     
     (- (id)init is
        (unless (super initWithWindowNibName:"Preferences")
                (return nil))
        (set $p self)
        self)

	(- (id)tableBgColor is
		(set defaults (NSUserDefaults standardUserDefaults))
		(set colorAsData (defaults objectForKey:BNRTableBgColorKey))
		(NSKeyedUnarchiver unarchiveObjectWithData:colorAsData))
		
	(- (BOOL)emptyDoc is
		(set defaults (NSUserDefaults standardUserDefaults))
		(defaults boolForKey:BNREmptyDocKey))
     
     (- (void)windowDidLoad is
		(@colorWell setColor:(self tableBgColor))
		(@checkbox setState:(self emptyDoc)))
     
     (- (void)changeBackgroundColor:(id)sender is
		(set color (@colorWell color))
		(set colorAsData (NSKeyedArchiver archivedDataWithRootObject:color))
		(set defaults (NSUserDefaults standardUserDefaults))
		(defaults setObject:colorAsData forKey:BNRTableBgColorKey)
		
		(NSLog "sending color changed notification")
		(set nc (NSNotificationCenter defaultCenter))
		(set d (NSDictionary dictionaryWithObject:color forKey:"color"))
		
		(nc postNotificationName:BNRColorChangedNotification object:self userInfo:d))
		
	(- (void)changeNewEmptyDoc:(id)sender is
		(set defaults (NSUserDefaults standardUserDefaults))
		(defaults setBool:(checkbox state) forKey:BNREmptyDocKey)))     

(class Person is NSObject
		; @property (readwrite, copy) NSString *personName;
		; @property (readwrite) float expectedRaise;
     (ivar (id) personName (float) expectedRaise)
     (ivar-accessors)

     (- (id)init is
        (super init)
        (set @expectedRaise 5.0)
        (set @personName "New Person")
        self)
     
     (- (id)initWithCoder:(id)c is
        (super init)
        (set @personName (c decodeObjectForKey:"personName"))
        (set @expectedRaise (c decodeFloatForKey:"expectedRaise"))
        self)
     
     (- (void)encodeWithCoder:(id)c is
        (c encodeObject:@personName forKey:"personName")
        (c encodeFloat:@expectedRaise forKey:"expectedRaise")))
		
(class MyDocument is NSDocument
     (ivar (id) tableView (id) employeeController (id) employees)
     
     (- (id)init is
        (unless (super init) (return nil))
        (self setEmployees:(NSMutableArray array))

		(set nc (NSNotificationCenter defaultCenter))
		(nc addObserver:self
			selector:"handleColorChange:"
			name:BNRColorChangedNotification
			object:nil)
		(NSLog "registered for notification")
		self)
     
     (- (void)createEmployee:(id)sender is
        (set w (@tableView window))
        (set editingEnded (w makeFirstResponder:w))
        (unless editingEnded (return))
        (set undo (self undoManager))
        (if (undo groupingLevel)
            (undo endUndoGrouping)
            (undo beginUndoGrouping))
        
        (set p (@employeeController newObject))
        (@employeeController addObject:p)
        
        ;; In case the user has sorted the content array
        (@employeeController rearrangeObjects)
        
        ;; Find the row of the new object
        (set a (@employeeController arrangedObjects))
        (set row (a indexOfObjectIdenticalTo:p))
        
        ;; Start editing in the first column
        (@tableView editColumn:0 row:row withEvent:nil select:YES))
     
     (- (void)startObservingPerson:(id)person is
        (person addObserver:self forKeyPath:"personName" options:NSKeyValueObservingOptionOld context:nil)
        (person addObserver:self forKeyPath:"expectedRaise" options:NSKeyValueObservingOptionOld context:nil))
     
     (- (void)stopObservingPerson:(id)person is
        (person removeObserver:self forKeyPath:"personName")
        (person removeObserver:self forKeyPath:"expectedRaise"))
     
     (- (void)insertObject:(id)p inEmployeesAtIndex:(int)r is
        ;; Register the undo
        (set undo (self undoManager))
        ((undo prepareWithInvocationTarget:self)
         removeObjectFromEmployeesAtIndex:r)
        (unless (undo isUndoing) (undo setActionName:"Insert Person"))
        ;; Add the person to the array
        (self startObservingPerson:p)
        (@employees insertObject:p atIndex:r))
     
     (- (void)removeObjectFromEmployeesAtIndex:(int)r is
        (set p (@employees objectAtIndex:r))
        (set undo (self undoManager))
        ((undo prepareWithInvocationTarget:self) insertObject:p inEmployeesAtIndex:r)
        (unless (undo isUndoing) (undo setActionName:"Delete Person"))
        (self stopObservingPerson:p)
        (@employees removeObjectAtIndex:r))
     
     (- (void)setEmployees:(id)a is
        (if (eq a @employees) (return))
        (@employees each:(do (p) (self stopObservingPerson:p)))
        (set @employees a)
        (@employees each:(do (p) (self startObservingPerson:p))))
     
     (- (void)changeKeyPath:(id)keyPath ofObject:(id)obj toValue:(id)newValue is
        (obj setValue:newValue forKeyPath:keyPath))
     
     (- (void)observeValueForKeyPath:(id)keyPath ofObject:(id)obj change:(id)change context:(void *)context is
        (set undo (self undoManager))
        (set oldValue (change objectForKey:NSKeyValueChangeOldKey))
        (NSLog "oldValue = #{oldValue}")
        ((undo prepareWithInvocationTarget:self)
         changeKeyPath:keyPath
         ofObject:obj
         toValue:oldValue)
        (undo setActionName:"Edit"))
     
     (- (id)windowNibName is "MyDocument")
     
     (- (void)windowControllerDidLoadNib:(id) aController is
        (super windowControllerDidLoadNib:aController)
		(set defaults (NSUserDefaults standardUserDefaults))
		(set colorAsData (defaults objectForKey:BNRTableBgColorKey))
        (set color (NSKeyedUnarchiver unarchiveObjectWithData:colorAsData))
		(@tableView setBackgroundColor:color))
     
     (- (void)presentError:(id)error modalForWindow:(id)window delegate:(id)delegate didPresentSelector:(SEL)didPresentSelector contextInfo:(void *)contextInfo is
        (set ui (error userInfo))
        (set underlying (ui objectForKey:NSUnderlyingErrorKey))
        (NSLog "error = #{error}, userInfo = #{ui}, underlying info = #{(underlying userInfo)}")
        (super presentError:error
               modalForWindow:window
               delegate:delegate
               didPresentSelector:didPresentSelector
               contextInfo:contextInfo))
     
     (- (id)dataOfType:(id)typeName error:(id *)outError is
        ((@tableView window) endEditingFor:nil)
        (NSKeyedArchiver archivedDataWithRootObject:@employees))

     (- (BOOL)readFromData:(id)data ofType:(id)typeName error:(id *)outError is
        (set a nil)
        (try (set a (NSKeyedUnarchiver unarchiveObjectWithData:data))
             (catch (obj)
                    (if outError
                        (set d (dict NSLocalizedFailureReasonErrorKey "This file is corrupted like Noriega."))
                        (outError setValue:(NSError errorWithDomain:NSOSStatusErrorDomain
                                                    code:unimpErr
                                                    userInfo:d)))
                    (return NO)))
        (self setEmployees:a)
        YES)

	(- (void)handleColorChange:(id)note is
		(NSLog "notification arrived: #{note}")
		(set newColor ((note userInfo) objectForKey:"color"))
		(@tableView setBackgroundColor:newColor))
)

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