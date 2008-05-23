//
//  Polynomial.h
//  Polynomials
//
//  Created by Aaron Hillegass on 11/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Polynomial : NSObject {
    __strong CGFloat * terms;
    int termCount;
    __strong CGColorRef color;
}
- (id)init;
- (float)valueAt:(float)x;
- (void)drawInRect:(CGRect)b 
         inContext:(CGContextRef)ctx;
- (CGColorRef)color;
@end
