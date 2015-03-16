//
//  LTWebViewController.m
//  LentaTest
//
//  Created by Aleksey on 16.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTWebViewController.h"

@interface LTWebViewController ()

@property (nonatomic,weak) IBOutlet UIWebView *webView;

@end

@implementation LTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self urlToShow])
    {
        [[self webView]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self urlToShow]]]];
        
        [[self navigationItem]setTitle:[self urlToShow]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
