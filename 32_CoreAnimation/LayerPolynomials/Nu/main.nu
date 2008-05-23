;; file main.nu
;; discussion Entry point for a Nu program.
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(set MARGIN 10)

(global M_PI 3.1415927)
(global hypot (NuBridgedFunction functionWithName:"hypot" signature:"ddd"))
(global random (NuBridgedFunction functionWithName:"random" signature:"l"))
(global cos (NuBridgedFunction functionWithName:"cos" signature:"dd"))
(global sin (NuBridgedFunction functionWithName:"sin" signature:"dd"))

(class PolynomialView is NSView
     (ivar (id) polynomials (BOOL) blasted)
     
     (- (id)initWithFrame:(NSRect)frame is
        (super initWithFrame:frame)
        (set @polynomials (array))
        (set @blasted NO)
        self)
     
     (- (void)resizeAndRedrawPolynomialLayers is
        (set b ((self layer) bounds))
        (set b (CGRectInset b MARGIN MARGIN))
        (NSAnimationContext beginGrouping)
        ((NSAnimationContext currentContext) setDuration:0)
        (set polynomialLayers ((self layer) sublayers))
        (polynomialLayers each:
             (do (layer)
                 (layer setFrame:(list ((layer frame) 0)
                                       ((layer frame) 1)
                                       (b 2)
                                       (b 3)))
                 (layer setNeedsDisplay)))
        (NSAnimationContext endGrouping))
     
     (- (void)setFrameSize:(NSSize)newSize is
        (super setFrameSize:newSize)
        (unless (self inLiveResize))
        (self resizeAndRedrawPolynomialLayers))
     
     (- (void)viewDidEndLiveResize is
        (self resizeAndRedrawPolynomialLayers))
     
     (- (void)blastem:(id)sender is
        (NSAnimationContext beginGrouping)
        ((NSAnimationContext currentContext) setDuration:3.0)
        (set polynomialLayers ((self layer) sublayers))
        (polynomialLayers each:
             (do (layer)
                 (if @blasted
                     (then (set p (list MARGIN MARGIN)))
                     (else (set p (self randomOffViewPosition))))
                 (layer setPosition:p)))
        (NSAnimationContext endGrouping)
        (self willChangeValueForKey:"blasted")
        (set @blasted (not @blasted))
        (self didChangeValueForKey:"blasted"))
     
     (- (NSPoint)randomOffViewPosition is
        (set bounds (self bounds))
        (set radius (hypot (bounds third) (bounds fourth)))
        (set angle (* 2.0 M_PI (/ (% (random) 360) 360.0)))
        (list (* radius (cos angle)) (* radius (sin angle))))
     
     (- (void)createNewPolynomial:(id)sender is
        (set p ((Polynomial alloc) init))
        (@polynomials addObject:p)
        (set layer (CALayer layer))
        (set b ((self layer) bounds))
        (set b (CGRectInset b MARGIN MARGIN))
        (layer setAnchorPoint:'(0 0))
        (layer setFrame:b)
        (layer setDelegate:p)
        (layer setCornerRadius:12)
        (layer setBorderColor:(p color))
        (layer setBorderWidth:3.5)
        ((self layer) addSublayer:layer)
        (layer display)
        (set anim (CABasicAnimation animationWithKeyPath:"position"))
        (anim setFromValue:(NSValue valueWithPoint:(self randomOffViewPosition)))
        (anim setToValue:(NSValue valueWithPoint:(list MARGIN MARGIN)))
        (anim setDuration:1.0)
        (set f (CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear))
        (anim setTimingFunction:f)
        (layer addAnimation:anim forKey:"whatever"))
     
     (- (void)deleteRandomPolynomial:(id)sender is
        (set polynomialLayers ((self layer) sublayers))
        (if (or (eq polynomialLayers nil) (eq (polynomialLayers count) 0))
            (NSBeep)
            (return))
        (set i (% (random) (polynomialLayers count)))
        (set toPoint (self randomOffViewPosition))
        (set layerToPull (polynomialLayers objectAtIndex:i))
        (set anim (CABasicAnimation animationWithKeyPath:"position"))
        (anim setValue:layerToPull forKey:"representedPolynomialLayer")
        (anim setFromValue:(NSValue valueWithPoint:(NSMakePoint MARGIN MARGIN)))
        (anim setToValue:(NSValue valueWithPoint:toPoint))
        (anim setDuration:1.0)
        (set f (CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear))
        (anim setTimingFunction:f)
        (anim setDelegate:self)
        (layerToPull addAnimation:anim forKey:"whatever")
        (layerToPull setPosition:toPoint))
     
     (- (void)animationDidStop:(id)anim finished:(BOOL)flag is
        (NSLog "deleting polynomial")
        ;; FIXME: layer flashes at Position 0,0 before removal
        (set layerToPull (anim valueForKey:"representedPolynomialLayer"))
        (set p (layerToPull delegate))
        (@polynomials removeObjectIdenticalTo:p)
        (layerToPull removeFromSuperlayer))
     
     (- (void)drawRect:(NSRect)rect is
        (set bounds (self bounds))
        ((NSColor whiteColor) set)
        (NSBezierPath fillRect:bounds)))

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
