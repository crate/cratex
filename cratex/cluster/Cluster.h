//
//  Cluster.h
//  cratex
//
//  Created by Philipp Bogensberger on 09.04.14.
//  Copyright (c) 2014 CRATE Technology GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClusterState : NSObject

@property(assign)NSInteger code;
@property(copy)NSString* name;
@property(nonatomic)NSImage* icon;

+(id)clusterState:(NSString*)name withCode:(NSInteger)code andIcon:(NSString*)icon;

@end

@interface Cluster : NSObject <NSCoding>

@property(copy)NSString* title;
@property(copy)NSString* url;
@property(readonly)BOOL isLeaf;
@property(copy)NSNumber* considerOverall;

@property(copy)NSArray* tables;
@property(copy)NSNumber* activePrimary;
@property(copy)NSNumber* unassigned;
@property(copy)NSNumber* configured;
@property(copy)NSNumber* missing;

@property(copy)NSString* available_data;
@property(copy)NSString* records_unavailable;
@property(copy)NSString* replicated_data;
@property(copy)NSString* records_total;
@property(copy)NSString* records_underreplicated;

@property(nonatomic)ClusterState* state;


@property(copy)NSArray* shardInfo;

+(Cluster*)clusterWithTitle:(NSString*)title andURL:(NSString*)url;

typedef void (^CompletionBlock)(BOOL success, NSDictionary *response, NSError *error);

- (void)sql:(NSString *)query withCallback:(CompletionBlock)callback;
- (NSArray*)convertSQLResult:(NSDictionary*)result fields:(NSArray*)fields;

@end

