;; file main.nu
;; discussion Entry point for a Nu program.
;;
;; copyright Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.

(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(set AWS_ID "1CKE6MZ6S27EFQ458402")

(function stringForKind (k)
     (case k
           (NSXMLDocumentKind "Document")
           (NSXMLElementKind "Element")
           (NSXMLTextKind "Text")
           (else (k stringValue))))

;; To see the output of this function, look at the Nu console (command-L).
(function ShowTree (node level)
     (set kind (node kind))
     (set kindString (stringForKind kind))
     (level times:(do (i) (print "  ")))
     (if (eq kind NSXMLTextKind)
         (then (puts (+ kindString ": " (node stringValue))))
         (else (puts (+ kindString ": " (node name)))))
     ((node children) each:
      (do (child)
          (ShowTree child (+ 1 level)))))

(class AppController is NSObject
     (ivar (id) progress (id) searchField (id) tableView (id) doc (id) itemNodes)
     (ivar-accessors)
     
     (- (void)awakeFromNib is
        (@tableView setDoubleAction:"openItem:")
        (@tableView setTarget:self))
     
     (- (void)fetchBooks:(id)sender is
        ;; Show the user that something is going on
        (@progress startAnimation:nil)
        
        ;; Put together the request
        ;; See http://www.amazon.com/gp/aws/landing.html
        
        ;; Get the string and percent-escape for insertion into URL
        (set searchString ((@searchField stringValue) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding))
        (NSLog "searchString = #{searchString}")
        
        ;; Create the URL
        (set urlString "http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=#{AWS_ID}&SearchIndex=Books&Keywords=#{searchString}")
        (set url (NSURL URLWithString:urlString))
        (set urlRequest (NSURLRequest requestWithURL:url
                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                             timeoutInterval:30))
        
        ;; Fetch the XML response
        (set urlData (NSURLConnection sendSynchronousRequest:urlRequest
                          returningResponse:(set responsep (NuReference new))
                          error:(set errorp (NuReference new))))
        (unless urlData
                (NSRunAlertPanel "Error loading" ((errorp value) localizedDescription) nil nil nil)
                (return))
        
        ;; Parse the XML response
        (set @doc ((NSXMLDocument alloc) initWithData:urlData
                   options:0
                   error:errorp))
        (NSLog "doc = #{@doc}")
        
        (ShowTree @doc 0)
        
        (unless @doc
                (set alert (NSAlert alertWithError:(errorp value)))
                (alert runModal)
                (return))
        
        (set @itemNodes (@doc nodesForXPath:@"ItemSearchResponse/Items/Item" error:errorp))
        (unless @itemNodes
                (set alert (NSAlert alertWithError:(errorp value)))
                (alert runModal)
                (return))
        
        ;; Update the interface
        (@tableView reloadData)
        (@progress stopAnimation:nil))
     
     (- (void)openItem:(id)sender is
        (set row (@tableView clickedRow))
        (if (eq row -1) (return))
        (set clickedItem (@itemNodes row))
        (set urlString (self stringForPath:"DetailPageURL" ofNode:clickedItem))
        (set url (NSURL URLWithString:urlString))
        ((NSWorkspace sharedWorkspace) openURL:url))
     
     (- (id)stringForPath:(id)xp ofNode:(id)n is
        (set nodes (n nodesForXPath:xp error:(set perror (NuReference new))))
        (cond ((eq nodes nil)
               (set alert (NSAlert alertWithError (perror value)))
               (alert runModal))
              ((eq (nodes count) 0)
               nil)
              (else ((nodes objectAtIndex:0) stringValue))))
     
     (- (int)numberOfRowsInTableView:(id) tv is
        (@itemNodes count))
     
     (- (id)tableView:(id)tv objectValueForTableColumn:(id)tableColumn row:(int)row is
        (set itemNode (@itemNodes objectAtIndex:row))
        (set xPath (tableColumn identifier))
        (self stringForPath:xPath ofNode:itemNode)))

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
