//
//  LTCommonClass.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTCommonClass : NSObject

+(NSDate*)dateFromServerDateString:(NSString*)dateString;
+(NSString*)userFormatDateForPostDate:(NSDate*)date;


@end
