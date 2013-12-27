//
//  FastPredictPanel.h
//  SocialIM
//
//  Created by OverTaker on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FastPredictPanel : NSPanel {
	IBOutlet NSTextField *predictText;
}

- (void)show:(id)sender;
- (void)hide:(id)sender;

- (NSString *)predictString;
- (void)setPredictString:(NSString *)string;

@end
