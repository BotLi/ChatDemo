//
//  RoomInfo.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/10.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@interface RoomInfo : NSObject

@property (strong,nonatomic) NSString* roomID;
@property (strong,nonatomic) NSString* creatorID;
@property (strong,nonatomic) NSString* roomName;
@property (strong,nonatomic) NSMutableArray* favoriteUsers;
@property (strong,nonatomic) NSMutableArray* currentUsers;
@property (strong,nonatomic) NSString* createDate;
- (id)initWithFirDataSnapshot:(FIRDataSnapshot*)snap;

@end
