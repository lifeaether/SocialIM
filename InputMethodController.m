//
//  InputMethodController.m
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InputMethodController.h"
#import "ConversionEngine.h"
#import "PredictEngine.h"
#import "ApplicationDelegate.h"
#import "CandidatePanel.h"
#import "Constants.h"

#define HELP_URL @"http://www7b.biglobe.ne.jp/~lifeaether/SocialIM/help.html"
#define WEBSITE_URL @"http://www7b.biglobe.ne.jp/~lifeaether/SocialIM/"


@implementation InputMethodController

- (NSMenu *)menu
{
	return [[NSApp delegate] menu];
}

- (void)openHelp:(id)sender
{
	NSWorkspace *work = [NSWorkspace sharedWorkspace];
	[work openURL:[NSURL URLWithString:HELP_URL]];
}

- (void)openWebSite:(id)sender
{
	NSWorkspace *work = [NSWorkspace sharedWorkspace];
	[work openURL:[NSURL URLWithString:WEBSITE_URL]];
}

- (void)registerWord:(id)sender
{
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"RegisterWord.app"];
	[[NSWorkspace sharedWorkspace] openFile:path];
}

-(void)setValue:(id)value forTag:(unsigned long)tag client:(id)sender
{
	NSString *mode = [value retain];
	
	if ( [mode isEqualToString:kKanaMode] ) {
		currentMode = KanaInputMode;
	} 
	if  ( [mode isEqualToString:kRomanMode] )  {
		currentMode = RomanInputMode;
	}
	
	[self commitComposition:sender];
	
	[mode release];
}

- (NSMutableString *)originalString
{
	if ( originalString ) {
		return originalString;
	} else {
		return originalString = [[NSMutableString alloc] init];
	}
}

- (void)setOriginalString:(NSString *)string
{
	NSMutableString *buffer = [self originalString];
	[buffer setString:string];
}

- (void)originalStringInsert:(NSString *)string
{
	NSMutableString *buffer = [self originalString];
	[buffer insertString:string atIndex:insertionIndex];
	insertionIndex += [string length];
	
	NSString *head, *composable, *tail;
	int index;
	
	if ( [[[NSUserDefaults standardUserDefaults] valueForKey:kInputModeIndex] intValue] == 0 ) {
		if ( [string isEqualToString:@"@"] && insertionIndex > 1 ) {
			index = insertionIndex - 2;
		} else {
			index = insertionIndex - 1;
		}
	} else {
		for ( index = insertionIndex; index > 0; index-- ) {
			if ( [buffer characterAtIndex:index-1] >= 128 ) break;
		}
	}
	
	head = [buffer substringToIndex:index];
	composable = [buffer substringWithRange:NSMakeRange(index, insertionIndex - index)];
	tail = [buffer substringFromIndex:insertionIndex];
	
	ConversionEngine *engine = [[NSApp delegate] conversionEngine];
	NSString *kana;
	if ( [[[NSUserDefaults standardUserDefaults] valueForKey:kInputModeIndex] intValue] == 0 ) {
		kana = [engine kanaConvert:composable];
	} else {
		kana = [engine romaKanaConvert:composable];
	}
		
	[buffer setString:head];
	[buffer appendString:kana];
	[buffer appendString:tail];
	
	insertionIndex += [kana length] - [composable length];
	[self setOriginalString:buffer];
	[self setComposedString:buffer];
	[self markOriginalString];
	//NSLog( buffer );
}

