//
//  MATHKnob.m
//  Math
//
//  Created by Jason Brennan on Jul-25-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHKnob.h"
#import "NSColor+MathColors.h"

@implementation MATHKnob

- (void)setupView {
	
}

- (void)drawRect:(NSRect)dirtyRect {
	CGRect bounds = [self bounds];
	
	// ensure it's a square
	bounds.size.height = bounds.size.width;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:bounds];
	[[NSColor comparedFunctionColor] set];
	
	[path fill];
}

@end
