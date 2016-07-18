//
//  NSString+AttributedString.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/13.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AttributeType) {
    AttributeTypeNone,
    AttributeTypeTitle,
    AttributeTypeSubTitle
};
@interface NSString (AttributedString)

- (NSMutableAttributedString*)withAttribute:(AttributeType)type;

@end
