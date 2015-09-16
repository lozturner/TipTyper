//
//  BPApplication.m
//  TipTyper
//
//  Created by Bruno Philipe on 10/14/13.
//  TipTyper – The simple plain-text editor for OS X.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <CommonCrypto/CommonCrypto.h>

#import "BPApplication.h"
#import "DCOAboutWindowController.h"
#import "BPPreferencesWindowController.h"

#ifdef SPARKLE
#import "Sparkle/Sparkle.h"
#endif

NSString *const kBPDefaultFont					= @"BP_DEFAULT_FONT";
NSString *const kBPDefaultTextColor				= @"BP_DEFAULT_TXTCOLOR";
NSString *const kBPDefaultBackgroundColor		= @"BP_DEFAULT_BGCOLOR";
NSString *const kBPDefaultShowLines				= @"BP_DEFAULT_SHOWLINES";
NSString *const kBPDefaultShowStatus			= @"BP_DEFAULT_SHOWSTATUS";
NSString *const kBPDefaultInsertTabs			= @"BP_DEFAULT_INSERTTABS";
NSString *const kBPDefaultInsertSpaces			= @"BP_DEFAULT_INSERTSPACES";
NSString *const kBPDefaultCountSpaces			= @"BP_DEFAULT_COUNTSPACES";
NSString *const kBPDefaultTabSize				= @"BP_DEFAULT_TABSIZE";
NSString *const kBPDefaultEditorWidth			= @"BP_DEFAULT_EDITOR_WIDTH";
NSString *const kBPDefaultShowSpecials			= @"BP_DEFAULT_SHOWSPECIALS";

NSString *const kBPShouldReloadStyleNotification = @"BP_SHOULD_RELOAD_STYLE";

NSString *const kBPTipTyperWebsite = @"https://www.brunophilipe.com/software/tiptyper";

@interface BPApplication () <NSWindowDelegate>

@property (strong) IBOutlet  NSMenuItem *checkForUpdateButton;

@end

@implementation BPApplication
{
	BPPreferencesWindowController *prefWindowController;
	DCOAboutWindowController *aboutWindowController;

	NSWindow *prefWindow;
}

- (BOOL)hasLoadedDocumentInKeyWindow
{
	id keyWindow = [self keyWindow];
	
	BOOL status = (keyWindow &&
				   [keyWindow isMemberOfClass:[BPDocumentWindow class]] &&
				   [[keyWindow document] isLoadedFromFile]);
	
	return status;
}

- (void)finishLaunching
{
	[super finishLaunching];
	
#ifdef SPARKLE
	[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
#else
	[self.checkForUpdateButton setHidden:YES];
#endif
}

- (IBAction)checkForUpdate:(id)sender
{
#ifdef SPARKLE
	[[SUUpdater sharedUpdater] checkForUpdates:sender];
#endif
}

- (IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kBPTipTyperWebsite]];
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefWindow)
	{
		prefWindowController = [[BPPreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
		prefWindow = prefWindowController.window;

		[prefWindow setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
	}

	[prefWindowController performSelector:@selector(showWindow:) withObject:self afterDelay:0.2];
}

- (void)verifyExecutableChecksum
{
	NSURL *executableURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/MacOS/TipTyper"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[executableURL path]] )
	{
		NSData *data = [NSData dataWithContentsOfURL:executableURL];
		unsigned char digest[CC_SHA512_DIGEST_LENGTH];
		CC_SHA512( data.bytes, (CC_LONG)data.length, digest );
		
		NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
		
		for( int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++ )
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		
		NSLog(@"%@", output);
	}
}

#pragma mark - IBActions

- (IBAction)showAboutPanel:(id)sender {
	if (!aboutWindowController) {
		aboutWindowController = [[DCOAboutWindowController alloc] init];

        //TODO: Support for Lion
		NSTimeInterval buildDate = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BuildDate"] doubleValue];
		NSInteger currentYear = [[NSCalendar currentCalendar] component:NSCalendarUnitYear
															   fromDate:[NSDate dateWithTimeIntervalSince1970:buildDate]];
		
		[aboutWindowController setAppCopyright:[NSString stringWithFormat:@"Copyright Bruno Philipe 2013-%ld – All Rights Reserved", currentYear]];
		[aboutWindowController setAppWebsiteURL:[NSURL URLWithString:kBPTipTyperWebsite]];
	}

	[aboutWindowController showWindow:sender];
}

@end
