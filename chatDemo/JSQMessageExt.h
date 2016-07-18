//
//  JSQMessageExt.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/13.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessage.h>

@interface JSQMessageExt : JSQMessage
@property (strong,nonatomic) NSString* messageBottomLabel;
@property (strong,nonatomic) NSString* messageKey;
- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
                      messageKey:(NSString*)messageKey
             messageBottomString:(NSString*)messageBottomString;
- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
                      messageKey:(NSString*)messageKey
             messageBottomString:(NSString*)messageBottomString;
@end
