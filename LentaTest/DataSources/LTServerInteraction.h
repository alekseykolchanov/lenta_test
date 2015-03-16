//
//  DCServerInteraction.h
//  ControlManager
//
//  Created by Aleksey on 16.02.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelHeaders.h"


typedef void(^LTServerCompletionBlock)(NSArray *itemsArray, NSError *error);



@interface LTServerInteraction : NSObject

+(instancetype)sharedInstance;

-(void)downloadPostsWithUrl:(NSString*)urlString withCompletion:(LTServerCompletionBlock)completion;

-(void)getImageDataAtUrl:(NSString*)imageUrlString withCompletion:(void (^) (NSData *imageData, NSError *error))completion;

    
@end