- (void)markOriginalString
{
	NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:[self originalString]] autorelease];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ( [[defaults valueForKey:kUseThinUnderline] boolValue] ) {
		[att addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithFloat:1.0] range:NSMakeRange(0, [[self originalString] length])];
	} else {
		[att addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithFloat:2.0] range:NSMakeRange(0, [[self originalString] length])];
	}
	[currentClient setMarkedText:att selectionRange:NSMakeRange(insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}


- (NSMutableString *)kanaString
{
	if ( kanaString ) {
		return kanaString;
	} else {
		return kanaString = [[NSMutableString alloc] init];
	}
}

- (void)setKanaString:(NSString *)string
{
	NSMutableString *buffer = [self kanaString];
	[buffer setString:string];
}

- (NSMutableString *)composedString
{
	if ( composedString ) {
		return composedString;
	} else {
		return composedString = [[NSMutableString alloc] init];
	}
}

- (void)setComposedString:(NSString *)string
{
	NSMutableString *buffer = [self composedString];
	[buffer setString:string];
}

- (void)markComposedString
{
	NSString *buffer = [self composedString];
	NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:buffer] autorelease];
	[currentClient setMarkedText:att selectionRange:NSMakeRange([buffer length], 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

- (void)updateComposedString
{
	CandidatePanel *panel = [[NSApp delegate] candidatePanel];
	NSAttributedString *att = [panel composedString];
	[self setComposedString:[att string]];
	[currentClient setMarkedText:att
				  selectionRange:NSMakeRange([[att string] length], 0)
				replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

- (NSString *)predictString
{
	return predictString;
}

- (void)setPredictString:(NSString *)string
{
	[predictString release];
	predictString = [string copy];
}


- (void)kanjiConvertDidFinish:(id)converter candidates:(NSArray *)arrays
{
	phraseSize = [arrays count];
	if ( [arrays count] > MAX_PHRASE_SIZE ) {
		NSLog( @"phrase is larger than max value." );
		return;
	}
	memset( sizes , 0, sizeof( sizes ) );
	
	NSString *buffer = [self originalString];
	NSInteger length = [[self originalString] length];
	NSInteger index = 0;
	NSRange  range = { 0, 0 };
	for ( NSArray *array in arrays ) {
		range.location = NSMaxRange(range);
		for ( range.length = 1; NSMaxRange(range) < length; range.length++ ) {
			if ( [array indexOfObject:[buffer substringWithRange:range]] != NSNotFound ) break;
		}
		sizes[index] = range.length;
		index++;
	}
	
	CandidatePanel *panel = [[NSApp delegate] candidatePanel];
	[panel setCandidates:arrays restToIndex:phraseIndex];
	[panel setIndexOfCandidate:phraseIndex];
	[self updateComposedString];
}

- (void)kanjiConvertDidError:(id)converter
{
	SubPanel * panel = [[NSApp delegate] subPanel];
	NSRange range = [[[NSApp delegate] candidatePanel] rangeOfSelecting];
	NSRect rect = [currentClient firstRectForCharacterRange:range];
	rect.origin.y += rect.size.height*1.75;
	rect.origin.x += 15;
	[panel setFrameOrigin:rect.origin];
	[panel show:currentClient];
	isConverting = NO;
}

- (void)fastPredictDidFinish:(id)predictor predict:(NSString *)string
{
	FastPredictPanel *panel = [[NSApp delegate] fastPredictPanel];
	
	if ( string ) {
		[self setPredictString:string];
		[panel setPredictString:string];
		
		NSRect rect = [currentClient firstRectForCharacterRange:NSMakeRange(0,0)];
		rect.origin.y += rect.size.height*1.75;
		rect.origin.x += 15;
		[panel setFrameOrigin:rect.origin];
		[panel show:currentClient];
	} else {
		[self setPredictString:nil];
		[panel hide:currentClient];
	}
}

- (void)fastPredictDidError:(id)predictor
{
	NSLog(@"predict error");
}

- (void)inputMove:(unichar)c
{
	//NSLog(@"move.");
	switch ( c ) {
		case 0x1C:
			[self moveLeft:currentClient];
			break;
		case 0x1D:
			[self moveRight:currentClient];
			break;
		case 0x1E:
			[self moveUp:currentClient];
			break;
		case 0x1F:
			[self moveDown:currentClient];
			break;
		default:
			break;
	}
}

- (void)inputSpace
{ 
	ConversionEngine *engine = [[NSApp delegate] conversionEngine];
	
	if ( isConverting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		if ( isSelecting ) {
			[self moveDown:currentClient];
		} else {
			if ( ![engine isKnajiConverting] ) {
				isSelecting = YES;
				
				NSRange range = [panel rangeOfSelecting];
				NSRect rect = [currentClient firstRectForCharacterRange:range];
				NSRect screen = [[NSScreen mainScreen] frame];
				if ( rect.origin.y - [panel frame].size.height > screen.origin.y ) {
					rect.origin.y -= [panel frame].size.height;
				} else {
					rect.origin.y += rect.size.height*2;
				}
				rect.origin.x -= 5;
				[panel setFrameOrigin:rect.origin];
				
				[panel show:currentClient];
				[self moveDown:currentClient];
			}
		}
	} else {
		[[[NSApp delegate] predictEngine] cancelFastPredict];
		[[[NSApp delegate] fastPredictPanel] hide:currentClient];
		[self setPredictString:nil];
		
		NSMutableString *buffer = [self originalString];
		[buffer replaceOccurrencesOfString:@"n" withString:@"ん" options:NSLiteralSearch range:NSMakeRange( [buffer length]-1, 1 )];
		isConverting = YES;
		phraseIndex = 0;
		[engine setDelegate:self];
		[engine kanjiConvert:buffer];
	}
}

- (void)inputTab
{
	if ( [self predictString] ) {
		[self setComposedString:[self predictString]];
		[self commitComposition:currentClient];
	}
}

- (void)cancelConvert
{
	[[[NSApp delegate] conversionEngine] cancelKanjiConvert];
	[[[NSApp delegate] candidatePanel] hide:currentClient];
	isConverting = NO;
	isSelecting = NO;
}

- (BOOL)dispatchAction:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
	
	if ( (flags & NSControlKeyMask) == NSControlKeyMask ) {
		//NSLog( @"control down" );
		switch ( keyCode ) {
			case 3:
				return [self didCommandBySelector:@selector(moveRight:) client:sender];
			case 11:
				return [self didCommandBySelector:@selector(moveLeft:) client:sender];
			case 35:
				return [self didCommandBySelector:@selector(moveUp:) client:sender];
			case 45:
				return [self didCommandBySelector:@selector(moveDown:) client:sender];
			case 4:
				return [self didCommandBySelector:@selector(deleteBackward:) client:sender];
			case 2:
				return [self didCommandBySelector:@selector(deleteForward:) client:sender];
			case 51:
				return [self didCommandBySelector:@selector(deleteForward:) client:sender];
			case 40:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] katakanaConvert:[self originalString]]];
					[self markComposedString];
					return YES;
				}
				break;
			case 38:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[self originalString]];
					[self markOriginalString];
					return YES;
				}
				break;
			case 41:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] halfkatakanaConvert:[self originalString]]];
					[self markComposedString];
					return YES;
				}
				break;
		}
	} else if ( (flags & NSShiftKeyMask) == NSShiftKeyMask ) {
		//NSLog( @"shift down" );
		switch ( keyCode ) {
			case 124:
				return [self didCommandBySelector:@selector(moveForwardAndModifySelection:) client:sender];
			case 123:
				return [self didCommandBySelector:@selector(moveBackwardAndModifySelection:) client:sender];
			case 49:
				if ( [[self originalString] length] > 0 ) {
					[self inputSpace];
				} else {
					[sender insertText:@" " replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
				}
				return YES;
			case 29:
				if ( [[[NSUserDefaults standardUserDefaults] valueForKey:kInputModeIndex] intValue] == kKanaInputModeIndex ) {
					return [self inputText:@"を" client:sender];
				}
				break;
		}
	} else if ( (flags & NSAlternateKeyMask) == NSAlternateKeyMask ) {
		switch ( keyCode ) {
			case 0:
			case 118:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] halfkatakanaConvert:[self originalString]]];
					[self markComposedString];
					return YES;
				}
				break;
			case 7:
			case 102:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] katakanaConvert:[self originalString]]];
					[self markComposedString];
					return YES;
				}
				break;
			case 122:
			case 6:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[self originalString]];
					[self markOriginalString];
					return YES;
				}
				break;
		}
	} else {
		switch ( keyCode ) {
			case 124:
				return [self didCommandBySelector:@selector(moveRight:) client:sender];
			case 123:
				return [self didCommandBySelector:@selector(moveLeft:) client:sender];
			case 126:
				return [self didCommandBySelector:@selector(moveUp:) client:sender];
			case 125:
				return [self didCommandBySelector:@selector(moveDown:) client:sender];
			case 36:
				return [self didCommandBySelector:@selector(insertNewline:) client:sender];
			case 76:
				return [self didCommandBySelector:@selector(insertNewline:) client:sender];
			case 51:
				return [self didCommandBySelector:@selector(deleteBackward:) client:sender];
			case 117:
				return [self didCommandBySelector:@selector(deleteForward:) client:sender];
			case 48:
				if ( [[self originalString] length] > 0 ) {
					[self inputTab];
					return YES;
				}
				break;
			case 49:
				if ( [[self originalString] length] > 0 ) {
					[self inputSpace];
				} else {
					[sender insertText:@"　" replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
				}
				return YES;
			case 53:
			case 97:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[self originalString]];
					[self markOriginalString];
					return YES;
				}
				break;
			case 98:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] katakanaConvert:[self originalString]]];
					[self markComposedString];
				return YES;
				}
				break;
			case 100:
				if ( [[self originalString] length] > 0 ) {
					[self cancelConvert];
					[self setComposedString:[[[NSApp delegate] conversionEngine] halfkatakanaConvert:[self originalString]]];
					[self markComposedString];
					return YES;
				}
				break;
		}
		
		if ( [[[NSUserDefaults standardUserDefaults] valueForKey:kInputModeIndex] intValue] == kRomanInputModeIndex ) {
			switch ( keyCode ) {
				case 18:
					return [self inputText:@"１" client:sender];
				case 19:
					return [self inputText:@"２" client:sender];
				case 20:
					return [self inputText:@"３" client:sender];
				case 21:
					return [self inputText:@"４" client:sender];
				case 22:
					return [self inputText:@"６" client:sender];
				case 23:
					return [self inputText:@"５" client:sender];
				case 25:
					return [self inputText:@"９" client:sender];
				case 26:
					return [self inputText:@"７" client:sender];
				case 28:
					return [self inputText:@"８" client:sender];
				case 29:
					return [self inputText:@"０" client:sender];
			}
		}
	}
	return NO;
}

