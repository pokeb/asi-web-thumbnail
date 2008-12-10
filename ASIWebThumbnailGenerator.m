//
//  ASIWebThumbnailGenerator.m
//  ASIWebThumbnail
//
//  Created by Ben Copsey on 07/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import "ASIWebThumbnailGenerator.h"


@implementation ASIWebThumbnailGenerator


- (id)init
{
	self = [super init];
	[self setUrl:nil];
	[self setSavePath:nil];
	[self setEnableJava:NO];
	[self setEnableJavaScript:YES];
	[self setEnablePlugins:YES];
	[self setSourceOrigin:NSMakePoint(0,0)];
	[self setDestinationSize:NSMakeSize(0,0)];
	[self setSourceSize:NSMakeSize(0,0)];
	[self setPageSize:NSMakeSize(0,0)];
	[self setTimeoutSeconds:0];
	return self;
}

- (void)dealloc
{
	[url release];
	[savePath release];
	[pageTitle release];
	[representedObject release];
	[super dealloc];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSTask *task = [[[NSTask alloc] init] autorelease];
	
	// Setup arugments
	NSMutableArray *args = [NSMutableArray array];
	

	if (enableJava) {
		[args addObject:@"-j"];
	} else {
		[args addObject:@"-J"];
	}	
	if (enableJavaScript) {
		[args addObject:@"-s"];
	} else {
		[args addObject:@"-S"];
	}
	if (enablePlugins) {
		[args addObject:@"-p"];
	} else {
		[args addObject:@"-P"];
	}
	if (destinationSize.width > 0) {
		[args addObject:[NSString stringWithFormat:@"-w%f",destinationSize.width]];
	}
	if (destinationSize.height > 0) {
		[args addObject:[NSString stringWithFormat:@"-h%f",destinationSize.height]];
	}
	if (sourceSize.width > 0) {
		[args addObject:[NSString stringWithFormat:@"-W%f",sourceSize.width]];
	}
	if (sourceSize.height > 0) {
		[args addObject:[NSString stringWithFormat:@"-H%f",sourceSize.height]];
	}
	if (pageSize.width > 0) {
		[args addObject:[NSString stringWithFormat:@"-a%f",pageSize.width]];
	}
	if (pageSize.height > 0) {
		[args addObject:[NSString stringWithFormat:@"-b%f",pageSize.height]];
	}
	if (sourceOrigin.x > 0) {
		[args addObject:[NSString stringWithFormat:@"-x%f",sourceOrigin.x]];
	}
	if (sourceOrigin.y > 0) {
		[args addObject:[NSString stringWithFormat:@"-y%f",sourceOrigin.y]];
	}
	if (timeoutSeconds > 0) {
		[args addObject:[NSString stringWithFormat:@"-z%hi",timeoutSeconds]];
	}
	[args addObject:@"-t"];

	[args addObject:url];
	if (!savePath) {
		[self setSavePath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]];
	}
	[args addObject:savePath];
	
	
	[task setArguments:args];	
	
	NSString *path = [[[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BundledThumbnailGenerator.app"] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"MacOS"] stringByAppendingPathComponent:@"BundledThumbnailGenerator"];
	[task setLaunchPath:path];

	
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardError:errorPipe];

    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
	
	[task launch];
	
	[task waitUntilExit];
	
	NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
	[self setPageTitle:[[[NSString alloc] initWithBytes:[outputData bytes] length:[outputData length] encoding:NSUTF8StringEncoding] autorelease]];
	
	//If something went wrong, log the error and stop
	if ([task terminationStatus] != 0) {
		
		NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
		NSString *error = [[[NSString alloc] initWithBytes:[errorData bytes] length:[errorData length] encoding:NSUTF8StringEncoding] autorelease];
			
		NSLog(@"Output: %@",pageTitle);
		NSLog(@"Error: %@",error);
	} else {
		
		if ([delegate respondsToSelector:@selector(thumbnailGenerationSucceededFor:)]) {
			[delegate performSelectorOnMainThread:@selector(thumbnailGenerationSucceededFor:) withObject:self waitUntilDone:NO];
		}
	}
	
	[pool release];
	
}

- (NSImage *)image
{
	return [[[NSImage alloc] initWithContentsOfFile:savePath] autorelease];
}

@synthesize url;
@synthesize savePath;
@synthesize pageTitle;
@synthesize enableJava;
@synthesize enableJavaScript;
@synthesize enablePlugins;
@synthesize sourceOrigin;
@synthesize destinationSize;
@synthesize sourceSize;
@synthesize pageSize;
@synthesize timeoutSeconds;
@synthesize representedObject;
@synthesize delegate;
@end
