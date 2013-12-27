//
//  PreferencesController.h
//  SocialIM
//
//  Created by OverTaker on 09/03/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSObject {
	IBOutlet NSPopUpButton *fontPopUpButton;
	IBOutlet NSPanel *panel;
	
	NSDictionary *fonts;
}

- (IBAction)setCandidateFont:(id)sender;
- (IBAction)colorWell:(id)sender;
- (void)changeColor:(id)sender;
@end
