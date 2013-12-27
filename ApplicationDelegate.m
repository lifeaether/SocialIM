//
//  ApplicationDelegate.m
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationDelegate.h"

@implementation ApplicationDelegate

-(void)awakeFromNib
{
	[[menu itemWithTag:10] setAction:@selector(showPreferences:)];
	[[menu itemWithTag:11] setAction:@selector(openHelp:)];
	[[menu itemWithTag:12] setAction:@selector(openWebSite:)];
	[[menu itemWithTag:13] setAction:@selector(registerWord:)];
}

- (ConversionEngine *)conversionEngine
{
	return conversionEngine;
}

- (PredictEngine *)predictEngine
{
	return predictEngine;
}

- (CandidatePanel *)candidatePanel
{
	return candidatePanel;
}

- (FastPredictPanel *)fastPredictPanel
{
	return fastPredictPanel;
}

- (SubPanel *)subPanel
{
	return subPanel;
}

- (NSArrayController *)candidates
{
	return candidates;
}

- (NSWindowController *)registerController
{
	return registerController;
}

- (NSMenu *)menu
{
	return menu;
}

@end
