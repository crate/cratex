//
//  AppDelegate.h
//  cratex
//
//  Created by Christian Bader on 09/04/14.
//  Copyright (c) 2014 CRATE Technology GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

- (IBAction)showDetail:(id)sender;
- (IBAction)showWebsite:(id)sender;
- (IBAction)addObject:(id)sender;

@property (strong) NSStatusItem *statusItem;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;

@end
