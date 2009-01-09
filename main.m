//
//  webthumbnail
//
//  Created by Ben Copsey on 05/12/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//
// See: http://www.gnu.org/software/libtool/manual/libc/Getopt.html#Getopt
// And: http://www-128.ibm.com/developerworks/aix/library/au-unix-getopt.html
// ...for hints on how getopt_long works


#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <Cocoa/Cocoa.h>
#import "ASIWebPageThumbnailGenerator.h"

// Valid arguments
static const struct option longOptions[] =
{
	{"enable-java", no_argument, NULL, 'j'},
	{"disable-java", no_argument, NULL, 'J'},
	{"enable-javascript", no_argument, NULL, 's'},
	{"disable-javascript", no_argument, NULL, 'S'},
	{"enable-plugins", no_argument, NULL, 'p'},
	{"disable-plugins", no_argument, NULL, 'P'},
	{"page-width", required_argument, NULL, 'a'},
	{"page-height", required_argument, NULL, 'b'},
	{"width", required_argument, NULL, 'w'},
	{"height", required_argument, NULL, 'h'},
	{"source-width", required_argument, NULL, 'W'},
	{"source-height", required_argument, NULL, 'H'},
	{"source-x", required_argument, NULL, 'x'},
	{"source-y", required_argument, NULL, 'y'},
	{"timeout", required_argument, NULL, 'z'},
	{"launch", no_argument, NULL, 'l'},
	{"print-page-title", no_argument, NULL, 't'},
	{"help", no_argument, NULL, '?'},
	{ NULL, no_argument, NULL, 0 }
};


static const NSString *usage = @"Usage: webthumbnail <options> http://myurl.com/mypage.html /path/to/save.png\nRun webthumbnail --help for information on valid options\n";	
static const NSString *help = @"webthumbnail - Copyright All-Seeing Interactive, 2008\n\nUsage: webthumbnail <options> http://myurl.com/mypage.html /path/to/save.png\n\nControlling the generated image (All measurements are specified in pixels)\n\n--width (-w)               Set the width of the generated thumbnail (Defaults to page-width)\n--height (-h)              Set the height of the generated thumbnail (Defaults to page-height)\n--source-width (-W)        Set the width of the area to be rendered in the source image (Defaults to page-width)\n--source-height (-H)       Set the height of the area to be rendered in the source image (Defaults to page-height)\n--source-x (-x)            Set the left point in the source image (Defaults to 0)\n--source-y (-y)            Set the top point in the source image (Defaults to 0)\n--page-width (-a)          Set the width of the page to be used when rendering (Defaults to the computed width of the page)\n--page-height (-b)         Set the height of the page to be used when rendering (Defaults to the computed height of the page)\n\nHandling web content\n\n--enable-java (-j)         Enable Java (Default is OFF)\n--disable-java (-J)        Disable Java\n--enable-javascript (-s)   Enable JavaScript (Default is ON)\n--disable-javascript (-S)  Disable JavaScript\n--enable-plugins (-p)      Enable Plugins (Flash etc, Default in ON)\n--disable-plugins (-P)     Disable Plugins\n--timeout (-z)             Timeout after the specified number of seconds (Default is never timeout)\n\nGeneral options\n\n--print-page-title (-t)    Print the title of an HTML page, if one was found\n--launch (-l)              Open the generated image when rendering is complete\n--help (-?)                Show these instructions\n\nExamples\n\n$ webthumbnail http://www.allseeing-i.com image.png\nRenders an image of the website at full size, containing the full page\n\n$ webthumbnail --width=300 --height=200 --source-height=600 http://www.allseeing-i.com image.png\nRenders an image of the website to a 300x200 thumbnail, cropping the source page to 600 pixels tall\n\n$ webthumbnail -w300 -h200 -H600 http://www.allseeing-i.com image.png\nDoes the same thing, using the shorter syntax\n\n$ webthumbnail -w300 -h200 -W300 -h200 -x100 -y100 -l http://www.allseeing-i.com image.png\nRenders a 300x200 portion of the page, at full size, starting from left:100 pixels top:100 pixels, and opens the image\n";

