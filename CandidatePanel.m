//
//  CandidatePanel.m
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CandidatePanel.h"
#import "ApplicationDelegate.h"
#import "Constants.h"


@implementation CandidatePanel

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	NSPanel *panel = [super initWithContentRect:contentRect
									  styleMask:NSBorderlessWindowMask
										backing:bufferingType
										  defer:NO];;
	[panel setLevel:NSPopUpMenuWindowLevel];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[panel setAlphaValue:[[defaults valueForKey:kCandidateAlpha] floatValue]];
	[panel setOpaque:YES];
	
	float row = [[defaults valueForKey:kCandidateFontSize] floatValue] * 1.2;
	[defaults setValue:[NSNumber numberWithFloat:row] forKey:kCandidateRowHeight];
	
	NSRect rect = [self frame];
	rect.size.height = ([[defaults valueForKey:kCandidateRowHeight] floatValue] + 2.0) * [[defaults valueForKey:kCandidateCount] intValue];
	[self setFrame:rect display:YES animate:NO];
	
	return panel;
}

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:kCandidateCount options:NSKeyValueObservingOptionNew context:nil];
	[defaults addObserver:self forKeyPath:kCandidateFontSize options:NSKeyValueObservingOptionNew context:nil];
	[defaults addObserver:self forKeyPath:kCandidateRowHeight options:NSKeyValueObservingOptionNew context:nil];
	[defaults addObserver:self forKeyPath:kCandidateAlpha options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( [keyPath isEqualToString:kCandidateFontSize] ) {
		float row = [[object valueForKey:kCandidateFontSize] floatValue] * 1.2;
		[object setValue:[NSNumber numberWithFloat:row] forKey:kCandidateRowHeight];
	}
	
	if ( [keyPath isEqualToString:kCandidateRowHeight] || [keyPath isEqualToString:kCandidateCount] ) {
		NSRect rect = [self frame];
		rect.size.height = ([[object valueForKey:kCandidateRowHeight] floatValue] + 2.0) * [[object valueForKey:kCandidateCount] intValue];
		[self setFrame:rect display:YES animate:NO];
	}
	
	if ( [keyPath isEqualToString:kCandidateAlpha] ) {
		[self setAlphaValue:[[object valueForKey:kCandidateAlpha] floatValue]];
	}
}

- (NSTimeInterval)animationResizeTime:(NSRect)newWindowFrame
{
	return abs( newWindowFrame.size.width - [self frame].size.width ) / 150 * 0.1;
}

- (void)show:(id)sender
{
	if ( 0 < [candidates count] ) {
		NSArrayController *controller = [[NSApp delegate] candidates];
		[[controller content] removeAllObjects];
		for ( NSString *string in [candidates objectAtIndex:index] ) {
			[controller addObject:[NSDictionary dictionaryWithObject:string forKey:@"string"]];
		}
		[controller setSelectionIndex:index];
	} else {
		NSLog( @"No such candidates." );
	}
		
	NSRect rect = [self frame];
	rect.size.width = 150;
	[self setFrame:rect display:YES animate:NO];
	[self sizeToFit];
	
	[self makeKeyAndOrderFront:sender];
}

- (void)hide:(id)sender
{
	[self orderOut:sender];
}

- (void)sizeToFit
{
	NSCell *cell = [[[tableView tableColumns] objectAtIndex:0] dataCell];
	NSRect screen = [[NSScreen mainScreen] frame];
	
	[cell setStringValue:[[candidates objectAtIndex:index] objectAtIndex:indexes[index]]];
	float width = [cell cellSize].width;

	NSRect rect = [self frame];
	if ( rect.size.width < width + 20 ) {
		rect.size.width = width + 20;
	}
	
	if ( rect.origin.x + rect.size.width > screen.origin.x + screen.size.width ) {
		rect.origin.x = screen.origin.x + screen.size.width - rect.size.width;
	}
	
	
	[self setFrame:rect display:YES animate:YES];
}

- (void)setCandidates:(NSArray *)arrays
{	
	[self setCandidates:arrays restToIndex:-1];
}

- (void)setCandidates:(NSArray *)arrays restToIndex:(NSInteger)idx
{
	if ( [arrays count] <= MAX_CANDIDATE_SIZE ) {
		[candidates release];
		candidates = [arrays retain];
		if ( idx == -1 ) {
			memset( indexes, 0, sizeof( indexes ) );
		} else {
			memset( &indexes[idx], 0, sizeof( NSInteger )*(MAX_CANDIDATE_SIZE - idx) );
		}
		index = 0;
	} else {
		NSLog( @"count of candidates is larger than max size." );
	}
}

- (void)next:(id)sender
{
	//NSLog( @"next" );
	indexes[index]++;
	if ( indexes[index] >= [[candidates objectAtIndex:index] count] ) indexes[index] = 0;
	NSArrayController *controller = [[NSApp delegate] candidates];
	[controller setSelectionIndex:indexes[index]];
	
	[self sizeToFit];
	[tableView scrollRowToVisible:indexes[index]];
	
}

- (void)previous:(id)sender
{
	//NSLog( @"pre" );
	indexes[index]--;
	if ( indexes[index] < 0 ) indexes[index] = [[candidates objectAtIndex:index] count]-1;
	
	NSArrayController *controller = [[NSApp delegate] candidates];
	[controller setSelectionIndex:indexes[index]];
	
	[self sizeToFit];
	[tableView scrollRowToVisible:indexes[index]];
}

- (NSInteger)selectionIndex:(NSInteger)idx
{
	if ( 0 <= idx && idx < [candidates count] ) {
		return indexes[idx];
	} else {
		return 0;
	}
}

- (void)nextCandidate:(id)sender
{
	[self setIndexOfCandidate:index+1];
	[self orderOut:sender];
}

- (void)previousCandidate:(id)sender
{
	[self setIndexOfCandidate:index-1];
	[self orderOut:sender];
}

- (void)setIndexOfCandidate:(NSInteger)idx
{
	index = idx;
	//NSLog(@"candidate index %d", index);
	if ( index < 0 ) index = 0;
	if ( index >= [candidates count] ) index = [candidates count]-1;
}

- (NSInteger)indexOfCandidate
{
	return index;
}

- (NSAttributedString *)composedString
{
	NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] init] autorelease];
	NSMutableString *string = [att mutableString];
	
	NSRange range = {0, 0};
	NSNumber *width;
	int i = 0;
	for ( NSArray *array in candidates ) {
		[string appendString:[array objectAtIndex:indexes[i]]];
		range.length = [string length] - range.location;
		
		if ( i == index ) {
			width = [NSNumber numberWithFloat:2.0];
			selectingRange = range;
		} else {
			if ( i % 2 ) {
				width = [NSNumber numberWithFloat:1.0];
			} else {
				width = [NSNumber numberWithFloat:1.1];
			}
		}
		
		[att addAttribute:NSUnderlineStyleAttributeName value:width range:range];
		range.location += range.length;
		i++;
	}
	
	return att;
}

- (NSRange)rangeOfSelecting
{
	return selectingRange;
}

- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:kCandidateCount];
	[defaults removeObserver:self forKeyPath:kCandidateFontSize];
	[defaults removeObserver:self forKeyPath:kCandidateRowHeight];
	[defaults removeObserver:self forKeyPath:kCandidateAlpha];
	
	[candidates release];
	[super dealloc];
}

@end
