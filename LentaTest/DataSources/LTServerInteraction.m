//
//  DCServerInteraction.m
//  ControlManager
//
//  Created by Aleksey on 16.02.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTServerInteraction.h"
#import <UIKit/UIKit.h>
#import "LTXMLParser.h"




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



-(void)downloadPostsWithUrl:(NSString*)urlString withCompletion:(LTServerCompletionBlock)completion
{
    if (!urlString)
    {
        if (completion){
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Wrong url string: %@",urlString]};
            NSError *error = [[NSError alloc] initWithDomain:@"ServerInteractionDomain"
                                                        code:0
                                                    userInfo:userInfoDict];
            completion(nil,error);
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    [req setTimeoutInterval:15.0f];
    
    NSURLSessionDataTask *dTask = [[self mainURLSession] dataTaskWithRequest:req completionHandler:^(NSData *resData, NSURLResponse *response, NSError *error){
        if (!error)
        {
            LTXMLParser *parser = [[LTXMLParser alloc]initWithData:resData];
            if (!parser)
            {
                if (completion)
                {
                    NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : @"Unable to parse server response in XML" };
                    NSError *error = [[NSError alloc] initWithDomain:@"XMLParserDomain"
                                                                code:0
                                                            userInfo:userInfoDict];
                    
                    completion(nil,error);
                }
            }
            
            [parser setCompletionBlock:^(NSArray* resItems, NSError *error) {
                
                if (completion)
                    completion(resItems,error);
                
            }];
            
            [parser startParse];
            
        }else{
            if (completion)
                completion(nil,error);
        }
        
        [self updateNetworkActivityIndicator];
    }];
    
    [dTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
}



@end
