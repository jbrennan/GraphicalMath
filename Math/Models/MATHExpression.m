//
//  MATHExpression.m
//  Math
//
//  Created by Jason Brennan on May-14-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHExpression.h"
#import "GCMathParser.h"
#import <ExpressionParser/ExpressionParser.h>

@interface MATHExpression ()

@property (readwrite, copy) NSString *lastValidExpression;
//@property (readonly, strong) GCMathParser *mathParser;
@property (nonatomic, strong) EXPExpressionParser *mathParser;

@end


@implementation MATHExpression

- (id)init {
	self = [super init];
	if (self) {
//		self.mathParser = [GCMathParser parser];
//		EXPExpressionParser *expressionParser = [EXPExpressionParser new];
//		BOOL valid = [expressionParser expressionIsValid:@"2 + 5"];
//		BOOL valid2 = NO;//= [expressionParser expressionIsValid:@"(2 + 5"];
//		
//		NSLog(@"Testing: %d %d", valid, valid2);
//		
//		NSLog(@"Evaluating...%f", [expressionParser evaluateExpression:@"2 * 5"]);
		self.mathParser = [EXPExpressionParser new];
	}
	
	return self;
}



- (void)setExpression:(NSString *)expression {
	if ([_expression isEqualToString:expression]) return;
	
	[self parseExpressionForValidity:expression];
	
	_expression = [expression copy];
	
	
}


- (void)setComparisonMode:(BOOL)comparisonMode {
	_comparisonMode = comparisonMode;
	
	self.baseExpression = self.lastValidExpression;
//	if (comparisonMode) {
//		// We're starting compare mode. Save whatever is currently stored in lastValidExpression as our baseExpression so it can be compared later
//		self.baseExpression = self.lastValidExpression;
//	} else {
//		// Done comparing. 
//	}
}

- (void)parseExpressionForValidity:(NSString *)expression {
	
	if ([self.mathParser expressionIsValid:expression]) {
		self.lastValidExpression = expression;
	} else {
		self.lastValidExpression = self.expression;
	}
	
//	@try {
//		GCMathParser *p = [GCMathParser parser];
//		[p evaluate:expression];
//		NSLog(@"successfully parsed: %@", expression);
//		self.lastValidExpression = expression;
//	}
//	@catch (NSException *exception) {
//		// This means the parser didn't successfully parse, so keep the most recent validly parsed expression
//		self.lastValidExpression = self.expression;
//		NSLog(@"Didn't parse: %@", expression);
//		
//		@try {
//			// clear out the parser's internal status...it apparently does something messy.
//			// This is a hack.
//			[GCMathParser evaluate:@"1"];
//		}
//		@catch (NSException *exception) {
//			NSLog(@"Parser error on the cleanup!!");
//		}
//		@finally {
//			
//		}
//	}
}


#pragma mark - Public API

- (BOOL)expressionIsPeriodic {
	return [self.expression hasSubstring:@"sin"] || [self.expression hasSubstring:@"cos"] || [self.expression hasSubstring:@"tan"]; // etc.
}


- (void)evaluateExpressionFromX:(double)fromX toX:(double)toX currentEvaluationHandler:(MATHExpressionEvaluationHandler)currentEvaluationHandler baseEvaluationHandler:(MATHExpressionEvaluationHandler)baseEvaluationHandler {
	
	if (currentEvaluationHandler == nil) return;
	if (![self.lastValidExpression length]) return;
	
	
	NSString *currentExpression = self.lastValidExpression; // instead of repeatedly asking for it.
	NSString *baseExpression = self.baseExpression;
	
	if (self.comparisonMode) {
		NSLog(@"functions are current: %@, base: %@", currentExpression, baseExpression);
	}
	
//	GCMathParser *parser = [GCMathParser parser];//self.mathParser;
	EXPExpressionParser *parser = self.mathParser;
	
	double x, y;
	for (x = fromX; x <= toX; x += 0.01) {
//		[parser setSymbolValue:x forKey:@"x"];
		
		[parser setValue:@(x) forSymbolNameInExpression:@"x"];
		y = [parser evaluateExpression:currentExpression];
		
//		@try {
//			y = [parser evaluate:currentExpression];
//		}
//		@catch (NSException *exception) {
//
//		}
//		@finally {
//			
//		}
		currentEvaluationHandler(x, y);
		
		if (!self.comparisonMode) continue;
		if (!baseEvaluationHandler) continue;
		
		// Now evaluate the base expression.
//		@try {
//			y = [parser evaluate:baseExpression];
//		} @catch (NSException *exception) {
//			
//		} @finally {
//			
//		}
		
		y = [parser evaluateExpression:baseExpression];
		baseEvaluationHandler(x, y);
		
	}
}

@end
