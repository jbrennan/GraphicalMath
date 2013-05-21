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
	
//	[[NSApplication sharedApplication] setPresentationOptions:NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar];
	
	[self.textField setDelegate:self];
	[self.textView setDelegate:self];
	[self.window makeKeyAndOrderFront:nil];
	[self.textWindow makeKeyAndOrderFront:nil];
	
	[self.textView setNumberDragHandler:^(NSTextView *draggedObject, NSString *draggedLine) {
		self.plotView.expression = [draggedObject string];
	}];
	NSString *expression = @"sin(x)";
	[self.textView setString:expression];
	[self.plotView setExpression:expression];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];

//    NSLog(@"answer == %f", [[textField stringValue] evaluateMath]);
	self.plotView.expression = [textField stringValue];
}


- (void)textDidChange:(NSNotification *)notification {
	NSString *text = [self.textView string];
	NSLog(@"Setting from app delegate: %@ currently is %@", text, self.plotView.expression);
	self.plotView.expression = text;
}

@end
