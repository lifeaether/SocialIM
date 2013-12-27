//
//  main.m
//  SocialIM
//
//  Created by OverTaker on 09/02/24.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

NSString * const kConnectionName = @"SocialIM_Connection";

IMKServer* Server = nil;

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	
	Server = [[IMKServer alloc] initWithName:kConnectionName bundleIdentifier:identifier];
	[NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
	
	[[NSApplication sharedApplication] run];
	
	[Server release];
	[pool release];
	return 0;
}
