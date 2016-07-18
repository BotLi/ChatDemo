//
//  ChatRoomListTableViewCell.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "ChatRoomListTableViewCell.h"

@implementation ChatRoomListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _chatTitleLabel = [[UILabel alloc] init];
        _chatTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _chatTitleLabel.numberOfLines = 3;
        [self.contentView addSubview:_chatTitleLabel];
        _favoriteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
        [_favoriteIcon setUserInteractionEnabled:YES];
        _favoriteIcon.image = [_favoriteIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.contentView addSubview:_favoriteIcon];
        _infoView = [UIView new];
        _favoriteIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
        _favoriteIconView.image = [_favoriteIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_favoriteIconView setTintColor:[UIColor blueColor]];
        [_infoView addSubview:_favoriteIconView];
        _favoriteCountLabel = [[UILabel alloc] init];
        [_infoView addSubview:_favoriteCountLabel];
        _usersIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Users"]];
        _usersIconView.image = [_usersIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_usersIconView setTintColor:[UIColor blueColor]];
        [_infoView addSubview:_usersIconView];
        _usersCountLabel = [[UILabel alloc] init];
        [_infoView addSubview:_usersCountLabel];
        _creatorIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Creator"]];
        _creatorIconView.image = [_creatorIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_creatorIconView setTintColor:[UIColor blueColor]];
        [_infoView addSubview:_creatorIconView];
        _creatorLabel = [[UILabel alloc] init];
        [_infoView addSubview:_creatorLabel];
        [self.contentView addSubview:_infoView];
        
        //add tap event
        for (UIView *v in @[_favoriteIcon])
        {
            UITapGestureRecognizer *tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
            [v addGestureRecognizer:tapGesture];
        }
    }
    
    return self;
}

- (void)tapEvent:(UITapGestureRecognizer*)gestureRecognizer
{
    UITableView *tableView = [self parentTableViewOf:self];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    if ([gestureRecognizer.view isEqual:_favoriteIcon] && [self.delegate respondsToSelector:@selector(ChatRoomListTableViewCell:favoriteIconTapAtIndexPath:)])
    {
        [self.delegate ChatRoomListTableViewCell:self favoriteIconTapAtIndexPath:indexPath];
    }
    else
    {
        if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[tableView indexPathForCell:self]];
        }
    }
}

- (UITableView *)parentTableViewOf:(UIView *)view {
    if([view.superview isKindOfClass:[UITableView class]]) {
        return (UITableView *)view.superview;
    } else {
        return [self parentTableViewOf:view.superview];
    }
    
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_chatTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(1);
        make.left.equalTo(self.left).offset(20);
        make.right.equalTo(_favoriteIcon.left).offset(-10);
        make.height.equalTo(self.contentView.frame.size.height*4/5);
    }];
    
    [_infoView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottom).offset(-1);
        make.left.equalTo(self.left).offset(10);
        make.right.equalTo(_favoriteIcon.left).offset(-10);
        make.height.equalTo(self.contentView.frame.size.height*1/5);
    }];
    
    [_favoriteIcon makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-10);
        make.width.height.equalTo(self.contentView.frame.size.height*3/5);
        make.centerY.equalTo(self.centerY);
    }];
    
    [_favoriteIconView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_infoView.left).offset(10);
        make.width.height.equalTo(self.contentView.frame.size.height*1/5);
        make.centerY.equalTo(_infoView.centerY);
    }];
    
    [_favoriteCountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_favoriteIconView.right).offset(2);
        make.height.equalTo(self.contentView.frame.size.height*1/5);
        make.width.lessThanOrEqualTo(self.contentView.frame.size.width*2/10);
        make.centerY.equalTo(_infoView.centerY);
    }];
    
    [_usersIconView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_favoriteCountLabel.right).offset(10);
        make.width.height.equalTo(self.contentView.frame.size.height*1/5);
        make.centerY.equalTo(_infoView.centerY);
    }];
    
    [_usersCountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_usersIconView.right).offset(2);
        make.height.equalTo(self.contentView.frame.size.height*1/5);
        make.width.lessThanOrEqualTo(self.contentView.frame.size.width*2/10);
        make.centerY.equalTo(_infoView.centerY);
    }];

    [_creatorIconView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_usersCountLabel.right).offset(10);
        make.width.height.equalTo(self.contentView.frame.size.height*1/5);
        make.centerY.equalTo(_infoView.centerY);
    }];
    
    [_creatorLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_creatorIconView.right).offset(2);
        make.height.equalTo(self.contentView.frame.size.height*1/5);
        make.width.lessThanOrEqualTo(self.contentView.frame.size.width*6/10);
        make.centerY.equalTo(_infoView.centerY);
    }];
}
@end
