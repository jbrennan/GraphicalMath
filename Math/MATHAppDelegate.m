//
//  MATHAppDelegate.m
//  Math
//
//  Created by Jason Brennan on Apr-28-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHAppDelegate.h"
#import "GCMathParser.h"
#import "MATHPlotView.h"

@implementation MATHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self.textField setDelegate:self];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];

//    NSLog(@"answer == %f", [[textField stringValue] evaluateMath]);
	self.plotView.expression = [textField stringValue];
}

@end
