//
//  LTCommonClass.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTCommonClass.h"


@implementation LTCommonClass


+(NSDateFormatter*)userFormatDateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_userFormatDateFormatter;
    dispatch_once(&onceToken, ^{
        _userFormatDateFormatter = [NSDateFormatter new];
        _userFormatDateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _userFormatDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _userFormatDateFormatter.locale = [NSLocale currentLocale];
        _userFormatDateFormatter.doesRelativeDateFormatting = YES;
    });
    
    
    return _userFormatDateFormatter;
}

+(NSDateFormatter *)serverDateFormatter{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_serverDateFormatter;
    dispatch_once(&onceToken, ^{
        
        _serverDateFormatter = [[NSDateFormatter alloc]init];
        [_serverDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [_serverDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_serverDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        
    });
    return _serverDateFormatter;
}


+(NSDate*)dateFromServerDateString:(NSString*)dateString
{
    if (!dateString)
        return nil;
    return [[self serverDateFormatter]dateFromString:dateString];
}


+(NSString*)userFormatDateForPostDate:(NSDate*)date
{
    return [[self userFormatDateFormatter]stringFromDate:date];
}


@end
