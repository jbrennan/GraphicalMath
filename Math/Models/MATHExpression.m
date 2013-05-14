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

@end
