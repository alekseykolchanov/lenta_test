//
//  LTIOSPostsDataSource.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTPostsDataSource.h"
#import <UIKit/UIKit.h>

@interface LTIOSPostsDataSource : LTPostsDataSource<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,weak) UITableView *mainTV;


@end
