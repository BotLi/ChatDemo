//
//  FirebaseProcess.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/12.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "RoomInfo.h"
#import "UserInfo.h"
#import "DateUtils.h"

@implementation FirebaseProcess
{
    BOOL isSync;
}

@synthesize roomInfos,userInfos;
@synthesize roomRef,messagesRef,rootRef,userRef,personalMessagesRef;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        rootRef = [[FIRDatabase database] reference];
        roomRef = [rootRef child:fkCHATROOMSREF];
        userRef = [rootRef child:fkUSERSREF];
        messagesRef = [rootRef child:fkMESSAGESREF];
        personalMessagesRef = [rootRef child:fkPERSONALMESSAGESREF];
        roomInfos = [[NSMutableArray alloc] init];
        userInfos = [[NSMutableArray alloc] init];
        isSync = NO;
    }
    
    return self;
}

- (FIRUser*)user
{
    return [[FIRAuth auth] currentUser];
}

- (NSString*)uid
{
    return [[[FIRAuth auth] currentUser] uid];
}

- (void)sync
{
    if (!isSync && [self user] != nil)
    {
        isSync = YES;
        [self syncRoomInfo];
        [self syncUserInfo];
    }
}

- (void)stopSync
{
    if (isSync)
    {
        [roomRef removeAllObservers];
        [roomInfos removeAllObjects];
        [userRef removeAllObservers];
        [userInfos removeAllObjects];
        
        isSync = NO;
    }
}

- (void)syncRoomInfo
{
    [roomRef
     observeEventType:FIRDataEventTypeChildAdded
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         [self.roomInfos addObject:[[RoomInfo alloc] initWithFirDataSnapshot:snapshot]];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
    [roomRef
     observeEventType:FIRDataEventTypeChildChanged
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSInteger index = [self.roomInfos indexOfObject:[self getRoomByKey:snapshot.key]];
         RoomInfo *info = [[RoomInfo alloc] initWithFirDataSnapshot:snapshot];
         [self.roomInfos replaceObjectAtIndex:index withObject:info];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
    [roomRef
     observeEventType:FIRDataEventTypeChildRemoved
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         [self.roomInfos removeObject:[self getRoomByKey:snapshot.key]];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
}

- (void)syncUserInfo
{
    [userRef
     observeEventType:FIRDataEventTypeChildAdded
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         [self.userInfos addObject:[[UserInfo alloc] initWithFirDataSnapshot:snapshot]];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
    [userRef
     observeEventType:FIRDataEventTypeChildChanged
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSInteger index = [self.userInfos indexOfObject:[self getUserByKey:snapshot.key]];
         UserInfo *info = [[UserInfo alloc] initWithFirDataSnapshot:snapshot];
         [self.userInfos replaceObjectAtIndex:index withObject:info];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
    [userRef
     observeEventType:FIRDataEventTypeChildRemoved
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         [self.userInfos removeObject:[self getUserByKey:snapshot.key]];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
     }];
}

- (void)favoriteForRoom:(RoomInfo*)room
{
    NSString *roomId = [room roomID];
    FIRDatabaseReference *ref = [[roomRef child:roomId] child:fkCHATROOMFAVORITEUSER];
    if ([room.favoriteUsers containsObject:self.uid])
    {
        [[ref child:self.uid] removeValue];
    }
    else
    {
        [ref updateChildValues:@{self.uid:fkCHATROOMFAVORITEUSER}];
    }
}

- (void)favoriteForUser:(UserInfo*)userInfo
{
    NSString *receiverID = [userInfo userID];
    NSString *userID = [self uid];
    if ([userID isEqualToString:receiverID])
    {
        return;
    }
    
    FIRDatabaseReference *followerRef = [[userRef child:receiverID] child:fkUSERFOLLOWER];
    FIRDatabaseReference *followeeRef = [[userRef child:userID] child:fkUSERFOLLOWEE];
    
    if ([userInfo.followerUser containsObject:userID])
    {
        [[followerRef child:userID] removeValue];
    }
    else
    {
        [followerRef updateChildValues:@{userID:fkUSERFOLLOWER}];
    }
    
    if ([[self getUserByKey:userID].followeeUser containsObject:receiverID])
    {
        [[followeeRef child:receiverID] removeValue];
    }
    else
    {
        [followeeRef updateChildValues:@{receiverID:fkUSERFOLLOWEE}];
    }
}

- (void)addUserForRoom:(RoomInfo*)room
{
    [[[roomRef child:[room roomID]] child:fkCHATROOMCURRENTUSER] updateChildValues:@{self.uid:fkCHATROOMCURRENTUSER}];
}

- (void)removeUserForRoom:(RoomInfo*)room
{
    [[[[roomRef child:[room roomID]] child:fkCHATROOMCURRENTUSER] child:self.uid] removeValue];
}

- (void)removeUserForRoomID:(NSString *)roomID
{
    [[[[roomRef child:roomID] child:fkCHATROOMCURRENTUSER] child:self.uid] removeValue];
}

-(void)createRoom:(NSString*)name
{
    [[roomRef childByAutoId] setValue:@{
                                        fkCHATROOMNAME:name,
                                        fkCHATROOMCREATORID:self.uid,
                                        fkCHATROOMCREATEDATE:[DateUtils dateToString]
                                        }];
}

- (void)deleteRoom:(RoomInfo*)room
{
    [[roomRef child:[room roomID]] removeValue];
    [[messagesRef child:[room roomID]] removeValue];
}

- (RoomInfo*)getRoomByKey:(NSString*)key
{
    for (RoomInfo *info in roomInfos)
    {
        if ([info.roomID isEqualToString:key])
        {
            return info;
        }
    }
    return nil;
}

- (UserInfo*)getUserByKey:(NSString*)key
{
    for (UserInfo *info in userInfos)
    {
        if ([info.userID isEqualToString:key])
        {
            return info;
        }
    }
    //if not found 
    UserInfo *info = [[UserInfo alloc] init];
    info.userID = key;
    return info;
}
@end
