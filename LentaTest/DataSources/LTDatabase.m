//
//  LTDatabase.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTDatabase.h"
#import "SDCoreDataController.h"
#import "LTServerInteraction.h"



NSString *const LTDatabaseSourcesSyncedVerKey = @"LTDatabaseSourcesSyncedVerKey";


NSString *const LTDatabaseDidStartPostUpdateNotification = @"LTDatabaseDidStartPostUpdateNotification";
NSString *const LTDatabaseDidFinishPostUpdateNotification = @"LTDatabaseDidFinishPostUpdateNotification";

NSString *const LTDatabaseUpdateNotificationSourceUrlKey =
@"LTDatabaseUpdateNotificationSourceUrlKey";
NSString *const LTDatabaseUpdateNotificationErrorKey =
@"LTDatabaseUpdateNotificationErrorKey";

@interface LTDatabase ()

@property (nonatomic,strong) NSString *sourcesSyncedVer;

@end


@implementation LTDatabase

@synthesize sourcesSyncedVer = _sourcesSyncedVer;

+(instancetype)sharedInstance

{
    static dispatch_once_t once;
    static LTDatabase *sharedInst;
    dispatch_once(&once,^{
        sharedInst = [[self alloc]init];
    });
    return sharedInst;
}


-(instancetype)init
{
    if (self = [super init])
    {
    
    }
    
    return self;
}


-(void)didBecomeActive
{
    if (![self isSourcesSynced])
    {
        [self syncSourcesPlistAndCoreData];
    }
    
    [self srvUpdatePostsForSource:nil];
}


#pragma mark - Sources
-(NSString *)sourcesSyncedVer
{
    if (!_sourcesSyncedVer)
        _sourcesSyncedVer = [[NSUserDefaults standardUserDefaults]objectForKey:LTDatabaseSourcesSyncedVerKey];
    
    return _sourcesSyncedVer;
}

-(void)setSourcesSyncedVer:(NSString *)sourcesSyncedVer
{
    _sourcesSyncedVer = sourcesSyncedVer;
    
    if (_sourcesSyncedVer){
        [[NSUserDefaults standardUserDefaults]setObject:_sourcesSyncedVer forKey:LTDatabaseSourcesSyncedVerKey];
    }else{
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:LTDatabaseSourcesSyncedVerKey];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSDictionary *)sourcesPlistContent
{
    static dispatch_once_t onceToken;
    static NSDictionary *_plistContent;
    dispatch_once(&onceToken, ^{
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:
                          @"PostSources" ofType:@"plist"];
        
        // Build the array from the plist
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            return;
        }
        
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        
        NSError *error = nil;
        _plistContent = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData options:0 format:nil error:&error];
    });
    
    return _plistContent;
}

-(BOOL)isSourcesSynced
{
    NSDictionary *sourcesPlistContent = [self sourcesPlistContent];
    if (!sourcesPlistContent)
        return YES;
    
    NSString *plistVer = sourcesPlistContent[@"ver"];
    if ([self sourcesSyncedVer] && [[self sourcesSyncedVer]compare:plistVer]==NSOrderedSame)
        return YES;
    
    return NO;
}

-(void)syncSourcesPlistAndCoreData
{
    NSDictionary *sourcesPlistContent = [self sourcesPlistContent];
    NSArray *plistArr = sourcesPlistContent[@"Sources"];
    if (!plistArr || ![plistArr isKindOfClass:[NSArray class]]){
        
        return;
    }

    
    NSDictionary *plistSourcesDict = [NSDictionary dictionaryWithObjects:plistArr forKeys:[plistArr valueForKey:@"identificator"]];
    
    NSManagedObjectContext *moc = [[SDCoreDataController sharedInstance]backgroundManagedObjectContext];
    
    NSArray *savedSources = [self allSourcesInContext:moc];
    
    NSMutableDictionary *savedSourcesDict = [[NSMutableDictionary alloc]initWithCapacity:[savedSources count]];
    
    [moc performBlockAndWait:^{
        if (savedSources)
            [savedSources enumerateObjectsUsingBlock:^(LTSource *savedSource, NSUInteger idx, BOOL *stop) {
                savedSourcesDict[[savedSource identificator]] = savedSource;
            }];
        
        [plistSourcesDict enumerateKeysAndObjectsUsingBlock:^(NSString *identificator, NSDictionary *plistSource, BOOL *stop) {
            LTSource *savedSource = savedSourcesDict[identificator];
            if (savedSource)
            {
                [savedSource updateValuesWithPlistDictionary:plistSource];
            }else{
                LTSource *nSource = (LTSource *)[self createManagedObjectWithName:@"LTSource" inContext:moc];
                [nSource updateValuesWithPlistDictionary:plistSource];
            }
        }];
        
        
        
        [savedSourcesDict enumerateKeysAndObjectsUsingBlock:^(NSString *identificator, LTSource *savedSource, BOOL *stop) {
            if (!plistSourcesDict[identificator])
                [moc deleteObject:savedSource];
        }];
        
        NSError *error;
        if ([moc hasChanges] && ![moc save:&error])
        {
            NSLog(@"Error while saving: %@",[error localizedDescription]);
        }
        
    }];
    
    [[SDCoreDataController sharedInstance]saveMasterContext];
    [self setSourcesSyncedVer:sourcesPlistContent[@"ver"]];
    
}

