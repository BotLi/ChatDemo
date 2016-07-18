//
//  DateUtils.h
//  chatDemo
//
//  Created by Li Bot on 2016/7/11.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSString*)dateToString:(NSDate*)date;
+ (NSString*)dateToString;
+ (NSDate*)stringToDate:(NSString*)string;

@end
