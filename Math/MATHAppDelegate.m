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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self.textField setDelegate:self];
	[self.textView setDelegate:self];
	[self.window orderFront:nil];
	[self.textWindow makeKeyAndOrderFront:nil];
	
	[self.textView setNumberDragHandler:^(NSTextView *draggedObject, NSString *draggedLine) {
		self.plotView.expression = [draggedObject string];
	}];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];

//    NSLog(@"answer == %f", [[textField stringValue] evaluateMath]);
	self.plotView.expression = [textField stringValue];
}


- (void)textDidChange:(NSNotification *)notification {
	self.plotView.expression = [self.textView string];
}

@end
