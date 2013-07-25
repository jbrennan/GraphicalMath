//
//  NSColor+MathColors.m
//  Math
//
//  Created by Jason Brennan on May-04-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "NSColor+MathColors.h"

@implementation NSColor (MathColors)

+ (NSColor *)mathGraphAxisColor {
	return [NSColor colorWithCalibratedHue:0.905 saturation:0.000 brightness:0.705 alpha:1.000];
}


+ (NSColor *)mathGraphBackgroundColor {
	return [NSColor colorWithCalibratedHue:0.672 saturation:0.020 brightness:1.000 alpha:1.000];
}


+ (NSColor *)baseFunctionColor {
	return [NSColor darkGrayColor];
}


+ (NSColor *)comparedFunctionColor {
	return [NSColor colorWithDeviceHue:0.984 saturation:0.979 brightness:0.746 alpha:1.000];
}

@end
