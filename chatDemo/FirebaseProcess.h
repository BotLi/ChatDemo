//
//  FirebaseProcess.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/12.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@class RoomInfo;
@class UserInfo;
@interface FirebaseProcess : NSObject

@property (strong,nonatomic) FIRUser *user;
@property (strong,nonatomic) NSString *uid;
@property (strong,nonatomic) NSMutableArray *roomInfos;
@property (strong,nonatomic) NSMutableArray *userInfos;
@property (strong,nonatomic) NSMutableArray *chatInfos;
@property (strong,nonatomic) FIRDatabaseReference *rootRef;
@property (strong,nonatomic) FIRDatabaseReference *roomRef;
@property (strong,nonatomic) FIRDatabaseReference *userRef;
@property (strong,nonatomic) FIRDatabaseReference *messagesRef;
@property (strong,nonatomic) FIRDatabaseReference *personalMessagesRef;

+ (instancetype)sharedInstance;
- (void)sync;
- (void)stopSync;

- (void)favoriteForRoom:(RoomInfo*)room;
- (void)favoriteForUser:(UserInfo*)uesr;

- (void)addUserForRoom:(RoomInfo*)room;
- (void)removeUserForRoom:(RoomInfo*)room;
- (void)removeUserForRoomID:(NSString *)roomID;

-(void)createRoom:(NSString*)roomName;
- (void)deleteRoom:(RoomInfo*)room;

- (RoomInfo*)getRoomByKey:(NSString*)key;
- (UserInfo*)getUserByKey:(NSString*)key;
@end
