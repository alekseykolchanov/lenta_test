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
#import "LTDatabase.h"

@interface LTPostCell ()

@property (weak, nonatomic) IBOutlet UIView *paperView;
@property (weak, nonatomic) IBOutlet UIImageView *postIV;
@property (weak, nonatomic) IBOutlet UIButton *sourceBtn;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

- (IBAction)sourceBtnClk:(id)sender;

@end


@implementation LTPostCell

-(void)awakeFromNib
{
    [self paperView].layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self paperView].layer.borderWidth = 0.5f;
    
}


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
        
        [[self postIV]setImage:nil];
        if ([post imageData])
        {
            UIImage *img = [UIImage imageWithData:[post imageData]];
            if (img)
            {
                [[self postIV]setImage:img];
            }else{
                [[LTDatabase sharedInstance]resetImageDataForPost:_post];
            }
        }else{
            [[LTDatabase sharedInstance]srvDownloadImageForPost:_post];
        }
        
    }
}


-(void)setOpened:(BOOL)isOpened animated:(BOOL)isAnimated
{
    if (isOpened)
    {
        
        if (isAnimated)
        {
            [[self descriptionLbl]setHidden:NO];
            [[self descriptionLbl]setAlpha:0.0f];
            
        
            
            [UIView animateKeyframesWithDuration:0.35f delay:0.0f options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.5f animations:^{
                    [[self descriptionLbl]setAlpha:1.0f];
                }];
            } completion:nil];
        }else{
            [[self descriptionLbl]setHidden:NO];
            [[self descriptionLbl]setAlpha:1.0f];
        }
    }else{
        
        if (isAnimated)
        {

            [UIView animateKeyframesWithDuration:0.35f delay:0.0f options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
                    [[self descriptionLbl]setAlpha:0.0f];
                }];
                
            } completion:^(BOOL finished) {
                [[self descriptionLbl]setHidden:YES];
            }];
        }else{
            [[self descriptionLbl]setHidden:YES];
            [[self descriptionLbl]setAlpha:0.0f];
        }
    }
}

- (IBAction)sourceBtnClk:(id)sender {
    
    if ([self delegate])
        [[self delegate]postCell:self didTapSourceForPost:[self post]];
    
}


@end
