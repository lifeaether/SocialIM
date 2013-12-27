//
//  PredictEngine.h
//  SocialIM
//
//  Created by OverTaker on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PredictEngine : NSObject {
	id delegate;
	
	NSURLConnection *connect;
	NSMutableData *receivedData;
	
	NSString *lastPredictString;
}

- (id)delegate;
- (void)setDelegate:(id)del;

- (void)fastPredict:(NSString *)string;
- (BOOL)isFastPredicting;
- (void)cancelFastPredict;

- (void)beginConnection:(NSString *)URLString;

@end

@interface NSObject (PredictEngineDelegate)

- (void)fastPredictDidFinish:(id)predictor predict:(NSString *)string;
- (void)fastPredictDidError:(id)predictor;

@end