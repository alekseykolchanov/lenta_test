//
//  DCServerInteraction.m
//  ControlManager
//
//  Created by Aleksey on 16.02.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTServerInteraction.h"
#import <UIKit/UIKit.h>




@interface LTServerInteraction ()<NSURLSessionDelegate>
{
    NSString *_apnsToken;
}

@property (nonatomic,strong) NSURLSession *mainURLSession;



@end



@implementation LTServerInteraction


+(instancetype)sharedInstance

{
    static dispatch_once_t once;
    static LTServerInteraction *sharedInst;
    dispatch_once(&once,^{
        sharedInst = [[self alloc]init];
    });
    return sharedInst;
}

-(id)init
{
    if (self=[super init])
    {
        
    }
    
    return self;
}




#pragma mark NSURLSession
-(NSURLSession *)mainURLSession
{
    if (!_mainURLSession)
    {
        NSURLSessionConfiguration *myConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [myConfiguration setAllowsCellularAccess:YES];
        [myConfiguration setURLCache:nil];
        [myConfiguration setHTTPMaximumConnectionsPerHost:2];
        [myConfiguration setTimeoutIntervalForRequest:30.0f];
        _mainURLSession = [NSURLSession sessionWithConfiguration:myConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _mainURLSession;
}


#pragma  mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"URLSession:didBecomeInvalidWithError:%@",[error localizedDescription]);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSLog(@"URLSession:didReceiveChallenge:completionHandler:");
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession:");
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if (completionHandler)
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
}

-(void)updateNetworkActivityIndicator
{
    [[self mainURLSession]getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
        NSUInteger cnt =[dataTasks count]+[uploadTasks count] + [downloadTasks count];
        if (cnt==0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
        }
    }];
}



-(NSDictionary*)dictionaryFromResponseData:(NSData*)dataContainer
{
    if (!dataContainer)
    {
        return @{};
    }
    
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:dataContainer
                                                      options:0
                                                        error:nil];
    
    if (!d)
    {
        return @{};
    }
    
    return d;
}


-(BOOL)manageResponseDictionary:(NSDictionary*)d
{
    if (!d)
        return NO;
    
    NSNumber *code =d[@"code"];
    
    if (code && [code longValue]>=200 && [code longValue]<=202)
    {
        return YES;
    }
    
    return NO;
    
}




@end
