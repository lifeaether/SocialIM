//
//  CandidatePanel.h
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MAX_CANDIDATE_SIZE 32

@interface CandidatePanel : NSPanel {
	NSArray *candidates;
	NSInteger indexes[MAX_CANDIDATE_SIZE];
	NSInteger index;
	NSRange selectingRange;
	
	IBOutlet NSTableView *tableView;
}

- (void)show:(id)sender;
- (void)hide:(id)sender;
- (void)sizeToFit;

- (void)setCandidates:(NSArray *)arrays;
- (void)setCandidates:(NSArray *)arrays restToIndex:(NSInteger)idx;

- (void)next:(id)sender;
- (void)previous:(id)sender;
- (NSInteger)selectionIndex:(NSInteger)idx;
- (void)previousCandidate:(id)sender;
- (void)nextCandidate:(id)sender;

- (NSInteger)indexOfCandidate;
- (void)setIndexOfCandidate:(NSInteger)idx;

- (NSAttributedString *)composedString;
- (NSRange)rangeOfSelecting;

@end
