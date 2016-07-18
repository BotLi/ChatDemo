//
//  NSString+AttributedString.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/13.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "NSString+AttributedString.h"

@implementation NSString (AttributedString)

- (NSMutableAttributedString*)withAttribute:(AttributeType)type
{
    UIFont *font=[UIFont fontWithName:@"Helvetica" size:26.0f];
    UIColor *textColor = [UIColor blackColor];
    switch (type) {
        case AttributeTypeTitle:
            font=[UIFont fontWithName:@"Helvetica" size:30.0f];
            textColor = [UIColor grayColor];
            break;
        case AttributeTypeSubTitle:
            font=[UIFont fontWithName:@"Helvetica" size:10.0f];
            textColor = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:self];
    NSInteger _stringLength=[self length];
    
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _stringLength)];
    [attString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, _stringLength)];
    return attString;
}

@end