- (BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
	//NSLog( @"code = %d, flag = %d, key = %@", keyCode, flags, string );
	
	currentClient = sender;
	[[[NSApp delegate] subPanel] hide:currentClient];
	if ( (flags & NSControlKeyMask) == NSControlKeyMask && (flags & NSShiftKeyMask) == NSShiftKeyMask ) return NO;
	if ( keyCode == 102 || keyCode == 104 ) return YES;
	if ( currentMode == RomanInputMode ) return NO;
	
	BOOL ret = [self dispatchAction:keyCode modifiers:flags client:sender];
	
	if ( !ret && (flags == 0 || flags == NSShiftKeyMask || flags == NSAlternateKeyMask || flags == NSAlphaShiftKeyMask || flags == (NSShiftKeyMask | NSAlternateKeyMask))  ) {
		ret = [self inputText:string client:sender];
	}
	
	return ret;
}

- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender
{
	//NSLog( @"command received." );
	if ( [self respondsToSelector:aSelector] && [[self originalString] length] > 0 ) {
		[self performSelector:aSelector withObject:sender];
		return YES;
	}
	return NO;
}

- (BOOL)inputText:(NSString*)string client:(id)sender
{
	//NSLog( @"recieved %@", string );
	unichar c = [string characterAtIndex:0];
	if ( c > 0x20 ) {
		if ( isConverting ) [self commitComposition:sender];
		[self originalStringInsert:string];
		/*
		NSInteger len = [[self originalString] length];
		if ( 0 < len ) {
			PredictEngine *engine = [[NSApp delegate] predictEngine];
			[engine setDelegate:self];
			[engine fastPredict:[self originalString]];
		} else {
			[[[NSApp delegate] fastPredictPanel] hide:currentClient];
			[self setPredictString:nil];
		}
		 */
		return YES;
	} else {
		return NO;
	}
}

