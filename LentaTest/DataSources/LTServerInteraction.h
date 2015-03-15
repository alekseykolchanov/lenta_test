//
//  DCServerInteraction.h
//  ControlManager
//
//  Created by Aleksey on 16.02.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelHeaders.h"


typedef void(^LTServerCompletionBlock)(NSDictionary *response_dict, NSError *error);



@interface LTServerInteraction : NSObject

+(instancetype)sharedInstance;




    
@end
