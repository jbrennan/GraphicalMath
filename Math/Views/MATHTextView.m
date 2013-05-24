//
//  MATHTextView.m
//  Math
//
//  Created by Jason Brennan on Apr-30-2013.
//  Copyright (c) 2013 Jason Brennan. All rights reserved.
//

#import "MATHTextView.h"
#import <ParseKit/ParseKit.h>

@interface MATHTextView () <NSTextStorageDelegate>
@property (assign) NSRange currentlyHighlightedRange;
@property (assign) NSRange initialNumberRange;
@property (assign) NSRange initialDragCommandRange;
@property (assign) CGPoint initialDragPoint;
@property (strong) NSNumber *initialNumber;
@property (strong) NSMutableDictionary *numberRanges;
@end


@implementation MATHTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self commonInit];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		[self commonInit];
	}
	
	return self;
}


- (void)commonInit {
	
	self.numberRanges = [@{} mutableCopy];
	self.initialDragPoint = CGPointZero;
	
	
	[self setFont:[NSFont fontWithName:@"Menlo" size:16]];
	[self setTextColor:[NSColor colorWithCalibratedHue:0.905 saturation:0.000 brightness:0.205 alpha:1.000]];
	[self setBackgroundColor:[NSColor colorWithCalibratedHue:0.672 saturation:0.020 brightness:1.000 alpha:1.000]];
	[self setTextContainerInset:CGSizeMake(5, 5)];
	[[self textStorage] setDelegate:self];
}

- (void)textStorageDidProcessEditing:(NSNotification *)note {
    [self highlightText];
}


#pragma mark - NSResponder methods

- (void)mouseMoved:(NSEvent *)theEvent {
    [[self textStorage] removeAttribute:NSBackgroundColorAttributeName range:self.currentlyHighlightedRange];
    NSUInteger character = [self characterIndexForPoint:[NSEvent mouseLocation]];
    
    NSRange range = [self numberStringRangeForCharacterIndex:character];
    if (range.location == NSNotFound) {
        if (_currentlyHighlightedRange.location != NSNotFound) {
            // Only change this when it's not already set... skip some work, I suppose.
            self.currentlyHighlightedRange = range;
        }
        [[NSCursor arrowCursor] set];
        return;
    }
    
    // Found a number under the cursor
    self.currentlyHighlightedRange = range;
    NSColor *fontColor = [NSColor colorWithCalibratedRed:0.742 green:0.898 blue:0.397 alpha:1.000];
    [[self textStorage] addAttribute:NSBackgroundColorAttributeName value:fontColor range:range];
    
    // Show we can drag the number
    [[NSCursor resizeLeftRightCursor] set];
}


- (void)mouseDown:(NSEvent *)theEvent {
    if (self.currentlyHighlightedRange.location == NSNotFound) {
        [super mouseDown:theEvent];
        return;
    }
    
    self.initialDragPoint = [NSEvent mouseLocation];
    NSString *initialString = [[self string] substringWithRange:self.currentlyHighlightedRange];
    self.initialNumber = [self numberFromString:initialString];
    
    NSString *wholeText = [self string];
    self.initialNumberRange = self.currentlyHighlightedRange;
    
	
    NSRange originalCommandRange = [wholeText lineRangeForRange:self.currentlyHighlightedRange];
    self.initialDragCommandRange = originalCommandRange;
	
	if (self.dragStartedHandler) {
		self.dragStartedHandler(self, [wholeText substringWithRange:originalCommandRange]);
	}
}


- (void)mouseDragged:(NSEvent *)theEvent {
    
    // Skip it if we're not currently dragging a number
    if (self.currentlyHighlightedRange.location == NSNotFound) {
        [super mouseDragged:theEvent];
        return;
    }
    
    NSRange numberRange = [self rangeForNumberNearestToIndex:self.currentlyHighlightedRange.location];
    NSString *numberString = [[self string] substringWithRange:numberRange];
    
	
    NSNumber *number = [self numberFromString:numberString];
    
    if (nil == number) {
        NSLog(@"Couldn't parse a number out of :%@", numberString);
        return;
    }
    
    CGPoint screenPoint = [NSEvent mouseLocation];
    CGFloat x = screenPoint.x - self.initialDragPoint.x;
    CGFloat y = screenPoint.y - self.initialDragPoint.y;
    CGSize offset = CGSizeMake(x, y);
    
    
    NSInteger offsetValue = [self.initialNumber integerValue] + (NSInteger)offset.width;
    NSNumber *updatedNumber = @(offsetValue);
    NSString *updatedNumberString = [updatedNumber stringValue];
    
    [[self textStorage] replaceCharactersInRange:self.currentlyHighlightedRange withString:updatedNumberString];
    
    
    self.currentlyHighlightedRange = NSMakeRange(self.currentlyHighlightedRange.location, [updatedNumberString length]);
    
    
    if (self.numberDragHandler) {
        self.numberDragHandler(self, [self currentLineForRange:self.currentlyHighlightedRange]);
    }
}


