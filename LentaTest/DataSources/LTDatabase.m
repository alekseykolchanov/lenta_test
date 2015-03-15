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
#import "ModelHeaders.h"


NSString *const LTDatabaseSourcesSyncedVerKey = @"LTDatabaseSourcesSyncedVerKey";


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
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"PostSources.plist"];
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


@end
