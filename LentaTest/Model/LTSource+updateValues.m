//
//  LTSource+updateValues.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTSource+updateValues.h"

@implementation LTSource (updateValues)

-(void)updateValuesWithPlistDictionary:(NSDictionary*)plistDictionary
{
    if (!plistDictionary)
        return;
    
    self.name = plistDictionary[@"name"];
    self.identificator = plistDictionary[@"identificator"];
    self.rssUrl = plistDictionary[@"rssUrl"];
    
}


@end
