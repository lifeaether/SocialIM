//
//  PreferencesController.m
//  SocialIM
//
//  Created by OverTaker on 09/03/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"
#import "Constants.h"

@implementation PreferencesController

- (void)awakeFromNib
{
	[fontPopUpButton removeAllItems];
	
	NSFontManager *manager = [NSFontManager sharedFontManager];
	fonts = [[NSMutableDictionary alloc] init];
	for ( NSString *name in [manager availableFontFamilies] ) {
		NSString *title = [manager localizedNameForFamily:name face:nil];
		[fonts setValue:name forKey:title];
		[fontPopUpButton addItemWithTitle:title];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[fontPopUpButton selectItemWithTitle:[manager localizedNameForFamily:[defaults valueForKey:kCandidateFontName] face:nil]];
}

- (IBAction)setCandidateFont:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[fonts valueForKey:[[sender selectedItem] title]] forKey:kCandidateFontName];
}

- (IBAction)colorWell:(id)sender
{
	NSLog(@"color well");
	
	NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[colorPanel setDelegate:self];
	[colorPanel setColor:[defaults valueForKey:kCandidateSelectionColor]];
	[colorPanel makeKeyAndOrderFront:sender];
	 
	[[NSUserDefaults standardUserDefaults] setValue:[sender color] forKey:kCandidateSelectionColor];

}

- (void)changeColor:(id)sender
{
	NSLog(@"change color");
	[[NSUserDefaults standardUserDefaults] setValue:[sender color] forKey:kCandidateSelectionColor];
}

- (void)dealloc
{
	[fonts release];
	[super dealloc];
}

@end
