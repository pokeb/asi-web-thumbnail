//
//  ASIWebPageThumbnailGenerator.h
//
//  Created by Ben Copsey on 05/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>

@interface ASIWebPageThumbnailGenerator : NSObject {
	NSURL *url;
	NSString *thumbnailSavePath;
	NSWindow *window ;
	int timeoutSeconds;
	BOOL complete;
	BOOL failed;
	WebView *webView;
	BOOL enableJava;
	BOOL enableJavaScript;
	BOOL enablePlugins;
	NSString *pageTitle;
	int destinationWidth;
	int destinationHeight;
	int sourceWidth;
	int sourceHeight;
	int sourceX;
	int sourceY;
	int pageWidth;
	int pageHeight;
}


- (void)cleanUpWebPreview;
- (void)timeoutRequest;
- (void)go;

@property (assign) BOOL failed;
@property (assign) BOOL complete;
@property (retain) NSURL *url;
@property (retain) NSString *thumbnailSavePath;
@property (retain) NSWindow *window;
@property (assign) int timeoutSeconds;
@property (retain) WebView *webView;

@property (assign) BOOL enableJava;
@property (assign) BOOL enableJavaScript;
@property (assign) BOOL enablePlugins;
@property (retain) NSString *pageTitle;

@property (assign) int destinationWidth;
@property (assign) int destinationHeight;
@property (assign) int sourceWidth;
@property (assign) int sourceHeight;
@property (assign) int sourceX;
@property (assign) int sourceY;
@property (assign) int pageWidth;
@property (assign) int pageHeight;
@end
