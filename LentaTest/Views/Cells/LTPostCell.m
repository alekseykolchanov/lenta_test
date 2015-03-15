//
//  LTPostCell.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTPostCell.h"
#import "LTSource.h"

@interface LTPostCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postIV;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
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
        [[self descriptionLbl]setText:[post description]];
        [[self sourceBtn]setTitle:[[[self post] source]name] forState:UIControlStateNormal];
        
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
    
}

- (IBAction)sourceBtnClk:(id)sender {
    
    if ([self delegate])
        [[self delegate]postCell:self didTapSourceForPost:[self post]];
    
}


@end
