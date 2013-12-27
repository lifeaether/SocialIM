//
//  ConversionEngine.m
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConversionEngine.h"
#import "Constants.h"

@implementation ConversionEngine

- (void)awakeFromNib
{
	if ( !receivedData ) {
		receivedData = [[NSMutableData alloc] init];
	}
}

- (NSDictionary *)romaKanaMap
{
	if ( romaKanaMap ) {
		return romaKanaMap;
	} else {
		NSString * path = [[NSBundle mainBundle] resourcePath];
		path = [path stringByAppendingPathComponent:@"romanmap.plist"];
		romaKanaMap = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		return romaKanaMap;
	}
}

- (NSDictionary *)kanaMap
{
	if ( kanaMap ) {
		return kanaMap;
	} else {
		NSString * path = [[NSBundle mainBundle] resourcePath];
		path = [path stringByAppendingPathComponent:@"kanamap.plist"];
		kanaMap = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		return kanaMap;
	}
}

- (NSDictionary *)katakanaMap
{
	if ( katakanaMap ) {
		return katakanaMap;
	} else {
		NSString * path = [[NSBundle mainBundle] resourcePath];
		path = [path stringByAppendingPathComponent:@"katakanamap.plist"];
		katakanaMap = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		return katakanaMap;
	}
}

