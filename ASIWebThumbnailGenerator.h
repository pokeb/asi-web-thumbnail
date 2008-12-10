//
//  ASIWebThumbnailGenerator.h
//  ASIWebThumbnail
//
//  Created by Ben Copsey on 07/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ASIWebThumbnailGenerator : NSOperation {
	NSString *url;
	NSString *savePath;
	NSString *pageTitle;
	BOOL enableJava;
	BOOL enableJavaScript;
	BOOL enablePlugins;
	NSPoint sourceOrigin;
	NSSize destinationSize;
	NSSize sourceSize;
	NSSize pageSize;
	int timeoutSeconds;
	NSObject *representedObject;
	id delegate;
}
- (void)main;
- (NSImage *)image;

@property (retain) NSString *url;
@property (retain) NSString *savePath;
@property (retain) NSString *pageTitle;
@property (assign) BOOL enableJava;
@property (assign) BOOL enableJavaScript;
@property (assign) BOOL enablePlugins;
@property (assign) NSPoint sourceOrigin;
@property (assign) NSSize destinationSize;
@property (assign) NSSize sourceSize;
@property (assign) NSSize pageSize;

@property (assign) int timeoutSeconds;
@property (retain) NSObject *representedObject;
@property (assign) id delegate;

@end
