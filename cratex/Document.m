//
//  Document.m
//  cratex
//
//  Created by Philipp Bogensberger on 09.04.14.
//  Copyright (c) 2014 CRATE Technology GmbH. All rights reserved.
//

#import "Document.h"
#import "Cluster.h"
#import "cluster/ClusterSettingsViewController.h"
#import "CLusterOverviewViewController.h"
#import "QueryViewController.h"
#import "AppDelegate.h"

@interface Document()

@property (weak) IBOutlet NSOutlineView *clusterOutlineView;
@property (weak) IBOutlet NSTreeController *clusterController;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet CLusterOverviewViewController* clusterOverViewController;
@property (weak) IBOutlet ClusterSettingsViewController* clusterSettingsViewController;
@property (weak) IBOutlet QueryViewController *queryViewController;
@property (weak) IBOutlet NSSplitView* splitView;

-(void)sendClusterUpdated;

@end

@implementation Document

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    self.clusterOutlineView.delegate = self;
    self.clusterOutlineView.dataSource = self;
    self.clusterOutlineView.floatsGroupRows = NO; // Prevent a sticky header
    
    [self.clusterController setContent:[(AppDelegate*)[[NSApplication sharedApplication] delegate] clusters]];
    
    // Expand the first group and select the first item in the list
    [self.clusterOutlineView expandItem:[self.clusterOutlineView itemAtRow:0]];
    [self.clusterOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    
    [[self.tabView tabViewItemAtIndex:0] setView:[self.clusterOverViewController view]];
    [[self.tabView tabViewItemAtIndex:1] setView:[self.queryViewController view]];
    [[self.tabView tabViewItemAtIndex:2] setView:[self.clusterSettingsViewController view]];

}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}


- (BOOL)isHeader:(id)item{
    
    if([item isKindOfClass:[NSTreeNode class]]){
        return ![((NSTreeNode *)item).representedObject isKindOfClass:[Cluster class]];
    } else {
        return ![item isKindOfClass:[Cluster class]];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
    if ([self isHeader:item]) {
        return [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    } else {
        return [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    return ![self isHeader:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
    // This converts a group to a header which influences its style
    return [self isHeader:item];
}

- (BOOL)isDocumentEdited {
    return NO;
}


- (IBAction)addObjectClicked:(id)sender {
    Cluster* cluster = [Cluster new];    
    NSUInteger indexArr[] = {0,[[[[self.clusterController content] objectAtIndex:0] objectForKey:@"children"] count]};
    [self.tabView selectLastTabViewItem:nil];
    [self.clusterController insertObject:cluster
               atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]];
    [self sendClusterUpdated];

}

- (IBAction)removeObjectClicked:(id)sender {
    [self.clusterController remove:sender];
    [self sendClusterUpdated];
}

- (void)sendClusterUpdated {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"clustersUpdated"
     object:nil
     userInfo:nil];
}

- (Cluster*)selectedCluster {
    return [[self.clusterController selectedObjects] objectAtIndex:0];
}

-(void)setCluster:(NSInteger)index {
    [self.clusterOutlineView expandItem:[self.clusterOutlineView itemAtRow:0]];
    [self.clusterOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index+1] byExtendingSelection:NO];

}

@end
