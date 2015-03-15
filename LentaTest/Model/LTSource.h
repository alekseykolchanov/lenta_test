//
//  LTSource.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTPost;

@interface LTSource : NSManagedObject

@property (nonatomic, retain) NSString * rssUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * identificator;
@property (nonatomic, retain) NSSet *posts;
@end

@interface LTSource (CoreDataGeneratedAccessors)

- (void)addPostsObject:(LTPost *)value;
- (void)removePostsObject:(LTPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