- (void)commitComposition:(id)sender
{
	//NSLog( @"commit" );
	if ( [[self originalString] length] == 0 ) return;
	
	[self cancelConvert];
	[[[NSApp delegate] predictEngine] cancelFastPredict];
	[[[NSApp delegate] fastPredictPanel] hide:currentClient];
	[self setPredictString:nil];
	
	ConversionEngine *engine = [[NSApp delegate] conversionEngine];
	CandidatePanel *panel = [[NSApp delegate] candidatePanel];
	[[[NSApp delegate] subPanel] hide:currentClient];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ( isConverting && [[defaults valueForKey:kSendResult] boolValue] ) {
		//NSLog( @"report" );
		BOOL doCommit = NO;
		NSMutableArray *array = [NSMutableArray array];
		for ( int i = 0; i < phraseSize; i++ ) {
			if ( [panel selectionIndex:i] != 0 ) doCommit = YES;
			[array addObject:[NSNumber numberWithInt:[panel selectionIndex:i]]];
		}
		if ( doCommit ) [engine commitLastKanjiConvert:array];
	}
	
	NSString *buffer = [self composedString];
	[sender insertText:buffer replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	
	[self setOriginalString:@""];
	[self setComposedString:@""];
	insertionIndex = 0;
	
	memset( resizes , 0, sizeof( resizes ) );
}

- (void)insertNewline:(id)sender
{
	if ( isSelecting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel hide:currentClient];
		[panel nextCandidate:currentClient];
		[self updateComposedString];
		isSelecting = NO;
	} else {
		[self commitComposition:sender];
	}
}

