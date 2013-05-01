//
//  MATHPlotView.m
//  Math
//
//  Created by Jason Brennan on Apr-28-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHPlotView.h"
#import "GCMathParser.h"

@interface MATHPlotView ()
@property (strong) GCMathParser *mathParser;
@property (strong) NSMutableArray *points;;
@end

@implementation MATHPlotView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
    
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		[self commonInit];
	}
	
	return self;
}


- (void)commonInit {
	self.mathParser = [GCMathParser parser];
	self.points = [NSMutableArray new];
}


- (void)setExpression:(NSString *)expression {
	_expression = expression;
	
	[self setupPlotInfo];
	
	[self setNeedsDisplay:YES];
	
}


- (void)setupPlotInfo {
	NSString* expression = self.expression;
	self.points = [NSMutableArray new];
	
	CGRect bounds = [self bounds];
	CGFloat maxWidth = CGRectGetWidth(bounds);
	CGFloat maxHeight = CGRectGetHeight(bounds);
	
	CGFloat totalXRange = 2.0 * M_PI;
	CGFloat xScale = maxWidth / totalXRange;
	
	CGFloat yScale = 15.0f; // just a guess for now, we'll have to actually specify these later.
	
	double x, y;
	for (x = -M_PI; x <= M_PI; x += 0.01) {
		[self.mathParser setSymbolValue:x forKey:@"x"];
		y = [self.mathParser evaluate:expression];
		// do something with x and y here, for example plot it.
		
		// Need to scale these to fit in the bounds
		CGFloat scaledX = xScale * x + maxWidth/2.0f;
		CGFloat scaledY = yScale * y + maxHeight/2.0f;
		[self.points addObject:[NSValue valueWithPoint:NSMakePoint(scaledX, scaledY)]];
	}
NSLog(@"%@", self.points);
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
	// Draw the graph
	
	// Draw the points
	
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
	NSValue *firstPoint = [[[self.points reverseObjectEnumerator] allObjects] lastObject];
	[pointsPath moveToPoint:[firstPoint pointValue]];
	for (NSValue *v in self.points) {
		[pointsPath lineToPoint:[v pointValue]];
	}
	
	[[NSColor darkGrayColor] set];
	[pointsPath stroke];
}

@end
