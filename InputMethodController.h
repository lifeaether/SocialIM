//
//  InputMethodController.h
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

#define MAX_PHRASE_SIZE 32

typedef enum {
	KanaInputMode,
	RomanInputMode
} InputMode;

@interface InputMethodController : IMKInputController {
	InputMode currentMode;
	
	id currentClient;
	NSMutableString *originalString;
	NSMutableString *kanaString;
	NSMutableString *composedString;
	NSInteger insertionIndex;
	
	NSString *predictString;
	
	NSInteger phraseSize;
	NSInteger phraseIndex;
	NSInteger sizes[MAX_PHRASE_SIZE];
	NSInteger resizes[MAX_PHRASE_SIZE];
	
	BOOL isConverting;
	BOOL isSelecting;
}

- (NSMutableString *)originalString;
- (void)setOriginalString:(NSString *)string;
- (void)originalStringInsert:(NSString *)string;
- (void)markOriginalString;
//- (void)markOriginalString:(NSColor *)color;
- (NSMutableString *)kanaString;
- (void)setKanaString:(NSString *)string;
- (NSMutableString *)composedString;
- (void)setComposedString:(NSString *)string;
- (void)markComposedString;

- (void)updateComposedString;

- (NSString *)predictString;
- (void)setPredictString:(NSString *)string;

- (BOOL)dispatchAction:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender;
- (void)inputMove:(unichar)c;
- (void)inputSpace;
- (void)inputTab;
- (void)cancelConvert;


- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;
- (void)moveLeft:(id)sender;
- (void)moveRight:(id)sender;

@end
