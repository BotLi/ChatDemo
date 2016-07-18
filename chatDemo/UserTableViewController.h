//
//  UserTableViewController.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/5.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListTableViewCell.h"
#import "UserInfo.h"
@import Firebase;

@interface UserTableViewController : UITableViewController<UserListTableViewCellDelegate>

@property (strong,nonatomic) NSString* roomID;
@property (strong,nonatomic) UISegmentedControl *segmentedCtrl;
- (id)initWithRoomID:(NSString*)rid;
@end
