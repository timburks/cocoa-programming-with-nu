//
//  Person.h
//  RaiseMan
//
//  Created by Aaron Hillegass on 9/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject {
	NSString *personName;
	float expectedRaise;
}
@property (readwrite, copy) NSString *personName;
@property (readwrite) float expectedRaise;

@end