- (NSDictionary *)halfkatakanaMap
{
	if ( halfkatakanaMap ) {
		return halfkatakanaMap;
	} else {
		NSString * path = [[NSBundle mainBundle] resourcePath];
		path = [path stringByAppendingPathComponent:@"halfkatakanamap.plist"];
		halfkatakanaMap = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		return halfkatakanaMap;
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


- (NSString *)romaKanaConvert:(NSString *)string
{
	NSMutableString *kanaString = [[[NSMutableString alloc] init] autorelease];
	NSInteger length = [string length];
	NSRange range;
	NSString *word, *kana;
	for ( range.location = 0; range.location < length; range.location += range.length ) {
		kana = nil;
		for ( range.length = 1; range.length <= length - range.location; range.length++ ) {
			word = [string substringWithRange:range];
			if ( [word isEqualToString:@"@"] ) kana = @"＠";
			if ( !kana ) kana = [[self romaKanaMap] valueForKey:word];
			
			if ( kana ) break;
		}
		
		if ( kana ) {
			[kanaString appendString:kana];
		} else {
			range.length = 1;
			[kanaString appendString:[string substringWithRange:range]];
		}
	}
	
	return kanaString;
}

- (NSString *)kanaConvert:(NSString *)string
{
	NSMutableString *kanaString = [[[NSMutableString alloc] init] autorelease];
	NSInteger length = [string length];
	NSRange range;
	NSString *word, *kana;
	for ( range.location = 0; range.location < length; range.location += range.length ) {
		kana = nil;
		for ( range.length = 1; range.length <= length - range.location; range.length++ ) {
			word = [string substringWithRange:range];
			if ( [word isEqualToString:@"@"] ) kana = @"゛";
			if ( !kana ) kana = [[self kanaMap] valueForKey:word];
			
			if ( kana ) break;
		}
		
		if ( kana ) {
			[kanaString appendString:kana];
		} else {
			range.length = 1;
			[kanaString appendString:[string substringWithRange:range]];
		}
	}
	
	return kanaString;
}

- (NSString *)katakanaConvert:(NSString *)string
{
	NSMutableString *katakana = [NSMutableString string];
	NSRange range = { 0, 1 };
	NSInteger length = [string length];
	NSString *word, *kana;
	for ( range.location = 0; range.location < length; range.location++ ) {
		word = [string substringWithRange:range];
		kana = [[self katakanaMap] valueForKey:word];
		if ( kana ) {
			[katakana appendString:kana];
		} else {
			[katakana appendString:word];
		}
	}
	return katakana;
}

- (NSString *)halfkatakanaConvert:(NSString *)string
{
	NSMutableString *katakana = [NSMutableString string];
	NSRange range = { 0, 1 };
	NSInteger length = [string length];
	NSString *word, *kana;
	for ( range.location = 0; range.location < length; range.location++ ) {
		word = [string substringWithRange:range];
		kana = [[self halfkatakanaMap] valueForKey:word];
		if ( kana ) {
			[katakana appendString:kana];
		} else {
			[katakana appendString:word];
		}
	}
	return katakana;
}

- (void)kanjiConvert:(NSString *)string
{
	NSString *encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *URLString = [NSString stringWithFormat:@"http://www.social-ime.com/api/?string=%@&charset=UTF-8", encodedString];
	[self beginConnection:URLString];
}

- (void)kanjiConvert:(NSString *)string resize:(NSArray *)resizes
{
	NSString *encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSMutableString *URLString = [NSMutableString stringWithFormat:@"http://www.social-ime.com/api/?string=%@&charset=UTF-8", encodedString];
	int i = 0;
	int value;
	for ( NSNumber *size in resizes ) {
		value = [size intValue];
		if ( value != 0 ) [URLString appendFormat:@"&resize[%d]=%d", i, value];
		i++;
	}
	//NSLog( @"request for %@", URLString );
	[self beginConnection:URLString];
}

- (void)beginConnection:(NSString *)URLString
{
	NSURL *URL = [NSURL URLWithString:URLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	[request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	[self cancelKanjiConvert];
	connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[lastURLString release];
	lastURLString = [URLString retain];
}

- (void)commitLastKanjiConvert:(NSArray *)indexes
{
	NSMutableString *URLString = [NSMutableString stringWithString:lastURLString];
	NSInteger value;
	int i = 0;
	for ( NSNumber *number in indexes ) {
		value = [number intValue];
		if ( value != 0 ) [URLString appendFormat:@"&commit[%d]=%d", i, value];
		i++;
	}
	//NSLog( @"commit: %@", URLString );
	NSURL *URL = [NSURL URLWithString:URLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	[request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	[NSURLConnection connectionWithRequest:request delegate:nil];	
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
	//d(@"connection error");
	[self cancelKanjiConvert];
	if ( [delegate respondsToSelector:@selector(kanjiConvertDidError:)] ) {
		[delegate kanjiConvertDidError:self];
	}
}

- (BOOL)isKnajiConverting
{
	return connect != nil;
}

- (void)cancelKanjiConvert
{
	if ( connect ) {
		[connect cancel];
		[connect release];
		connect = nil;
	}
}

NSArray * stringsFromSeparatedString( NSString *string )
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSCharacterSet *space = [NSCharacterSet characterSetWithCharactersInString:@"\t"];
	NSString *scannedString;
	NSMutableArray *array = [NSMutableArray array];
	while ( ![scanner isAtEnd] ) {
		if ( [scanner scanUpToCharactersFromSet:space intoString:&scannedString] ) {
			[array addObject:[[[NSString alloc] initWithString:scannedString] autorelease]];
		}
		[scanner scanCharactersFromSet:space intoString:nil];
	}
	return array;
}

NSArray * parseResponseData( NSData *data )
{
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
	
	NSString *scannedString;
	NSMutableArray *array = [NSMutableArray array];
	while ( ![scanner isAtEnd] ) {
		if ( [scanner scanUpToCharactersFromSet:newline intoString:&scannedString] ) {
			[array addObject:stringsFromSeparatedString( scannedString )];
		}
		[scanner scanCharactersFromSet:newline intoString:nil];
	}
	
	return array;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSLog( @"finish" );
	NSArray *arrays = parseResponseData( receivedData );
	[self cancelKanjiConvert];
	if ( [delegate respondsToSelector:@selector(kanjiConvertDidFinish:candidates:)] ) {
		[delegate kanjiConvertDidFinish:self candidates:arrays];
	}
}

- (void)dealloc
{
	[lastURLString release];
	[receivedData release];
	[halfkatakanaMap release];
	[katakanaMap release];
	[romaKanaMap release];
	[kanaMap release];
	[kanaMap release];
	[super dealloc];
}

@end
