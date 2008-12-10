//
//  ASIWebPageThumbnailGenerator.m
//
//  Created by Ben Copsey on 05/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import "ASIWebPageThumbnailGenerator.h"


@implementation ASIWebPageThumbnailGenerator

- (id)init
{
	self = [super init];
	[self setEnableJava:NO];
	[self setEnablePlugins:YES];
	[self setEnableJavaScript:YES];
	[self setDestinationWidth:0];
	[self setDestinationHeight:0];
	[self setSourceWidth:0];
	[self setSourceHeight:0];
	[self setSourceX:0];
	[self setSourceY:0];
	[self setPageWidth:0];
	[self setPageHeight:0];
	return self;
}

- (void)dealloc
{
	[url release];
	[thumbnailSavePath release];
	[webView release];
	[window release];
	[pageTitle release];
	[super dealloc];
}

- (void)go
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Make an offscreen window
	NSRect r = NSMakeRect(-2500,-2500,800,600);
	[self setWindow:[[[NSWindow alloc] initWithContentRect:r styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease]];
	[self setWebView:[[[WebView alloc] initWithFrame:r frameName:nil groupName:nil] autorelease]];
	
	WebPreferences *prefs = [[[WebPreferences alloc] initWithIdentifier:@"ThumbnailGenerator"] autorelease];
	[prefs setJavaEnabled:[self enableJava]];
	[prefs setJavaScriptEnabled:[self enableJavaScript]];
	[prefs setPlugInsEnabled:[self enablePlugins]];
	[webView setPreferences:prefs];
	
	[window setContentView:webView];
	[webView setHostWindow:window];
	[[[webView mainFrame] frameView] setAllowsScrolling:NO];	
	
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
	[webView setFrameLoadDelegate:self];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	// Record when the request started, so we can timeout if nothing happens
	NSDate *startTime = [[NSDate date] retain];
	
	// Wait for the request to finish
	while (!complete) {
		
		NSDate *now = [NSDate date];
		
		// See if we need to timeout
		if (timeoutSeconds > 0) {
			if ([now timeIntervalSinceDate:startTime] > timeoutSeconds) {
				[self timeoutRequest];
				break;
			}
		}
		
		[runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];

	}
	
	[startTime release];
	
	[pool release];
	pool = nil;
	
}

- (void)timeoutRequest
{
	if ([webView estimatedProgress] > 0.6) {
		[self webView:webView didFinishLoadForFrame:[webView mainFrame]];
		return;
	}
	failed = YES;
	[self cleanUpWebPreview];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if (frame != [sender mainFrame]) {
		return;
	}
	
	NSView *docView = [[[sender mainFrame] frameView] documentView];
	NSSize size = [docView bounds].size;
	
	if (pageWidth > 0 && pageHeight > 0) {
		size = NSMakeSize(pageWidth,pageHeight);	
	} else if (pageWidth > 0) {
		size = NSMakeSize(pageWidth, size.height);
	} else if (pageHeight > 0) {
		size = NSMakeSize(size.width, pageHeight);
	} else {
		size = NSMakeSize(size.width+40,size.height+40);	
	}
	
	if (size.width == 0 || size.height == 0) {
		[self cleanUpWebPreview];
		failed = YES;
		[sender stopLoading:nil];
		return;
	}
	[window setFrameOrigin:NSMakePoint(0-size.width-300, 0-size.height-300)];
	[window setContentSize:size];
	
	
	
	[[[sender mainFrame] frameView] scrollPoint:NSMakePoint(0,[docView bounds].size.height-size.height)];
	[window display];
	[window orderFront:nil];
	[sender lockFocus];
	NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[sender bounds]] autorelease];
	[sender unlockFocus];
	
	if (rep) {
		NSImage *img = [[[NSImage alloc] initWithData:[rep TIFFRepresentation]] autorelease];
		[img setScalesWhenResized:YES];
		[img lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
		[img unlockFocus];
		
		
		float sW = sourceWidth;
		if (sW == 0) {
			sW = [img size].width;
		}
		float sH = sourceHeight;
		if (sH == 0) {
			sH = [img size].height;
		}		
		double scale = 1;
		NSSize thumbnailSize;
		if (destinationWidth > 0 && destinationHeight > 0) {
			thumbnailSize = NSMakeSize(destinationWidth,destinationHeight);
			scale = destinationWidth/sW;
		} else {
			
			if (destinationWidth > 0) {
				scale = destinationWidth/sW;
			} else if (destinationHeight > 0) {
				scale = destinationHeight/sH;
			}
			thumbnailSize = NSMakeSize(sW*scale,sH*scale);
		}
		
		NSImage *destinationImage = [[[NSImage alloc] initWithSize:thumbnailSize] autorelease];
		[destinationImage lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
		
		NSRect r = NSMakeRect(sourceX, ([img size].height-(thumbnailSize.height/scale))-sourceY, thumbnailSize.width/scale, thumbnailSize.height/scale);
		[img drawInRect:NSMakeRect(0,0,thumbnailSize.width,thumbnailSize.height) fromRect:r operation:NSCompositeSourceOver fraction:1.0];
		[destinationImage unlockFocus];
		
		
		NSData *data = [[NSBitmapImageRep imageRepWithData:[destinationImage TIFFRepresentation]] representationUsingType:NSPNGFileType properties:nil];
		[data writeToFile:thumbnailSavePath  atomically:NO];
		
	}
	
	[self cleanUpWebPreview];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if (frame != [sender mainFrame]) {
		return;
	}
	failed = YES;
	[self cleanUpWebPreview];
}


- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if (frame != [sender mainFrame]) {
		return;
	}
	failed = YES;
	[self cleanUpWebPreview];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	[self setPageTitle:title];
}

- (void)cleanUpWebPreview
{
	if (window) {
		[webView stopLoading:nil];
		[window orderOut:nil];
	}
	complete = YES;
}

@synthesize failed;
@synthesize complete;
@synthesize url;
@synthesize thumbnailSavePath;
@synthesize window;
@synthesize timeoutSeconds;
@synthesize webView;
@synthesize enableJava;
@synthesize enableJavaScript;
@synthesize enablePlugins;
@synthesize pageTitle;
@synthesize destinationWidth;
@synthesize destinationHeight;
@synthesize sourceWidth;
@synthesize sourceHeight;
@synthesize sourceX;
@synthesize sourceY;
@synthesize pageWidth;
@synthesize pageHeight;
@end
