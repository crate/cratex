//
//  AppDelegate.m
//  cratex
//
//  Created by Christian Bader on 09/04/14.
//  Copyright (c) 2014 CRATE Technology GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "Cluster.h"
#import "ClusterSettingsViewController.h"
#import "Document.h"

@interface AppDelegate()

-(void)clustersUpdated:(NSNotification*)notification;
-(NSString*)pathForArchive:(NSString *)archiveName;
-(NSURL *)applicationDocumentsDirectory;
-(void)statusUpdated:(NSNotification*)notification;
-(IBAction)openDocument:(id)sender;
@property(nonatomic)NSMutableArray* menuItems;

@end

@implementation AppDelegate

- (id)init {
    self = [super init];
    if(self){
        self.menuItems = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clustersUpdated:)
                                                     name:@"clustersUpdated"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusUpdated:)
                                                     name:@"statusUpdated"
                                                   object:nil];
        id archivedClusters = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForArchive:@"clusters"]];
        if(archivedClusters){
            self.clusters = archivedClusters;
        }else {
            self.clusters = @{@"title": @"CLUSTER",
                              @"isLeaf": @(NO),
                              @"children":@[
                                      [Cluster clusterWithTitle:@"Localhost" andURL:@"http://localhost:4200/"]
                                      ].mutableCopy
                              }.mutableCopy;
        }
    }
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Add status bar item
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_statusMenu];
    [_statusItem setImage:[NSImage imageNamed:@"tray_icon"]];
    [_statusItem setHighlightMode:YES];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    [self showDetail:nil];
    return YES;
}

# pragma mark - Action handling

- (IBAction)showDetail:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
}


- (IBAction)showWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kCrateUrl]];
}

- (void)clustersUpdated:(NSNotification *)notification {
    [NSKeyedArchiver archiveRootObject:self.clusters toFile:[self pathForArchive:@"clusters"]];
    [self statusUpdated:notification];
}

#pragma mark - Application's Documents directory

- (NSString*)pathForArchive:(NSString *)archiveName {
    NSString* pathComponent = [NSString stringWithFormat:@"%@.archive", archiveName];
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:pathComponent];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)statusUpdated:(NSNotification *)notification {
    // Remove all menu items
    [self.menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_statusMenu removeItem:obj];
    }];
    [self.menuItems removeAllObjects];
    
    NSArray* clusters = [[self clusters] objectForKey:@"children"];
    ClusterState* __block state = [ClusterState clusterState:@"Unknown" withCode:0 andIcon:@"tray_icon"];
    [clusters enumerateObjectsUsingBlock:^(Cluster* cluster, NSUInteger idx, BOOL *stop) {
        if([cluster.considerOverall boolValue] && cluster.state.code > state.code){
            state = cluster.state;
        }
        if(cluster.state && cluster.title){
            NSMenuItem* item = [[NSMenuItem alloc] init];
            [item setImage:cluster.state.icon];
            [item setTitle:cluster.title];
            [item setAction:@selector(openDocument:)];
            [self.menuItems addObject:item];
        }
    }];
    
    // Add menu items
    [_statusMenu setMenuChangedMessagesEnabled:NO];
    [_statusItem setImage:[state icon]];
    [self.menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_statusMenu insertItem:obj atIndex:idx];
    }];
}

-(IBAction)openDocument:(id)sender {
    NSInteger index = [_statusMenu indexOfItem:sender];
    NSDocumentController* controller = [NSDocumentController sharedDocumentController];
    [controller newDocument:nil];
    Document* document = [[controller documents] lastObject];
    [document setCluster:index];
}


@end
