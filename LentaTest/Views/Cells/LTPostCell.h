//
//  LTPostCell.h
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTPost.h"
@class LTPostCell;

@protocol LTPostCellDelegate <NSObject>

-(void)postCell:(LTPostCell*)cell didTapSourceForPost:(LTPost*)post;

@end

@interface LTPostCell : UITableViewCell

@property (nonatomic,weak) id<LTPostCellDelegate> delegate;

@property (nonatomic,strong) LTPost *post;
@property (nonatomic,readonly) BOOL isOpened;

-(void)setOpened:(BOOL)isOpened animated:(BOOL)isAnimated;


@end
