//
//  Polynomial.m
//  Polynomials
//
//  Created by Aaron Hillegass on 11/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Polynomial.h"
#import <QuartzCore/QuartzCore.h>

#define HOPS (100)
#define RANDFLOAT() (random() % 128 / 128.0)

static CGRect funcRect = {-20, -20, 40, 40};

@implementation Polynomial
- (id)init
{
    [super init];
    termCount = (random() % 3) + 2;
    terms = NSAllocateCollectable(termCount * sizeof(CGFloat), NSScannedOption);
    color = CGColorCreateGenericRGB(RANDFLOAT(), RANDFLOAT(), RANDFLOAT(), 0.7);
    NSMakeCollectable(color);
    
    int i;
    for (i = 0; i < termCount; i++) {
        terms[i] = 5.0 - (random() % 100) / 10.0;
    }
    
    return self;
}
- (float)valueAt:(float)x
{
    float result = 0;
    int i;
    for (i = 0; i < termCount; i++) {
        result = (result * x) + terms[i];
    }
    return result;
}

- (void)drawInRect:(CGRect)b inContext:(CGContextRef)ctx
{
    NSLog(@"drawing");
    CGAffineTransform tf;
    tf = CGAffineTransformMake(b.size.width / funcRect.size.width, 0, 
                               0, b.size.height / funcRect.size.height, 
                               b.size.width/2, b.size.height/2);
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, tf);
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextSetLineWidth(ctx, 0.4);
    float distance = funcRect.size.width / HOPS;
    float currentX = funcRect.origin.x;
    BOOL first = YES;
    while (currentX <= funcRect.origin.x + funcRect.size.width) {
        float currentY = [self valueAt:currentX];
        if (first) {
            CGContextMoveToPoint(ctx, currentX, currentY);
            first = NO;
        } else {
            CGContextAddLineToPoint(ctx, currentX, currentY);
        }
        currentX += distance;
    }
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
}

- (void)drawLayer:(CALayer *)layer 
        inContext:(CGContextRef)ctx
{
    CGRect cgb = [layer bounds];
    [self drawInRect:cgb
           inContext:ctx];
}
- (id<CAAction>)actionForLayer:(CALayer *)layer 
                        forKey:(NSString *)event
{
    NSLog(@"action = %@", event);
    return nil;
}


- (CGColorRef)color
{
    return color;
}
- (void)finalize
{
    NSLog(@"finalizing");
    [super finalize];
}

@end
