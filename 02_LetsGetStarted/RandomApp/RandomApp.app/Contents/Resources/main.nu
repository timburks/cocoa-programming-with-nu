;; randomapp.nu

;; Rewritten from Cocoa Programming Third Edition
;; and Tim Burks original RandomApp in Nu.

;; Various things we need to include for Nu
(load "Nu:nu")		;; basics
(load "Nu:cocoa")	;; cocoa definitions
(load "Nu:menu")	;; menu generation

;; Start by building the interface in Interface Builder
;; See the MainMenu.nib file in English.lproj/

;; Now, create a class Foo with appropriate variables and actions
(class Foo is NSObject
     (ivar (id) textField)
     
     (- (void) seed: (id) sender is
        (NuMath srandom:((NSCalendarDate calendarDate) timeIntervalSince1970))
        (@textField setStringValue:"generator seeded"))
     
     (- (void) generate: (id) sender is
        (@textField setIntValue:(+ 1 (% (NuMath random) 100)))))

;; Create an instance of Foo in Interface Builder, give it seed: and
;;  generate: actions and a textField outlet. Connect these to the
;;  appropriate interface elements.

;; this makes the application window take focus when we've started it from the terminal
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
