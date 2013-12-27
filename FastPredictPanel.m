//
//  FastPredictPanel.m
//  SocialIM
//
//  Created by OverTaker on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FastPredictPanel.h"
#import "Constants.h"

@implementation FastPredictPanel

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	NSPanel *panel = [super initWithContentRect:contentRect
									  styleMask:NSBorderlessWindowMask
										backing:bufferingType
										  defer:NO];;
	[panel setLevel:NSPopUpMenuWindowLevel];
	[panel setBackgroundColor:[NSColor whiteColor]];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[panel setAlphaValue:[[defaults valueForKey:kCandidateAlpha] floatValue]];
	[panel setOpaque:YES];
	
	return panel;
}

- (void)show:(id)sender
{
	NSRect rect = [self frame];
	NSRect screen = [[NSScreen mainScreen] frame];
	float width = [[predictText cell] cellSize].width;
	if ( width > 150 ) {
		rect.size.width = width;
	} else {
		rect.size.width = 150;
	}
	if ( rect.origin.x + rect.size.width > screen.size.width ) {
		rect.origin.x = screen.size.width - rect.size.width;
	}
	[self setFrame:rect display:YES animate:NO];
	
	[self makeKeyAndOrderFront:sender];
}

- (void)hide:(id)sender
{
	[self orderOut:sender];
}

- (NSString *)predictString
{
	return [predictText stringValue];
}

- (void)setPredictString:(NSString *)string
{
	[predictText setStringValue:string];
}


@end
