//
//  SubPanel.m
//  SocialIM
//
//  Created by OverTaker on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SubPanel.h"
#import "Constants.h"

@implementation SubPanel

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
	
	return panel;
}

- (void)show:(id)sender
{	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self setAlphaValue:[[defaults valueForKey:kCandidateAlpha] floatValue]];

	NSRect screen = [[NSScreen mainScreen] frame];
	NSRect rect = [self frame];
	if ( rect.origin.x + rect.size.width > screen.size.width ) {
		rect.origin.x = screen.size.width - rect.size.width;
	}
	[self setFrame:rect display:YES];
	
	[self makeKeyAndOrderFront:sender];
}

- (void)hide:(id)sender
{
	[self orderOut:sender];
}


@end
