//
//  CandidateTableView.m
//  SocialIM
//
//  Created by OverTaker on 09/02/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CandidateTableView.h"
#import "Constants.h"

@implementation CandidateTableView

- (void)awakeFromNib
{
	[self setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
}

- (NSColor *)_highlightColorForCell: (NSCell *) aCell
{
	return [NSColor colorWithCalibratedRed:0.713 green:1.0 blue:0.729 alpha:1.0];
/*	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:kCandidateSelectionColor]];*/
}

@end
