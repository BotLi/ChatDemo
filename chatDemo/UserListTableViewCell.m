//
//  UserListTableViewCell.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "UserListTableViewCell.h"

@implementation UserListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _chatImageView = [[UIImageView alloc] initWithImage:nil];
        [self.contentView addSubview:_chatImageView];
        _chatTitleLabel = [[UILabel alloc] init];
        _chatTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _chatTitleLabel.numberOfLines = 3;
        [self.contentView addSubview:_chatTitleLabel];
        _chatMessageLabel = [[UILabel alloc] init];
        _chatMessageLabel.numberOfLines = 2;
        [_chatMessageLabel setUserInteractionEnabled:YES];
        [self.contentView addSubview:_chatMessageLabel];
        _favoriteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
        [_favoriteIcon setUserInteractionEnabled:YES];
        _favoriteIcon.image = [_favoriteIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.contentView addSubview:_favoriteIcon];

        //add tap event
        for (UIView *v in @[_chatMessageLabel,_favoriteIcon])
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
    
    if ([gestureRecognizer.view isEqual:_favoriteIcon] && [self.delegate respondsToSelector:@selector(UserListTableViewCell:favoriteIconTapAtIndexPath:)])
    {
        [self.delegate UserListTableViewCell:self favoriteIconTapAtIndexPath:indexPath];
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
    
    [_chatImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(1);
        make.bottom.equalTo(self.bottom).offset(-1);
        make.left.equalTo(self.left).offset(10);
        make.width.equalTo(self.height);
    }];
    
    [_chatTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(2);
        make.bottom.equalTo(self.bottom).offset(-2);
        make.left.equalTo(_chatImageView.right).offset(10);
        make.right.equalTo(_chatMessageLabel.left).offset(-10);
    }];
    
    [_chatMessageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(2);
        make.bottom.equalTo(self.bottom).offset(-2);
        make.right.equalTo(_favoriteIcon.left).offset(-10);
        make.width.equalTo(self.height);
    }];
    
    [_favoriteIcon makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-10);
        make.width.height.equalTo(self.contentView.frame.size.height*3/5);
        make.centerY.equalTo(self.centerY);
    }];
}
@end
