//
//  MATHExpression.m
//  Math
//
//  Created by Jason Brennan on May-14-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHExpression.h"
#import "GCMathParser.h"

@interface MATHExpression ()
@property (readwrite, copy) NSString *lastValidExpression;
@property (readonly, strong) GCMathParser *mathParser;
@end


@implementation MATHExpression

- (id)init {
	self = [super init];
	if (self) {
//		self.mathParser = [GCMathParser parser];
	}
	
	return self;
}


- (GCMathParser *)mathParser {
	// return a new parser
	return [GCMathParser parser];
}

- (void)setExpression:(NSString *)expression {
	if ([_expression isEqualToString:expression]) return;
	
	[self parseExpressionForValidity:expression];
	
	_expression = [expression copy];
	
	
}

- (void)parseExpressionForValidity:(NSString *)expression {
	
	@try {
		GCMathParser *p = [GCMathParser parser];
		[p evaluate:expression];
		NSLog(@"successfully parsed: %@", expression);
		self.lastValidExpression = expression;
	}
	@catch (NSException *exception) {
		// This means the parser didn't successfully parse, so keep the most recent validly parsed expression
		self.lastValidExpression = self.expression;
		NSLog(@"Didn't parse: %@", expression);
		
		@try {
			// clear out the parser's internal status...it apparently does something messy.
			// This is a hack.
			[GCMathParser evaluate:@"1"];
		}
		@catch (NSException *exception) {
			NSLog(@"Parser error on the cleanup!!");
		}
		@finally {
			
		}
	}
}


#pragma mark - Public API

- (BOOL)expressionIsPeriodic {
	return [self.expression hasSubstring:@"sin"] || [self.expression hasSubstring:@"cos"] || [self.expression hasSubstring:@"tan"]; // etc.
}


- (void)evaluateExpressionFromX:(double)fromX toX:(double)toX evaluationHandler:(MATHExpressionEvaluationHandler)evaluationHandler {
	
	if (evaluationHandler == nil) return;
	if (![self.lastValidExpression length]) return;
	NSLog(@"last valid: %@", self.lastValidExpression);
	
	NSString *expression = self.lastValidExpression; // instead of repeatedly asking for it.
	GCMathParser *parser = [GCMathParser parser];//self.mathParser;
	
	double x, y;
	for (x = fromX; x <= toX; x += 0.01) {
		[parser setSymbolValue:x forKey:@"x"];
		@try {
			y = [parser evaluate:expression];
		}
		@catch (NSException *exception) {
//			NSLog(@"Exception when evaluating (%@) over range??? %@", expression, exception);
		}
		@finally {
			
		}
		
		evaluationHandler(x, y);
	}
}

@end
