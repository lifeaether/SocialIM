//
//  ConversionEngine.h
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConversionEngine : NSObject {
	NSDictionary *romaKanaMap;
	NSDictionary *kanaMap;
	NSDictionary *katakanaMap;
	NSDictionary *halfkatakanaMap;
	
	id delegate;
	
	NSString *lastURLString;
	NSURLConnection *connect;
	NSMutableData *receivedData;
}

- (NSDictionary *)romaKanaMap;
- (NSDictionary *)kanaMap;
- (NSDictionary *)katakanaMap;
- (NSDictionary *)halfkatakanaMap;

- (id)delegate;
- (void)setDelegate:(id)del;

- (NSString *)romaKanaConvert:(NSString *)string;
- (NSString *)kanaConvert:(NSString *)string;

- (NSString *)katakanaConvert:(NSString *)string;
- (NSString *)halfkatakanaConvert:(NSString *)string;

- (void)kanjiConvert:(NSString *)string;
- (void)commitLastKanjiConvert:(NSArray *)indexes;
- (void)kanjiConvert:(NSString *)string resize:(NSArray *)resizes;
- (BOOL)isKnajiConverting;
- (void)cancelKanjiConvert;

- (void)beginConnection:(NSString *)URLString;

@end

@interface NSObject (ConversionEngineDelegate)

- (void)kanjiConvertDidFinish:(id)converter candidates:(NSArray *)arrays;
- (void)kanjiConvertDidError:(id)converter;

@end