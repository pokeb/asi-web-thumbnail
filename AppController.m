//
//  AppController.m
//  ASIWebThumbnail
//
//  Created by Ben Copsey on 07/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import "AppController.h"
#import "ASIWebThumbnailGenerator.h"

@implementation AppController

- (IBAction)generateThumbnail:(id)sender
{
	[progress setDoubleValue:0];
	[queue cancelAllOperations];
	[queue release];
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:4];
	
	NSArray *urls = [NSArray arrayWithObjects:
	@"http://slashdot.org",
	@"http://wired.com",
	@"http://news.bbc.co.uk",
	@"http://theregister.co.uk",
	@"http://github.com",
	@"http://adobe.com",
	@"http://allseeing-i.com/ASIHTTPRequest",
	@"http://stackoverflow.com",
	@"http://www.yellow5.com/pokey/archive/index422.html",
	nil];
	

	int i=0;
	for (NSString *url in urls) {
		ASIWebThumbnailGenerator *generator = [[[ASIWebThumbnailGenerator alloc] init] autorelease];
		[generator setUrl:url];
		[generator setPageSize:NSMakeSize(1000,0)];
		[generator setSourceSize:NSMakeSize(1000,700)];
		[generator setDestinationSize:NSMakeSize(300,200)];
		[generator setRepresentedObject:[[matrix cells] objectAtIndex:i]];
		[generator setDelegate:self];
		[queue addOperation:generator];
		i++;
	}
}

- (void)thumbnailGenerationSucceededFor:(ASIWebThumbnailGenerator *)generator
{
	[(NSImageCell *)[generator representedObject] setImage:[generator image]];
	[progress setDoubleValue:[progress doubleValue]+1];
}

@end
