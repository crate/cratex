//
//  Document.h
//  cratex
//
//  Created by Philipp Bogensberger on 09.04.14.
//  Copyright (c) 2014 CRATE Technology GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument <NSOutlineViewDataSource, NSOutlineViewDelegate>

- (IBAction)addObject:(id)sender;

@end