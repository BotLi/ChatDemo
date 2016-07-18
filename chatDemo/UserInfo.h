//
//  UserInfo.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/11.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@interface UserInfo : NSObject

@property (strong,nonatomic) NSString* userID;
@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSString* photoUrl;
@property (strong,nonatomic) NSMutableArray* followerUser;
@property (strong,nonatomic) NSMutableArray* followeeUser;
@property (strong,nonatomic) UIImage *image;

@property (assign,nonatomic) NSInteger badgeCount;
@property (strong,nonatomic) NSString *lastMessage;
@property (strong,nonatomic) NSString *dateString;

- (id)initWithFirDataSnapshot:(FIRDataSnapshot*)snap;
- (id)initWithUserInfo:(UserInfo*)info;
@end
