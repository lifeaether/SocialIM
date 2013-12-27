//
//  PredictEngine.m
//  SocialIM
//
//  Created by OverTaker on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PredictEngine.h"
#import "Constants.h"

@implementation PredictEngine

- (void)awakeFromNib
{
	if ( !receivedData ) {
		receivedData = [[NSMutableData alloc] init];
	}
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)del
{
	delegate = del;
}

- (BOOL)isFastPredicting
{
	return connect != nil;
}

- (void)cancelFastPredict
{
	if ( connect ) {
		[connect cancel];
		[connect release];
		connect = nil;
	}
}

- (void)fastPredict:(NSString *)string
{
	[lastPredictString release];
	lastPredictString = [string retain];
	NSString *encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *URLString = [NSString stringWithFormat:@"http://www.social-ime.com/api2/predict.php?string=%@&charset=UTF-8", encodedString];
	[self beginConnection:URLString];
}

- (void)beginConnection:(NSString *)URLString
{
	NSURL *URL = [NSURL URLWithString:URLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	[request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	[self cancelFastPredict];
	connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData
{
	[receivedData appendData:receiveData]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//(@"connection error");
	[self cancelFastPredict];
	if ( [delegate respondsToSelector:@selector(fastPredictDidError:)] ) {
		[delegate fastPredictDidError:self];
	}
}

extern NSArray * stringsFromSeparatedString( NSString *string );


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSLog( @"finish" );
	NSString *string = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
	NSArray *predicts = stringsFromSeparatedString( string );
	[self cancelFastPredict];
	if ( [delegate respondsToSelector:@selector(fastPredictDidFinish:predict:)] ) {
		/*
		NSInteger len = [lastPredictString length];
		for ( NSString *predict in predicts ) {
			if ( len < [predict length] ) {
				[delegate fastPredictDidFinish:self predict:predict];
				return;
			}
		}
		 */
		if ( [predicts count] > 0 ) {
			[delegate fastPredictDidFinish:self predict:[predicts objectAtIndex:0]];
		} else {
			[delegate fastPredictDidFinish:self predict:nil];
		}
	}
}

- (void)dealloc
{
	[lastPredictString release];
	[receivedData release];
	[super dealloc];
}


@end
