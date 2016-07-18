//
//  UserInfo.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/11.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
- (id)initWithFirDataSnapshot:(FIRDataSnapshot*)snap
{
    self = [super init];
    
    if (self) {
        self.userID = snap.key;
        self.userName = snap.value[fkUSERNAME];
        self.photoUrl = snap.value[fkUSERPHOTOURL];
        self.followerUser = [NSMutableArray arrayWithArray:[snap.value[fkUSERFOLLOWER] allKeys]];
        self.followeeUser = [NSMutableArray arrayWithArray:[snap.value[fkUSERFOLLOWEE] allKeys]];
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoUrl]]];//[[UIImage alloc] init];
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//            //Background Thread
//            self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoUrl]]];
//        });
    }
    return self;
}

- (id)initWithUserInfo:(UserInfo*)info
{
    self = [super init];
    
    if (self)
    {
        self.userID = info.userID;
        self.userName = info.userName;
        self.photoUrl = info.photoUrl;
        self.followerUser = info.followeeUser;
        self.followeeUser = info.followerUser;
        self.image = info.image;
        self.badgeCount = 0;
    }
    
    return self;
}

@end
