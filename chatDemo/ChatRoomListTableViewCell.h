//
//  ChatRoomListTableViewCell.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatRoomListTableViewCell;
@protocol ChatRoomListTableViewCellDelegate <NSObject>

@optional

-(void)ChatRoomListTableViewCell:(ChatRoomListTableViewCell*)cell favoriteIconTapAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface ChatRoomListTableViewCell : UITableViewCell<ChatRoomListTableViewCellDelegate>

@property (strong,nonatomic) UILabel *chatTitleLabel;
@property (strong,nonatomic) UIImageView *favoriteIcon;
@property (strong,nonatomic) UIView *infoView;
@property (strong,nonatomic) UIImageView *favoriteIconView;
@property (strong,nonatomic) UILabel *favoriteCountLabel;
@property (strong,nonatomic) UIImageView *usersIconView;
@property (strong,nonatomic) UILabel *usersCountLabel;
@property (strong,nonatomic) UIImageView *creatorIconView;
@property (strong,nonatomic) UILabel *creatorLabel;
@property (nonatomic, weak) id<ChatRoomListTableViewCellDelegate> delegate;
@end
