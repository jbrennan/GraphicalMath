//
//  MATHExpression.h
//  Math
//
//  Created by Jason Brennan on May-14-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MATHExpression : NSObject

@property (nonatomic, copy) NSString *expression;
@property (readonly, copy) NSString *lastValidExpression; // if an expression is being typed, but is incomplete, this will hold the last one that parsed properly.


@end