static const char *optionsString = "jJsSpPw:h:W:H:x:y:a:b:z:lt?";

int main (int argc, char **argv) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ASIWebPageThumbnailGenerator *generator = [[[ASIWebPageThumbnailGenerator alloc] init] autorelease];
	[generator setTimeoutSeconds:10];
	
	BOOL showHelp = NO;
	BOOL badParameters = NO;
	
	int optionIndex = 0;
	int option = getopt_long (argc, argv, optionsString, longOptions, &optionIndex);
	
	BOOL printPageTitle = NO;
	BOOL launchThumbnail = NO;

	while (option != -1) {
		
		switch (option)
		{
			case 'j':
                [generator setEnableJava:YES];
                break;
			case 'J':
                [generator setEnableJava:NO];
                break;
			case 's':
                [generator setEnableJavaScript:YES];
                break;
			case 'S':
                 [generator setEnableJavaScript:NO];
                break;		
			case 'p':
                [generator setEnablePlugins:YES];
                break;
			case 'P':
                 [generator setEnablePlugins:NO];
				 break;
			case 'w':
				[generator setDestinationWidth:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'h':
				[generator setDestinationHeight:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'W':
				[generator setSourceWidth:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'H':
				[generator setSourceHeight:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'x':
				[generator setSourceX:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'y':
				[generator setSourceY:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'a':
				[generator setPageWidth:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'b':
				[generator setPageHeight:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 'z':
				[generator setTimeoutSeconds:[[NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] intValue]];
                break;
			case 't':
				printPageTitle = YES;
				break;
			case 'l':
				launchThumbnail = YES;
                break;
            case '?':
				showHelp = YES;
                break;	
			default: 
				badParameters = YES;
				break;
		}
				
		option = getopt_long (argc, argv, optionsString, longOptions, &optionIndex);
	}
	
	
	if (!showHelp && !badParameters) {
	
		int numInputFiles = argc - optind;
		
		// The url and path to save to aren't set, give up
		if (numInputFiles > 2) {
			CFShow((CFStringRef *)@"ERROR: Too many parameters given\n");
			badParameters = YES;
		} else if (numInputFiles < 2) {
			CFShow((CFStringRef *)@"ERROR: Missing URL and/or save path\n");
			badParameters = YES;
				
		// Grab the url and path to save to from the end of the arguments
		} else {
			char **sourceAndDestination = argv + optind;
			NSString *url = [NSString stringWithCString:*sourceAndDestination encoding:NSUTF8StringEncoding];
			sourceAndDestination++;
			NSString *destinationPath = [NSString stringWithCString:*sourceAndDestination encoding:NSUTF8StringEncoding];
			if (!url || !destinationPath) {
				CFShow((CFStringRef *)@"ERROR: Missing URL and/or save path\n");
				badParameters = YES;
			}
			[generator setUrl:[[[NSURL alloc] initWithString:url] autorelease]];
			[generator setThumbnailSavePath:destinationPath];
		}
		
	}
	
	
	int err = 0;
	
	if (badParameters) {
		CFShow(usage);
		
	} else if (showHelp) {
		[help writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:NULL];
	
	// We got valid arguments, let's attempt to generate the thumbnail
	} else {
		[NSApplication sharedApplication]; // Connect to the window server
		[generator go];
		err = (!generator || [generator failed]);
		if (err == 0) {
			if (printPageTitle) {
				[[generator pageTitle] writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:NULL];
			}
			if (launchThumbnail) {
				[[NSWorkspace sharedWorkspace] openFile:[generator thumbnailSavePath]];
			}
		}
		
	}
	

	[pool release];
	
	return err;
	
}
