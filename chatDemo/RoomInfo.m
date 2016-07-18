//
//  RoomInfo.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/10.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "RoomInfo.h"

@implementation RoomInfo
@synthesize currentUsers;
- (id)initWithFirDataSnapshot:(FIRDataSnapshot*)snap
{
    self = [super init];
    
    if (self) {
        self.roomID = snap.key;
        self.creatorID = snap.value[fkCHATROOMCREATORID];
        self.roomName = snap.value[fkCHATROOMNAME];
        self.favoriteUsers = [NSMutableArray arrayWithArray:[snap.value[fkCHATROOMFAVORITEUSER] allKeys]];
        self.currentUsers = [NSMutableArray arrayWithArray:[snap.value[fkCHATROOMCURRENTUSER] allKeys]];
        self.createDate = snap.value[fkCHATROOMCREATEDATE];
    }
    return self;
}

@end
