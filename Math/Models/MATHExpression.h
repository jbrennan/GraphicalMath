//
//  MATHExpression.h
//  Math
//
//  Created by Jason Brennan on May-14-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MATHExpressionEvaluationHandler)(double input, double result);

@interface MATHExpression : NSObject

@property (nonatomic, copy) NSString *expression;
@property (readonly, copy) NSString *lastValidExpression; // if an expression is being typed, but is incomplete, this will hold the last one that parsed properly.
@property (readonly) BOOL expressionIsPeriodic;

// Evaluates the last valid expression over the given X domain and calls the evaluation handler for every step with the result.
- (void)evaluateExpressionFromX:(double)fromX toX:(double)toX evaluationHandler:(MATHExpressionEvaluationHandler)evaluationHandler;

@end
