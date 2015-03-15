//
//  LTPostCell.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTPostCell.h"
#import "LTSource.h"
#import "LTCommonClass.h"

@interface LTPostCell ()

@property (weak, nonatomic) IBOutlet UIView *paperView;
@property (weak, nonatomic) IBOutlet UIImageView *postIV;
@property (weak, nonatomic) IBOutlet UIButton *sourceBtn;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleToSourceConstraint;

- (IBAction)sourceBtnClk:(id)sender;

@end


@implementation LTPostCell

-(void)setPost:(LTPost *)post
{
    _post = post;
    

    if (_post)
    {
        [[self titleLbl]setText:[post title]];
        [[self descriptionLbl]setText:[post shortDescr]];
        [[self sourceBtn]setTitle:[[[self post] source]name] forState:UIControlStateNormal];
        [[self dateLbl]setText:[LTCommonClass userFormatDateForPostDate:[post pubDate]]];
        
        
        if (![[self post]link] || [[[self post]link]length]==0)
        {
            [[self sourceBtn]setEnabled:NO];
        }else{
            [[self sourceBtn]setEnabled:YES];
        }
        
        [[self postIV]setImage:[UIImage imageWithData:[post imageData]]];
    }
}


-(void)setOpened:(BOOL)isOpened animated:(BOOL)isAnimated
{
    CGFloat constraintValue = isOpened?[self descriptionLbl].frame.size.height+12.0f:0.0f;
    if (isOpened)
    {
        
        if (isAnimated)
        {
            [[self descriptionLbl]setHidden:NO];
            [[self descriptionLbl]setAlpha:0.0f];
            
            [[self contentView]layoutIfNeeded];
            
            [UIView animateKeyframesWithDuration:0.20f delay:0.0f options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
                    [[self titleToSourceConstraint]setConstant:constraintValue];
                    [[self contentView]layoutIfNeeded];
                }];
                [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.5f animations:^{
                    [[self descriptionLbl]setAlpha:1.0f];
                }];
            } completion:nil];
        }else{
            [[self descriptionLbl]setHidden:NO];
            [[self descriptionLbl]setAlpha:1.0f];
            [[self titleToSourceConstraint]setConstant:constraintValue];
        }
    }else{
        
        if (isAnimated)
        {
            [[self contentView]layoutIfNeeded];
            [UIView animateKeyframesWithDuration:0.2f delay:0.0f options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
                    [[self descriptionLbl]setAlpha:0.0f];
                }];
                [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.5f animations:^{
                    [[self titleToSourceConstraint]setConstant:constraintValue];
                    [[self contentView]layoutIfNeeded];
                }];
                
            } completion:^(BOOL finished) {
                [[self descriptionLbl]setHidden:YES];
            }];
        }else{
            [[self descriptionLbl]setHidden:YES];
            [[self descriptionLbl]setAlpha:0.0f];
            [[self titleToSourceConstraint]setConstant:constraintValue];
        }
    }
}

- (IBAction)sourceBtnClk:(id)sender {
    
    if ([self delegate])
        [[self delegate]postCell:self didTapSourceForPost:[self post]];
    
}


@end
