//
//  LTDatabase.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTDatabase : NSObject

+(instancetype)sharedInstance;


-(void)didBecomeActive;

@end
