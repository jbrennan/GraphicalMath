//
//  MATHTextView.h
//  Math
//
//  Created by Jason Brennan on Apr-30-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// TODO: Really need to put as much of this in a common class as possible, for text dragging.
typedef void (^MATHTextViewDragHandler)(NSTextView *draggedObject, NSString *draggedLine);

@interface MATHTextView : NSTextView


// It occurs to me these could have been delegate methods, but I want to try this.
@property (copy) MATHTextViewDragHandler dragStartedHandler;
@property (copy) MATHTextViewDragHandler dragEndedHandler;

@property (copy) MATHTextViewDragHandler numberDragHandler; // will be called continuously as a number is dragged


@end
