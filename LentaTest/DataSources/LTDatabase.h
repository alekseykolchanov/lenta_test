//
//  LTDatabase.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelHeaders.h"


NSString *const LTDatabaseDidStartPostUpdateNotification;
NSString *const LTDatabaseDidFinishPostUpdateNotification;

NSString *const LTDatabaseUpdateNotificationSourceUrlKey;
NSString *const LTDatabaseUpdateNotificationErrorKey;

@interface LTDatabase : NSObject

+(instancetype)sharedInstance;


-(void)didBecomeActive;


-(void)srvUpdatePostsForSource:(LTSource*)source;

@end