- (void)mouseUp:(NSEvent *)theEvent {
    // Skip it if we're not currently dragging a word
    if (self.currentlyHighlightedRange.location == NSNotFound) {
        [super mouseUp:theEvent];
        return;
    }
	
	if (self.dragEndedHandler) {
		self.dragEndedHandler(self, [[self string] substringWithRange:self.initialDragCommandRange]);
	}
    
    // Triggers clearing out our number-dragging state.
    [self highlightText];
    [self mouseMoved:theEvent];
    
    
    self.initialNumber = nil;
    self.initialDragCommandRange = NSMakeRange(NSNotFound, NSNotFound);
}


#pragma mark - Number dragging helpers

- (void)setNumberString:(NSString *)string forRange:(NSRange)numberRange {
    // Just store the start location of the number, because the length might change (if, say, number goes from 100 -> 99)
    self.numberRanges[NSStringFromRange(numberRange)] = string;
}

- (NSRange)numberStringRangeForCharacterIndex:(NSUInteger)character {
    for (NSString *rangeString in self.numberRanges) {
        NSRange range = NSRangeFromString(rangeString);
        if (NSLocationInRange(character, range)) {
            return range;
        }
        
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSNumber *)numberFromString:(NSString *)string {
    static NSNumberFormatter *formatter = nil;
    if (nil == formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setAllowsFloats:YES];
    }
    return [formatter numberFromString:string];
}


- (NSRange)rangeForNumberNearestToIndex:(NSUInteger)index {
    // parse this out right now...
    NSRange originalRange = self.initialDragCommandRange;
    
    // Gets the line in range as it is currently in the textview's string
    NSString *currentLine = [self currentLineForRange:originalRange];
    
    PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:currentLine];
    
    tokenizer.commentState.reportsCommentTokens = YES;
    tokenizer.whitespaceState.reportsWhitespaceTokens = YES;
    
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *token = nil;
    
    
    NSUInteger currentLocation = 0; // in the command!
    
    while ((token = [tokenizer nextToken]) != eof) {
        
        NSRange numberRange = NSMakeRange(currentLocation + originalRange.location, [[token stringValue] length]);
        
        if ([token isNumber]) {
            if (NSLocationInRange(index, numberRange)) {
                return numberRange;
            }
        }
        
        
        currentLocation += [[token stringValue] length];
        
    }
    return NSMakeRange(NSNotFound, NSNotFound);
}


- (NSString *)currentLineForRange:(NSRange)originalRange {
    
    NSString *wholeString = [self string];
    
    NSRange lineRange = [wholeString lineRangeForRange:originalRange];
    return [wholeString substringWithRange:lineRange];
}


#pragma mark - Highlighting

- (void)highlightText {
	NSString *string = [[self textStorage] string];
	PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:string];
	
	tokenizer.commentState.reportsCommentTokens = NO;
	tokenizer.whitespaceState.reportsWhitespaceTokens = YES;
	
	
	PKToken *eof = [PKToken EOFToken];
	PKToken *token = nil;
	
	[[self textStorage] beginEditing];
	[self.numberRanges removeAllObjects];
	NSUInteger currentLocation = 0;
	
	while ((token = [tokenizer nextToken]) != eof) {
		NSColor *fontColor = [NSColor whiteColor];//[NSColor grayColor];
		
		NSRange numberRange = NSMakeRange(currentLocation, [[token stringValue] length]);
		
		if ([token isNumber]) {
			fontColor = [NSColor colorWithCalibratedWhite:0.890 alpha:1.000];
			[self setNumberString:[token stringValue] forRange:numberRange];
		} else {
			NSColor *bgColor = [[self textStorage] attribute:NSBackgroundColorAttributeName atIndex:numberRange.location effectiveRange:NULL];
			if (bgColor) fontColor = bgColor;
		}
		
		
		[[self textStorage] addAttribute:NSBackgroundColorAttributeName value:fontColor range:numberRange];
		currentLocation += [[token stringValue] length];
		
		
	}
	
	[[self textStorage] endEditing];
}


@end
