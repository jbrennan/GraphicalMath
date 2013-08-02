//
//  MATHPlotView.m
//  Math
//
//  Created by Jason Brennan on Apr-28-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHPlotView.h"
#import "MATHExpression.h"
#import "NSColor+MathColors.h"
#import "MATHKnob.h"

const CGFloat MATHPlotViewLineWidth = 1.0f;
const CGPoint MATHPlotViewMouseNotInViewPoint = (CGPoint){CGFLOAT_MAX, CGFLOAT_MAX};

@interface MATHPlotView ()

@property (strong) NSMutableArray *currentPoints;
@property (strong) NSMutableArray *basePoints;
@property (strong) MATHExpression *expressionEvaluator;

@property MATHKnob *knob;
@property NSTextField *mouseLabel;
@property (readonly) BOOL mouseIsInView;
@property CGPoint currentViewScanningPoint;

@end


#pragma mark -

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
	self.expressionEvaluator = [MATHExpression new];
	self.currentPoints = [NSMutableArray new];
	[self setAutoresizesSubviews:YES];
	
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options:(NSTrackingMouseEnteredAndExited |
																									NSTrackingMouseMoved |
																									NSTrackingActiveInActiveApp |
																									NSTrackingInVisibleRect)
																  owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	
	CGFloat knobSize = 10.f;
	self.knob = [MATHKnob newWithSuperview:self frame:CGRectMake(0, 0, knobSize, knobSize)];
	
	
	self.mouseLabel = [NSTextField newWithSuperview:self frame:CGRectMake(0, 0, 0, 0)];
	[self.mouseLabel setBezeled:NO];
	[self.mouseLabel setEditable:NO];
	[self.mouseLabel setDrawsBackground:NO];
	[self.mouseLabel setAttributedStringValue:[self attributedMouseLabelStringForString:@""]];
	[self.mouseLabel sizeToFit];
}

- (NSAttributedString *)attributedMouseLabelStringForString:(NSString *)string {
	NSDictionary *attributes = @{NSFontAttributeName: [[self class] functionFont]};
	return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	[self setupPlotInfoAndRedisplay];
}

#pragma mark - Public API

- (void)setExpression:(NSString *)expression {
	_expression = [expression copy];
	
	[self setupPlotInfoAndRedisplay];
}


- (void)setShowsComparisons:(BOOL)showsComparisons {
	_showsComparisons = showsComparisons;
	
	self.expressionEvaluator.comparisonMode = showsComparisons;
	
	[self setupPlotInfoAndRedisplay];
}


#pragma mark - Private API


- (void)setupPlotInfoAndRedisplay {
	[self setupPlotInfo];
	[self setNeedsDisplay:YES];
}

- (void)setupPlotInfo {
	self.expressionEvaluator.expression = self.expression;
	self.currentPoints = [NSMutableArray new];
	self.basePoints = [NSMutableArray new];
	double domain = [self graphingXDomain];

	
	[self.expressionEvaluator evaluateExpressionFromX:-domain toX:domain currentEvaluationHandler:^(double input, double result) {
		[self.currentPoints addObject:[NSValue valueWithPoint:CGPointMake(input, result)]];
	} baseEvaluationHandler:^(double input, double result) {
		[self.basePoints addObject:[NSValue valueWithPoint:CGPointMake(input, result)]];
	}];
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
	
	// Draw a background colour
	[[NSColor mathGraphBackgroundColor] set];
	NSRectFill([self bounds]);

	
	[self drawGraph];
	[self drawUnits];
	[self drawPoints];
	
	if (self.mouseIsInView) [self drawMouseLines];
	
	[self drawComparisonLabels];
}


- (void)drawGraph {
	if ([self expressionIsPeriodic]) {
		[self drawPeriodicGraph];
	} else {
		[self drawPeriodicGraph];
	}
}


- (void)drawUnits {
	if ([self expressionIsPeriodic]) {
		[self drawPeriodicUnits];
	} else {
		[self drawPeriodicUnits];
	}
}


+ (NSFont *)functionFont {
	return [NSFont fontWithName:@"Helvetica-Bold" size:12.0f];
}

- (void)drawComparisonLabels {
//	if (!self.showsComparisons) return;
	
	NSFont *functionFont = [[self class] functionFont];
	
	NSColor *baseFunctionColor = [NSColor baseFunctionColor];
	NSDictionary *baseAttributes = @{NSFontAttributeName: functionFont, NSForegroundColorAttributeName: baseFunctionColor};
	
	CGPoint drawingPoint = CGPointMake(20.0f, CGRectGetHeight([self bounds]) - 30.0f);
	
	
	// Draw the original function in grey
	NSString *functionToDraw = self.showsComparisons? self.expressionEvaluator.baseExpression : self.expressionEvaluator.lastValidExpression;

	[functionToDraw drawAtPoint:drawingPoint withAttributes:baseAttributes];

	if (self.showsComparisons) {		
		CGSize labelSize = [functionToDraw sizeWithAttributes:baseAttributes];
		drawingPoint.y -= (labelSize.height + 5.0f);
		
		NSDictionary *secondFunctionAttributes = @{NSFontAttributeName: functionFont, NSForegroundColorAttributeName: [NSColor comparedFunctionColor]};
		[self.expressionEvaluator.lastValidExpression drawAtPoint:drawingPoint withAttributes:secondFunctionAttributes];
	}
}


