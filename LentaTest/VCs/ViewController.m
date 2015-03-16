//
//  ViewController.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "ViewController.h"
#import "LTDatabase.h"
#import "LTIOSPostsDataSource.h"
#import "LTWebViewController.h"

@interface ViewController ()<LTIOSPostsDataSourceDelegate>
{
    LTIOSPostsDataSource *_dataSource;

}

@property (nonatomic,strong) NSMutableDictionary *updateUrlsDictionary;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter]removeObserver:self name:LTDatabaseDidStartPostUpdateNotification object:[LTDatabase sharedInstance]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didStartUpdateNotification:) name:LTDatabaseDidStartPostUpdateNotification object:[LTDatabase sharedInstance]];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:LTDatabaseDidFinishPostUpdateNotification object:[LTDatabase sharedInstance]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishUpdateNotification:) name:LTDatabaseDidFinishPostUpdateNotification object:[LTDatabase sharedInstance]];
    
    
    _dataSource = [LTIOSPostsDataSource new];
    [_dataSource setMainTV:[self tableView]];
    [_dataSource setDelegate:self];
    
    [self prepareInterface];
}

-(void)prepareInterface
{
    [[self refreshControl]beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSMutableDictionary*)updateUrlsDictionary
{
    if (!_updateUrlsDictionary)
        _updateUrlsDictionary = [NSMutableDictionary new];
    
    return _updateUrlsDictionary;
}


-(void)didStartUpdateNotification:(NSNotification*)notification
{
    if ([notification userInfo][LTDatabaseUpdateNotificationSourceUrlKey])
    {
        [self updateUrlsDictionary][[notification userInfo][LTDatabaseUpdateNotificationSourceUrlKey]] = [NSDate date];
        
        [self updateRefreshControlState];
        
    }
        
}

-(void)didFinishUpdateNotification:(NSNotification*)notification
{
    if ([notification userInfo][LTDatabaseUpdateNotificationSourceUrlKey])
    {
        [[self updateUrlsDictionary]removeObjectForKey:[notification userInfo][LTDatabaseUpdateNotificationSourceUrlKey]];
        [self updateRefreshControlState];
    }
}

-(void)updateRefreshControlState
{
    NSArray *allKeys = [[[self updateUrlsDictionary]allKeys]copy];
    
    NSDate *now = [NSDate date];
    [allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSDate *keyDate = [self updateUrlsDictionary][key];
        if (!keyDate)
            return;
        if ([now timeIntervalSinceDate:keyDate]>15.0f){
            [[self updateUrlsDictionary]removeObjectForKey:key];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self updateUrlsDictionary]count]>0)
        {
            [[self refreshControl]beginRefreshing];
        }else{
            [[self refreshControl]endRefreshing];
        }
    });
    
}

- (IBAction)refreshControlAction:(id)sender
{
    [[LTDatabase sharedInstance]srvUpdatePostsForSource:nil];
}


#pragma mark - LTIOSPostsDataSourceDelegate
-(void)postsDataSourceDidTapSourceBtnForPost:(LTPost *)post
{
    if (!post || ![post link] || [[post link]length]==0)
        return;
    
    LTWebViewController *wvc = [[self storyboard]instantiateViewControllerWithIdentifier:@"LTWebViewController"];
    
    [wvc setUrlToShow:[[post link]copy]];
    [[self navigationController]pushViewController:wvc animated:YES];
    
}

@end
