//
//  Person.m
//  RaiseMan
//
//  Created by Aaron Hillegass on 9/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person

@synthesize expectedRaise;
@synthesize personName;

- (id)init
{
	[super init];
	expectedRaise = 5.0;
	personName = @"New Person";
	return self;
}

- (void)dealloc
{
	[personName release];
	[super dealloc];
}

@end

