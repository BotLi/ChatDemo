//
//  ChatListTableViewCell.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListTableViewCell : UITableViewCell

@property (strong,nonatomic) UIImageView *chatImageView;
@property (strong,nonatomic) UIView *groupView;
@property (strong,nonatomic) UILabel *chatTitleLabel;
@property (strong,nonatomic) UILabel *lastMessageLabel;
@property (strong,nonatomic) UILabel *lastMessageDateLabel;
@end
