//
//  DateUtils.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/11.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSString*)dateToString:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString*)dateToString
{
    return [self dateToString:[NSDate date]];
}

+ (NSDate*)stringToDate:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

@end
