//
//  AppDelegate.m
//  MailtoEmacs
//
//  Created by Dominick LoBraico on 3/18/13.
//  Copyright (c) 2013 Dominick LoBraico. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  }

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)passURLToEmacsClient:(NSURL *)url {
    NSString * mailto_string = [url absoluteString];
    NSLog(@"Received mailto link: %@", mailto_string);
    
    NSString * emacs_snippet = [NSString stringWithFormat:@"(browse-url \"%@\")", mailto_string];
    NSLog(@"Running emacsclient with snippet: %@", emacs_snippet);
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/local/bin/emacsclient"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"-n", @"-a", @"''", @"-c", @"-e", emacs_snippet, nil];
    [task setArguments: arguments];
    
    [task launch];
    
    while ([task isRunning]) {
        sleep(1);
    }
    
    exit(0);
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    [self passURLToEmacsClient:url];
}


@end
