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
@property (strong) GCMathParser *mathParser;
@end


@implementation MATHExpression

- (id)init {
	self = [super init];
	if (self) {
		self.mathParser = [GCMathParser parser];
	}
	
	return self;
}

- (void)setExpression:(NSString *)expression {
	if ([_expression isEqualToString:expression]) return;
	
	[self parseExpressionForValidity:expression];
	
	_expression = expression;
	
	
}

- (void)parseExpressionForValidity:(NSString *)expression {
	
	@try {
		[self.mathParser evaluate:expression];
		self.lastValidExpression = expression;
	}
	@catch (NSException *exception) {
		// This means the parser didn't successfully parse, so keep the most recent validly parsed expression
		self.lastValidExpression = self.expression;
	}
	@finally {
		
	}
}


#pragma mark - Public API

- (BOOL)expressionIsPeriodic {
	return [self.expression hasSubstring:@"sin"] || [self.expression hasSubstring:@"cos"] || [self.expression hasSubstring:@"tan"]; // etc.
}


- (void)evaluateExpressionFromX:(double)fromX toX:(double)toX evaluationHandler:(MATHExpressionEvaluationHandler)evaluationHandler {
	
	if (evaluationHandler == nil) return;
	
	NSString *expression = self.expression; // instead of repeatedly asking for it.
	GCMathParser *parser = self.mathParser;
	
	double x, y;
	for (x = fromX; x <= toX; x += 0.01) {
		[parser setSymbolValue:x forKey:@"x"];
		y = [parser evaluate:expression];
		
		evaluationHandler(x, y);
	}
}

@end