- (void)drawPoints {
	

	if (self.showsComparisons) {
		// draw the base first so that the current function will be on top.
		[[self secondGraphColor] set];
		[[self bezierPathForExpressionPoints:self.basePoints] stroke];
	}
	
	
	[[self firstGraphColor] set];
	[[self bezierPathForExpressionPoints:self.currentPoints] stroke];

}


- (void)drawMouseLines {
	NSMutableArray *points = [NSMutableArray new];
	[points addObject:[NSValue valueWithPoint:self.currentViewScanningPoint]];
	
	CGPoint graphOrigin = [self pointByConvertingExpressionPointToViewPoint:CGPointMake(0, 0)];
	CGPoint pointAlongXAxis = CGPointMake(self.currentViewScanningPoint.x, graphOrigin.y);
	CGPoint pointAlongYAxis = CGPointMake(graphOrigin.x, self.currentViewScanningPoint.y);
	
	
	[points addObject:[NSValue valueWithPoint:pointAlongXAxis]];
	
	// Get the bezier paths and draw them.
	[[NSColor comparedFunctionColor] set];
	NSBezierPath *xPath = [self bezierPathForViewPoints:points];
	[xPath stroke];
	
	[points removeLastObject];
	[points addObject:[NSValue valueWithPoint:pointAlongYAxis]];
	
	
	NSBezierPath *yPath = [self bezierPathForViewPoints:points];
	[yPath stroke];
}


- (NSBezierPath *)bezierPathForExpressionPoints:(NSArray *)points {
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
	NSValue *firstPoint = [points zerothObject];
	
	CGPoint unscaledPoint = [firstPoint pointValue];
	
	[pointsPath moveToPoint:[self pointByConvertingExpressionPointToViewPoint:unscaledPoint]];
	for (NSValue *v in points) {
		[pointsPath lineToPoint:[self pointByConvertingExpressionPointToViewPoint:[v pointValue]]];
	}
	
	return pointsPath;
}


