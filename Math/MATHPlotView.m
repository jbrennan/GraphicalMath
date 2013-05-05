//
//  MATHPlotView.m
//  Math
//
//  Created by Jason Brennan on Apr-28-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHPlotView.h"
#import "GCMathParser.h"
#import "NSColor+MathColors.h"


const CGFloat MATHPlotViewLineWidth = 1.0f;


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
//NSLog(@"%@", self.points);
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithCalibratedHue:0.672 saturation:0.020 brightness:1.000 alpha:1.000] set];
	NSRectFill([self bounds]);
	// Draw the graph
	[self drawGraph];
	
	// Draw units
	[self drawUnits];
	
	// Draw the points
	
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
	NSValue *firstPoint = [self.points zerothObject];
	[pointsPath moveToPoint:[firstPoint pointValue]];
	for (NSValue *v in self.points) {
		[pointsPath lineToPoint:[v pointValue]];
	}
	
	[[NSColor darkGrayColor] set];
	[pointsPath stroke];
}


- (void)drawGraph {
	if ([self expressionIsPeriodic]) {
		[self drawPeriodicGraph];
	} else {
		[self drawOriginGraph];
	}
}




- (void)drawPeriodicGraph {
	// Draw the origin in the centre of the view
	CGRect bounds = [self bounds];
	
	[[NSColor mathGraphAxisColor] set];
	
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line setLineWidth:MATHPlotViewLineWidth];
	[line moveToPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))];
	[line lineToPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMinX(bounds))];
	[line stroke];
	
	[line removeAllPoints];
	
	[line moveToPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds))];
	[line lineToPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds))];
	[line stroke];
	
}


- (void)drawOriginGraph {
	// Draw the origin in the lower left of the view
}


- (void)drawUnits {
	if ([self expressionIsPeriodic]) {
		[self drawPeriodicUnits];
	} else {
		[self drawOriginUnits];
	}
}


- (void)drawPeriodicUnits {
	// I need some kind of scale that will take mathematical units and turn them into pixel units (well, points).
	// This scale needs to be the same no matter what the size of the view is.
	// But the scale should probably be configurable so that it can either be zoomed or derived from the Expression being evaluated.
	
	// Get the scale for the current expression
	CGFloat unitScale = [self unitScale];
	
	// Iterate over the axises and draw marks every unitScale pixels?
	CGPoint origin = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
	
	NSBezierPath *line = [NSBezierPath bezierPath];
	[line setLineWidth:MATHPlotViewLineWidth];
	
	
	// positive x
	NSUInteger unitsOverXAxis = (NSUInteger)(CGRectGetWidth([self bounds]) / 2.0f) / unitScale; // half-width
	for (NSInteger currentMarker = 0; currentMarker < unitsOverXAxis; currentMarker++) {
		[line removeAllPoints];
		
		CGPoint markerPoint = CGPointMake(currentMarker * unitScale + origin.x, origin.y);
		CGPoint endPoint = CGPointMake(markerPoint.x, markerPoint.y - 5.0f);
		
		[line moveToPoint:markerPoint];
		[line lineToPoint:endPoint];
		[line stroke];
		
		if (currentMarker == 0) continue;
		
		NSString *currentNumber = [NSString stringWithFormat:@"%ld", (long)currentMarker];
		NSFont *numberFont = [NSFont fontWithName:@"Helvetica-Bold" size:9];
		
		NSDictionary *attributes = @{NSFontAttributeName: numberFont, NSForegroundColorAttributeName: [NSColor mathGraphAxisColor]};
		endPoint.x -= [currentNumber sizeWithAttributes:attributes].width / 2.0f;
		endPoint.y -= 13.0f;
		[currentNumber drawAtPoint:endPoint withAttributes:attributes];
	}
}


- (void)drawOriginUnits {
	
}


#pragma mark - Helpers

- (BOOL)expressionIsPeriodic {
	return [self.expression hasSubstring:@"sin"] || [self.expression hasSubstring:@"cos"] || [self.expression hasSubstring:@"tan"]; // etc.
}


- (CGFloat)unitScale {
	// This should instead go in some kind of Expression class, along with other attributes like -expressionIsPeriodic, for example.
	// Also in that class should be things like evaluation ranges/domain
	return 30.0f;
}

@end
