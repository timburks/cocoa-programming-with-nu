//
//  MyDocument.h
//  RaiseMan
//
//  Created by Aaron Hillegass on 9/24/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class Person;

@interface MyDocument : NSDocument
{
	NSMutableArray *employees;	
}
#pragma mark Accessors - 'employee'

- (void)setEmployees:(NSMutableArray *)array;
- (void)insertObject:(Person *)p
  inEmployeesAtIndex:(int)r;
- (void)removeObjectFromEmployeesAtIndex:(int)r;

@end