- (void)moveForwardAndModifySelection:(id)sender
{
	//NSLog( @"move forward and modify" );
	if ( isConverting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel hide:currentClient];
		isSelecting = NO;
		
		phraseIndex = [panel indexOfCandidate];
		NSInteger sum = 0;
		for ( int i = 0; i <= phraseIndex; i++ ) {
			sum += sizes[i];
		}
		if ( sum < [[self originalString] length] ) {
			resizes[phraseIndex]++;
			memset( &sizes[phraseIndex+1] , 0, sizeof( NSInteger )*(MAX_PHRASE_SIZE -phraseIndex-1) );
			
			NSMutableArray *array = [NSMutableArray array];
			for ( int i = 0; i < phraseSize; i++ ) {
				[array addObject:[NSNumber numberWithInt:resizes[i]]];
			}
			
			ConversionEngine *engine = [[NSApp delegate] conversionEngine];
			[engine setDelegate:self];
			[engine kanjiConvert:[self originalString] resize:array];
		}
	}
}

- (void)moveBackwardAndModifySelection:(id)sender
{
	//NSLog( @"move backward and modify" );
	if ( isConverting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel hide:currentClient];
		isSelecting = NO;
		
		phraseIndex = [panel indexOfCandidate];
		
		if ( sizes[phraseIndex] > 1 ) {
			resizes[phraseIndex]--;
			
			memset( &sizes[phraseIndex+1] , 0, sizeof( NSInteger )*(MAX_PHRASE_SIZE -phraseIndex-1) );
			
			NSMutableArray *array = [NSMutableArray array];
			for ( int i = 0; i < phraseSize; i++ ) {
				[array addObject:[NSNumber numberWithInt:resizes[i]]];
			}
			
			ConversionEngine *engine = [[NSApp delegate] conversionEngine];
			[engine setDelegate:self];
			[engine kanjiConvert:[self originalString] resize:array];
		}
	}
}

- (void)moveUp:(id)sender
{
	if ( isSelecting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel previous:currentClient];
		[self updateComposedString];
	}
}

- (void)moveDown:(id)sender
{
	if ( isSelecting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel next:currentClient];
		[self updateComposedString];
	}	
}

- (void)moveLeft:(id)sender
{
	if ( isConverting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel previousCandidate:currentClient];
		[self updateComposedString];
		isSelecting = NO;
	} else {
		if ( 0 < insertionIndex ) {
			insertionIndex--;
			[self markOriginalString];
		}
	}
}

- (void)moveRight:(id)sender
{
	if ( isConverting ) {
		CandidatePanel *panel = [[NSApp delegate] candidatePanel];
		[panel nextCandidate:currentClient];
		[self updateComposedString];
		isSelecting = NO;
	} else {
		if ( insertionIndex < [[self originalString] length] ) {
			insertionIndex++;
			[self markOriginalString];
		}
	}
}

- (void)moveBackward:(id)sender
{
	[self moveLeft:sender];
}

- (void)moveForward:(id)sender
{
	[self moveRight:sender];
}

- (void)moveToBeginningOfLine:(id)sender
{
	insertionIndex = 0;
	[self markOriginalString];
}

- (void)moveToEndOfLine:(id)sender
{
	insertionIndex = [[self originalString] length];
	[self markOriginalString];
}

- (void)deleteBackward:(id)sender
{
	if ( insertionIndex > 0 ) {
		[[[NSApp delegate] predictEngine] cancelFastPredict];
		[[[NSApp delegate] fastPredictPanel] hide:currentClient];
		[self setPredictString:nil];
		
		NSMutableString *buffer = [self originalString];
		
		if ( isConverting ) {
			[self cancelConvert];
		} else {
			insertionIndex--;
			[buffer deleteCharactersInRange:NSMakeRange(insertionIndex, 1)];
		}
		
		[self setComposedString:buffer];
		[self markOriginalString];
	}
}

- (void)deleteForward:(id)sender
{
	NSMutableString *buffer = [self originalString];
	if ( insertionIndex < [buffer length] ) {
		[[[NSApp delegate] predictEngine] cancelFastPredict];
		[[[NSApp delegate] fastPredictPanel] hide:currentClient];
		[self setPredictString:nil];
		
		if ( isConverting ) {
			[self cancelConvert];
		} else {
			[buffer deleteCharactersInRange:NSMakeRange(insertionIndex, 1)];
		}
		
		[self setComposedString:buffer];
		[self markOriginalString];
	}
}

- (void)dealloc
{
	[originalString release];
	[kanaString release];
	[composedString release];
	[predictString release];
	[super dealloc];
}

@end
