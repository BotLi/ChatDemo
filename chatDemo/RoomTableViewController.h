//
//  RoomTableViewController.h
//  chatDemo
//
//  Created by Li Bot on 2016/6/25.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import FirebaseDatabase;
@import FirebaseGoogleAuthUI;
#import "ChatViewController.h"
#import "ChatRoomListTableViewCell.h"

@interface RoomTableViewController : UITableViewController<FIRAuthUIDelegate,ChatRoomListTableViewCellDelegate>
@property (strong,nonatomic) UISegmentedControl *segmentedCtrl;
@end

