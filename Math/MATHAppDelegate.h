//
//  MATHAppDelegate.h
//  Math
//
//  Created by Jason Brennan on Apr-28-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MATHPlotView;
@class MATHTextView;
@interface MATHAppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet MATHPlotView *plotView;
@property (weak) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSWindow *textWindow;
@property (unsafe_unretained) IBOutlet MATHTextView *textView;

@end
