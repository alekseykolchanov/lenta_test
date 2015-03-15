//
//  LTPostsDataSource.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelHeaders.h"
#import "SDCoreDataController.h"

@interface LTPostsDataSource : NSObject<NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSSet *sourcesToShow;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;


-(void)refetchPosts;


@end
