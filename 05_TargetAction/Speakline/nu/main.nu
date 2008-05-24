;; main.nu

;; Rewritten from Cocoa Programming, Second Edition
;; and Tim Burks' various Nu examples

;; Various things we need to include for Nu
(load "Nu:nu")		;; basics
(load "Nu:cocoa")	;; cocoa definitions
(load "Nu:menu")	;; menu generation

;; Start by building the interface in Interface Builder
;; See the MainMenu.nib file in English.lproj/

;; @class AppController
;; @description This controller class accepts the sayIt:, stopIt:
;;  and changeTextColor: actions.
(class AppController is NSObject
     (ivar (id) textField
           (id) colorWell
           (id) speechSynth)
     
     (- (id) init is
        (super init)
        (set @speechSynth ((NSSpeechSynthesizer alloc) initWithVoice:nil))
        self)
     
     (- awakeFromNib is
        (@colorWell setColor:(@textField textColor)))
     
     (- changeTextColor:(id)sender is
        (@textField setTextColor:(@colorWell color)))
     
     (- sayIt:(id)sender is
        (@speechSynth startSpeakingString:(@textField stringValue)))
     
     (- stopIt:(id)sender is
        (@speechSynth stopSpeaking)))

;; Create an instance of Foo in Interface Builder, give it seed: and
;;  generate: actions and a textField outlet. Connect these to the
;;  appropriate interface elements.

;; this makes the application window take focus when we've started it from the terminal
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
