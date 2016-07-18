//
//  ChatListTableViewCell.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/4.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "ChatListTableViewCell.h"

@implementation ChatListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _chatImageView = [[UIImageView alloc] initWithImage:nil];
        [self.contentView addSubview:_chatImageView];
        
        _groupView = [UIView new];
        
        _chatTitleLabel = [[UILabel alloc] init];
        _chatTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _chatTitleLabel.numberOfLines = 3;
        [_groupView addSubview:_chatTitleLabel];
        
        _lastMessageLabel = [[UILabel alloc] init];
        _lastMessageLabel.textAlignment = NSTextAlignmentRight;
        [_groupView addSubview:_lastMessageLabel];
        
        _lastMessageDateLabel = [[UILabel alloc] init];
        _lastMessageDateLabel.textAlignment = NSTextAlignmentRight;
        [_groupView addSubview:_lastMessageDateLabel];
        
        [self.contentView addSubview:_groupView];
        
//        _chatImageView.layer.borderColor = [[UIColor blueColor] CGColor];
//        _chatImageView.layer.borderWidth = 1.0f;
//        _chatTitleLabel.layer.borderColor = [[UIColor blueColor] CGColor];
//        _chatTitleLabel.layer.borderWidth = 1.0f;
//        _lastMessageLabel.layer.borderColor = [[UIColor blueColor] CGColor];
//        _lastMessageLabel.layer.borderWidth = 1.0f;
//        _lastMessageDateLabel.layer.borderColor = [[UIColor blueColor] CGColor];
//        _lastMessageDateLabel.layer.borderWidth = 1.0f;
//        _groupView.layer.borderColor = [[UIColor blueColor] CGColor];
//        _groupView.layer.borderWidth = 1.0f;
    }
    
    return self;
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
    
    [_groupView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_chatImageView.right).offset(10);
        make.right.equalTo(self.right).offset(-50);
        make.height.equalTo(self.height);
    }];
    
    [_chatTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_groupView.top);
        make.bottom.equalTo(_groupView.bottom).offset(-1);
        make.left.equalTo(_groupView.left).offset(1);
    }];
    
    [_lastMessageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_groupView.top).offset(1);
        make.left.equalTo(_chatTitleLabel.right).offset(10);
        make.right.equalTo(_groupView.right);
        make.height.equalTo(self.contentView.frame.size.height*3/5);
    }];
    
    [_lastMessageDateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_groupView.bottom).offset(-1);
        make.left.equalTo(_chatTitleLabel.right).offset(10);
        make.right.equalTo(_groupView.right);
        make.height.equalTo(self.contentView.frame.size.height*2/5);
    }];
    
    [_chatTitleLabel setContentHuggingPriority:UILayoutPriorityRequired
                                       forAxis:UILayoutConstraintAxisHorizontal];
    [_chatTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                     forAxis:UILayoutConstraintAxisHorizontal];
    
    [_lastMessageLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                         forAxis:UILayoutConstraintAxisHorizontal];
    [_lastMessageLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                       forAxis:UILayoutConstraintAxisHorizontal];
}
@end