- (NSBezierPath *)bezierPathForViewPoints:(NSArray *)points {
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
	NSValue *firstPoint = [points zerothObject];
	
	CGPoint viewPoint = [firstPoint pointValue];
	
	[pointsPath moveToPoint:viewPoint];
	for (NSValue *v in points) {
		[pointsPath lineToPoint:[v pointValue]];
	}
	
	return pointsPath;
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


- (void)drawPeriodicUnits {
	
	[self drawPeriodicUnitsAlongHorizontalAxis:YES positive:YES];
	[self drawPeriodicUnitsAlongHorizontalAxis:YES positive:NO];
	[self drawPeriodicUnitsAlongHorizontalAxis:NO positive:YES];
	[self drawPeriodicUnitsAlongHorizontalAxis:NO positive:NO];
	
}


- (void)drawPeriodicUnitsAlongHorizontalAxis:(BOOL)yesForHorizontal positive:(BOOL)positive {
	// Get the scale for the current expression
	CGFloat unitScale = [self unitScale];
	
	CGPoint origin = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
	
	NSBezierPath *line = [NSBezierPath bezierPath];
	[line setLineWidth:MATHPlotViewLineWidth];
	
	
	// get the units
	NSUInteger unitsOverAxis = 0;
	if (yesForHorizontal) {
		unitsOverAxis = (NSUInteger)(CGRectGetWidth([self bounds]) / 2.0f) / unitScale; // half-width
	} else {
		unitsOverAxis = (NSUInteger)(CGRectGetHeight([self bounds]) / 2.0f) / unitScale; // half-height
	}
	unitsOverAxis++;
	
	
	for (NSInteger currentMarker = 0; currentMarker < unitsOverAxis; currentMarker++) {
		
		[line removeAllPoints];
		
		
		CGPoint markerPoint;
		CGPoint endPoint;
		CGFloat markerEndOffset = 5.0f;
		if (yesForHorizontal) {
			if (positive) {
				markerPoint = CGPointMake(currentMarker * unitScale + origin.x, origin.y);
			} else {
				markerPoint = CGPointMake(origin.x - currentMarker * unitScale, origin.y);
			}
			endPoint = CGPointMake(markerPoint.x, markerPoint.y - markerEndOffset);
		} else {
			if (positive) {
				markerPoint = CGPointMake(origin.x, currentMarker * unitScale + origin.y);
			} else {
				markerPoint = CGPointMake(origin.x, origin.y - currentMarker * unitScale);
			}
			endPoint = CGPointMake(markerPoint.x - markerEndOffset, markerPoint.y);
		}
		
		
		[line moveToPoint:markerPoint];
		[line lineToPoint:endPoint];
		[line stroke];
		
		if (currentMarker == 0) continue;
		
		NSString *currentNumber = [NSString stringWithFormat:@"%@%ld", positive? @"" : @"-", currentMarker];
		NSFont *numberFont = [NSFont fontWithName:@"Helvetica-Bold" size:9];
		
		NSDictionary *attributes = @{NSFontAttributeName: numberFont, NSForegroundColorAttributeName: [NSColor mathGraphAxisColor]};
		
		CGFloat letterOffset = 13.0f;
		if (yesForHorizontal) {
			endPoint.x -= [currentNumber sizeWithAttributes:attributes].width / 2.0f;
			endPoint.y -= letterOffset;
		} else {
			endPoint.x -= 10;
			endPoint.y -= ([currentNumber sizeWithAttributes:attributes].width / 2.0f) + 2;
		}
		[currentNumber drawAtPoint:endPoint withAttributes:attributes];
	}
}


- (void)drawOriginUnits {
	
}

#pragma mark - Mouse movements


- (void)mouseMoved:(NSEvent *)theEvent {

	[super mouseMoved:theEvent];
	
	// Get the point, then map it down to "math-space"
	CGPoint mousePoint = [theEvent locationInWindow];
	
	CGPoint converted = [self pointByConvertingViewPointToExpressionPoint:mousePoint];
	
	__block CGFloat y = 0;
	[self.expressionEvaluator evaluateExpressionFromX:converted.x toX:converted.x currentEvaluationHandler:^(double input, double result) {
		y = result;
	} baseEvaluationHandler:^(double input, double result) {
		
	}];
	
	CGPoint mathPoint = CGPointMake(converted.x, y);
	CGPoint convertedAnswerPoint = [self pointByConvertingExpressionPointToViewPoint:mathPoint];
	
	[self moveKnobToPoint:convertedAnswerPoint];
	
	[self setMouseLabelForYValue:y position:mousePoint];

	[self setNeedsDisplay:YES];
	
}


- (void)setMouseLabelForYValue:(double)y position:(CGPoint)position {
	NSString *labelString = [NSString stringWithFormat:@"%.2f", y];
	[self.mouseLabel setAttributedStringValue:[self attributedMouseLabelStringForString:labelString]];
	[self.mouseLabel sizeToFit];
	[self.mouseLabel setFrameOrigin:position];
	
}


- (void)moveKnobToPoint:(CGPoint)point {
	self.knob.centerOfFrame = point;
	self.currentViewScanningPoint = point;
}


- (void)mouseEntered:(NSEvent *)theEvent {
	self.currentViewScanningPoint = [theEvent locationInWindow];
	[self setNeedsDisplay:YES];
	[self setKnobVisible:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	self.currentViewScanningPoint = MATHPlotViewMouseNotInViewPoint;
	[self setKnobVisible:NO];
	[self setNeedsDisplay:YES];
}


- (void)setKnobVisible:(BOOL)visible {
	[self.knob setHidden:!visible];
}


- (BOOL)mouseIsInView {
	return !CGPointEqualToPoint(self.currentViewScanningPoint, MATHPlotViewMouseNotInViewPoint);
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


- (double)graphingXDomain {
	CGFloat halfWidth = CGRectGetMidX([self bounds]);
	return (double)(halfWidth/[self unitScale]);
}


- (CGPoint)pointByConvertingExpressionPointToViewPoint:(CGPoint)unscaledPoint {
	CGFloat scale = [self unitScale];
	
	CGRect bounds = [self bounds];
	CGPoint halfBounds = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
	CGPoint scaled = CGPointMake(unscaledPoint.x * scale, unscaledPoint.y * scale);
	CGPoint translated = CGPointMake(scaled.x + halfBounds.x, scaled.y + halfBounds.y);
	
	return translated;
}


- (CGPoint)pointByConvertingViewPointToExpressionPoint:(CGPoint)viewPoint {
	
	CGFloat scale = [self unitScale];
	
	CGRect bounds = [self bounds];
	CGPoint halfBounds = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	CGPoint translated = CGPointMake(viewPoint.x - halfBounds.x, viewPoint.y - halfBounds.y);
	CGPoint scaled = CGPointMake(translated.x / scale, translated.y / scale);
	
	return scaled;
}


- (NSColor *)firstGraphColor {
	return self.showsComparisons? [NSColor comparedFunctionColor] : [NSColor baseFunctionColor];
}


- (NSColor *)secondGraphColor {
	return self.showsComparisons? [NSColor baseFunctionColor] : [NSColor comparedFunctionColor];
}


@end
