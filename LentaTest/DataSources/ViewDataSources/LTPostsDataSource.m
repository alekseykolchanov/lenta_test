//
//  LTPostsDataSource.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTPostsDataSource.h"

NSString *const LTPostsDSCacheName = @"PostsCache";

@implementation LTPostsDataSource

-(id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[SDCoreDataController sharedInstance]backgroundManagedObjectContext]];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSaveMasterContext:) name:NSManagedObjectContextDidSaveNotification object:[[SDCoreDataController sharedInstance]backgroundManagedObjectContext]];
    }
    
    return self;
    
}

-(void)didSaveMasterContext:(NSNotification*)notification
{
    [[self managedObjectContext]mergeChangesFromContextDidSaveNotification:notification];
}

-(NSManagedObjectContext*)managedObjectContext
{
    if (!_managedObjectContext)
        _managedObjectContext = [[SDCoreDataController sharedInstance]newManagedObjectContext];
    
    return _managedObjectContext;
}

-(void)refetchPosts
{
    [NSFetchedResultsController deleteCacheWithName:LTPostsDSCacheName];
    
    [self fetchedResultsController].fetchRequest.predicate = [self currentFetchRequest].predicate;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:LTPostsDSCacheName];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self currentFetchRequest] managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:LTPostsDSCacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    
    return _fetchedResultsController;
}

-(NSFetchRequest*)currentFetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LTPost" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"source"]];
    NSPredicate *predicate;
    
    if ([self sourcesToShow] && [[self sourcesToShow]count]>0){
#warning TODO Fill to implement source filtering
    }
    
    [fetchRequest setPredicate:predicate];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}


@end
