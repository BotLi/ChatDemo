//
//  JSQMessageExt.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/13.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "JSQMessageExt.h"

@implementation JSQMessageExt

@synthesize messageBottomLabel,messageKey;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
                      messageKey:(NSString*)key
             messageBottomString:(NSString*)messageBottomString
{
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    if (self)
    {
        messageKey = key;
        messageBottomLabel = messageBottomString;
    }
    return self;
}
- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
                      messageKey:(NSString*)key
             messageBottomString:(NSString*)messageBottomString
{
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:media];
    if (self)
    {
        messageKey = key;
        messageBottomLabel = messageBottomString;
    }
    return self;

}
@end
