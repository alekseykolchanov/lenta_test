//
//  LTPost+updateValues.m
//  LentaTest
//
//  Created by Пользователь on 16/03/15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTPost+updateValues.h"
#import "LTCommonClass.h"

@implementation LTPost (updateValues)

-(void)updateValuesWithDict:(NSDictionary*)valDict
{
    if (!valDict)
        return;
    
    self.title = valDict[@"title"];
    self.shortDescr = valDict[@"description"];
    self.guid = valDict[@"guid"];
    self.link = valDict[@"link"];
    self.pubDate = [LTCommonClass dateFromServerDateString:valDict[@"pubDate"]];
    
    
    
    if (self.imageData)
    {
        if (![self.imageUrl isEqualToString:valDict[@"imageUrl"]])
            self.imageData = nil;
    }
    
    self.imageType = valDict[@"imageType"];
    self.imageUrl = valDict[@"imageUrl"];
}


@end
