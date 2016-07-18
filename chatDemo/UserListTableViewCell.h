//
//  UserListTableViewCell.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserListTableViewCell;
@protocol UserListTableViewCellDelegate <NSObject>

@optional
-(void)UserListTableViewCell:(UserListTableViewCell*)cell favoriteIconTapAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface UserListTableViewCell : UITableViewCell<UserListTableViewCellDelegate>

@property (strong,nonatomic) UIImageView *chatImageView;
@property (strong,nonatomic) UILabel *chatTitleLabel;
@property (strong,nonatomic) UILabel *chatMessageLabel;
@property (strong,nonatomic) UIImageView *favoriteIcon;
@property (nonatomic, weak) id<UserListTableViewCellDelegate> delegate;
@end