#pragma mark - Core Data
-(NSManagedObject*)createManagedObjectWithName:(NSString *)name inContext:(NSManagedObjectContext*)moc
{
    if (!name)
        return nil;
    
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:moc];
    
    return mo;
}


#pragma mark - Core Data Fetching
-(NSArray*)allSourcesInContext:(NSManagedObjectContext*)moc
{
    if (!moc)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"LTSource"];
    
    __block NSArray *allEntities;
    [moc performBlockAndWait:^{
        NSError *error;
        allEntities = [moc executeFetchRequest:fetchRequest error:&error];
    }];
    
    return allEntities;
}


#pragma mark - Server Fetching
-(void)srvUpdatePostsForSource:(LTSource*)source
{
    
    
    if (!source)
    {
        NSManagedObjectContext *moc = [[SDCoreDataController sharedInstance]backgroundManagedObjectContext];
        
        NSArray *allSources = [self allSourcesInContext:moc];
        [moc performBlockAndWait:^{
            [allSources enumerateObjectsUsingBlock:^(LTSource *_source, NSUInteger idx, BOOL *stop) {
                [self srvUpdatePostsForSource:_source];
            }];
        }];
        
    }
    
    __block NSString *sourceURLString = nil;
    __block NSString *sourceIdentificator = nil;
    
    [[source managedObjectContext]performBlockAndWait:^{
        sourceURLString = [[source rssUrl]copy];
        sourceIdentificator = [[source identificator]copy];
    }];
    
    if (!sourceURLString || !sourceIdentificator)
        return;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:LTDatabaseDidStartPostUpdateNotification object:self userInfo:@{LTDatabaseUpdateNotificationSourceUrlKey:sourceURLString}];
    
    [[LTServerInteraction sharedInstance]downloadPostsWithUrl:sourceURLString withCompletion:^(NSArray *resItemsArr, NSError *error) {
        
        if (!error && resItemsArr && [resItemsArr count]>0)
            [self syncServerPostArray:resItemsArr forSourceWithIdentificator:sourceIdentificator];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:LTDatabaseDidFinishPostUpdateNotification object:self userInfo:@{LTDatabaseUpdateNotificationSourceUrlKey:sourceURLString,LTDatabaseUpdateNotificationErrorKey:error==nil?[NSNull null]:error}];
    }];
}

#pragma mark - Syncing Posts
-(void)syncServerPostArray:(NSArray*)postsArr forSourceWithIdentificator:(NSString *)sourceIdentificator
{
    if (!sourceIdentificator || !postsArr || [postsArr count]==0)
        return;
    
    NSMutableDictionary *serverPostsDict = [NSMutableDictionary new];
    [postsArr enumerateObjectsUsingBlock:^(NSDictionary *postDict, NSUInteger idx, BOOL *stop) {
        if (postDict[@"guid"] && postDict[@"pubDate"])
            serverPostsDict[postDict[@"guid"]] = postDict;
    }];
    
    if ([serverPostsDict count]==0)
        return;
    
    NSManagedObjectContext *moc = [[SDCoreDataController sharedInstance]backgroundManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"LTSource"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identificator==%@",sourceIdentificator]];
    
    __block NSArray *allEntities;
    [moc performBlockAndWait:^{
        NSError *error;
        allEntities = [moc executeFetchRequest:fetchRequest error:&error];
        
        if (!allEntities || [allEntities count]==0)
            return;
        
        LTSource *source = [allEntities firstObject];
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"LTPost"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid IN $GUID_LIST"];
        [fetchRequest setPredicate:[predicate predicateWithSubstitutionVariables:
                             [NSDictionary dictionaryWithObject:[serverPostsDict allKeys] forKey:@"GUID_LIST"]]];
        
        NSArray *savedPosts = [moc executeFetchRequest:fetchRequest error:&error];
        [savedPosts enumerateObjectsUsingBlock:^(LTPost *savedPost, NSUInteger idx, BOOL *stop) {
            [savedPost updateValuesWithDict:serverPostsDict[savedPost.guid]];
            [savedPost setSource:source];
            
            [serverPostsDict removeObjectForKey:savedPost.guid];
        }];
        
        [serverPostsDict enumerateKeysAndObjectsUsingBlock:^(NSString *postGuid, NSDictionary *serverPostDict, BOOL *stop) {
            LTPost *nPost = (LTPost *)[self createManagedObjectWithName:@"LTPost" inContext:moc];
            [nPost updateValuesWithDict:serverPostDict];
            [nPost setSource:source];
        }];
        
        if ([moc hasChanges] && ![moc save:&error])
        {
            
        }
        
    }];
    

}

@end
