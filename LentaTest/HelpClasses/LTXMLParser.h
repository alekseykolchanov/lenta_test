//
//  LTXMLParser.h
//  LentaTest
//
//  Created by Пользователь on 15/03/15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTXMLParser : NSObject

-(instancetype)initWithData:(NSData*)data;

@property (nonatomic,copy) void(^completionBlock)(NSArray * resItems,NSError* error);

-(void)startParse;

@end
