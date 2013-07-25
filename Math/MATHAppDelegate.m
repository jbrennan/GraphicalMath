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
#import "MATHTextView.h"

@interface MATHAppDelegate () <NSTextViewDelegate>
@end

@implementation MATHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[self.textView setDelegate:self];
	[self.window orderFrontRegardless];
	[self.textWindow makeKeyAndOrderFront:nil];
	
	[self.textView setNumberDragHandler:^(NSTextView *draggedObject, NSString *draggedLine) {
		self.plotView.expression = [draggedObject string];
	}];
	
	
	[self.textView setDragStartedHandler:^(NSTextView *draggedObject, NSString *draggedLine) {
		self.plotView.showsComparisons = YES;
	}];
	
	
	[self.textView setDragEndedHandler:^(NSTextView *draggedObject, NSString *draggedLine) {
		self.plotView.showsComparisons = NO;
	}];
	
	
	NSString *expression = @"sin(x)";
	[self.textView setString:expression];
	[self.plotView setExpression:expression];
}




- (void)textDidChange:(NSNotification *)notification {
	NSString *text = [self.textView string];
	self.plotView.expression = text;
}

@end
