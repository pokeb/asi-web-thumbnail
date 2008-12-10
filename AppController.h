//
//  AppController.h
//  ASIWebThumbnail
//
//  Created by Ben Copsey on 07/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet NSMatrix *matrix;
	IBOutlet NSProgressIndicator *progress;
	NSOperationQueue *queue;
}

- (IBAction)generateThumbnail:(id)sender;

@end
