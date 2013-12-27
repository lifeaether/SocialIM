//
//  ApplicationDelegate.h
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversionEngine.h"
#import "PredictEngine.h"
#import "CandidatePanel.h"
#import "FastPredictPanel.h"
#import "SubPanel.h"

@interface ApplicationDelegate : NSObject {
	IBOutlet ConversionEngine *conversionEngine;
	IBOutlet PredictEngine *predictEngine;
	IBOutlet CandidatePanel *candidatePanel;
	IBOutlet FastPredictPanel *fastPredictPanel;
	IBOutlet SubPanel *subPanel;
	IBOutlet NSArrayController *candidates;
	
	IBOutlet NSWindowController *registerController;
	
	IBOutlet NSMenu *menu;
}

- (ConversionEngine *)conversionEngine;
- (PredictEngine *)predictEngine;
- (CandidatePanel *)candidatePanel;
- (FastPredictPanel *)fastPredictPanel;
- (SubPanel *)subPanel;
- (NSArrayController *)candidates;

- (NSWindowController *)registerController;

- (NSMenu *)menu;


@end
