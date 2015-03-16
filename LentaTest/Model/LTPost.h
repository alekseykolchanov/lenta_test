//
//  LTPost.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTSource;

@interface LTPost : NSManagedObject

@property (nonatomic, retain) NSString * imageType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * shortDescr;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) LTSource *source;

@end
