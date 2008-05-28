//
//  MyDocument.m
//  RaiseMan
//
//  Created by Aaron Hillegass on 9/24/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "MyDocument.h"
#import "Person.h"

@interface MyDocument ()

- (void)startObservingPerson:(Person *)p;
- (void)stopObservingPerson:(Person *)p;

@end

@implementation MyDocument

- (id)init
{
    if (![super init])
		return nil;
	
	[self setEmployees:[NSMutableArray array]];
	
    return self;
}

- (void)dealloc
{
	[self setEmployees:nil];
	[super dealloc];
}

#pragma mark Accessors - 'employees'
- (void)startObservingPerson:(Person *)person
{
	[person addObserver:self
			 forKeyPath:@"personName"
				options:NSKeyValueObservingOptionOld
				context:NULL];
	
	[person addObserver:self
			 forKeyPath:@"expectedRaise"
				options:NSKeyValueObservingOptionOld
				context:NULL];
}

- (void)stopObservingPerson:(Person *)person
{
	[person removeObserver:self
				forKeyPath:@"personName"];
	
	[person removeObserver:self
				forKeyPath:@"expectedRaise"];
}


- (void)insertObject:(Person *)p
  inEmployeesAtIndex:(int)r
{
	// Register the undo
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self]
				removeObjectFromEmployeesAtIndex:r];
	if (![undo isUndoing]) {
		[undo setActionName:@"Insert Person"];
	}
	// Add the person to the array
	[self startObservingPerson:p];
	[employees insertObject:p atIndex:r];
}
- (void)removeObjectFromEmployeesAtIndex:(int)r
{
	Person *p = [employees objectAtIndex:r];
	
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self]
	 insertObject:p inEmployeesAtIndex:r];
	if (![undo isUndoing]) {
		[undo setActionName:@"Delete Person"];
	}
	[self stopObservingPerson:p];
	[employees removeObjectAtIndex:r];
}

- (void)setEmployees:(NSMutableArray *)array
{
	if (array == employees) {
		return;
	}
	for (Person *p in employees) {
		[self stopObservingPerson:p];
	}
	[employees release];
	[array retain];
	employees = array;
	for (Person *p in employees) {
		[self startObservingPerson:p];
	}
}

- (void)changeKeyPath:(NSString *)keyPath
			 ofObject:(id)obj
			  toValue:(id)newValue
{
	[obj setValue:newValue forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)obj
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSUndoManager *undo = [self undoManager];
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	if (oldValue == [NSNull null]) {
		oldValue = nil;
	}
	NSLog(@"oldValue = %@", oldValue);
	[[undo prepareWithInvocationTarget:self] 
	 changeKeyPath:keyPath
	 ofObject:obj
	 toValue:oldValue];
	[undo setActionName:@"Edit"];
}

#pragma mark NSDocument methods

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
