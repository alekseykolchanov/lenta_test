//
//  LTIOSPostsDataSource.m
//  LentaTest
//
//  Created by Aleksey on 15.03.15.
//  Copyright (c) 2015 DOTCAPITAL. All rights reserved.
//

#import "LTIOSPostsDataSource.h"
#import "LTPostCell.h"
#import "LTTableFooterView.h"

@interface LTIOSPostsDataSource()<LTPostCellDelegate>
{
__weak LTTableFooterView *_footerView;
}

@property (nonatomic,strong) NSMutableSet *selectedPostGUIDSet;

@end

@implementation LTIOSPostsDataSource

-(NSMutableSet*)selectedPostGUIDSet
{
    if (!_selectedPostGUIDSet)
        _selectedPostGUIDSet = [NSMutableSet new];
    
    return _selectedPostGUIDSet;
}
-(void)setMainTV:(UITableView*)mainTV
{
    _mainTV = mainTV;
    
    
    [_mainTV registerNib:[UINib nibWithNibName:@"LTPostCell" bundle:nil] forCellReuseIdentifier:@"LTPostCell"];
    [_mainTV registerNib:[UINib nibWithNibName:@"LTImagePostCell" bundle:nil] forCellReuseIdentifier:@"LTImagePostCell"];
    
    [_mainTV registerNib:[UINib nibWithNibName:@"LTImagePostCell_SizingWText" bundle:nil] forCellReuseIdentifier:@"LTImagePostCell_SizingWText"];
    [_mainTV registerNib:[UINib nibWithNibName:@"LTImagePostCell_SizingWOText" bundle:nil] forCellReuseIdentifier:@"LTImagePostCell_SizingWOText"];
    [_mainTV registerNib:[UINib nibWithNibName:@"LTPostCell_SizingWText" bundle:nil] forCellReuseIdentifier:@"LTPostCell_SizingWText"];
    [_mainTV registerNib:[UINib nibWithNibName:@"LTPostCell_SizingWOText" bundle:nil] forCellReuseIdentifier:@"LTPostCell_SizingWOText"];
    
    [_mainTV setDataSource:self];
    [_mainTV setDelegate:self];
    
    LTTableFooterView *fView = [[LTTableFooterView alloc]initWithFrame:CGRectZero];
    [_mainTV setTableFooterView:fView];
    _footerView = fView;
    
    
}


-(void)refetchPosts
{
    [super refetchPosts];
    
    [[self mainTV]reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LTPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    LTPostCell *cell;
    
    if ([post imageUrl] && [[post imageUrl]length]>0){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"LTImagePostCell" forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"LTPostCell" forIndexPath:indexPath];
    }
    
    
    [self configureCell:cell atIndexPath:indexPath];
    [cell setDelegate:self];
    
    return cell;
}

- (void)configureCell:(LTPostCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat lblWidth = [self mainTV].bounds.size.width-40;
    [[cell titleLbl]setPreferredMaxLayoutWidth:lblWidth];
    [[cell descriptionLbl]setPreferredMaxLayoutWidth:lblWidth];
    
    LTPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setPost:post];
    
    if ([[self selectedPostGUIDSet]member:[post guid]]){
        [cell setOpened:YES animated:NO];
    }else{
        [cell setOpened:NO animated:NO];
    }
    
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *selectedGUID;
    if ((selectedGUID = [[self selectedPostGUIDSet]member:[post guid]])){
        [[self selectedPostGUIDSet]removeObject:selectedGUID];
        [(LTPostCell*)[[self mainTV]cellForRowAtIndexPath:indexPath] setOpened:NO animated:YES];
    }else{
        [[self selectedPostGUIDSet]addObject:[[post guid]copy]];
        [(LTPostCell*)[[self mainTV]cellForRowAtIndexPath:indexPath] setOpened:YES animated:YES];
    }
    
    
    [[self mainTV]beginUpdates];
    [[self mainTV]endUpdates];
}

-(CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    LTPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    LTPostCell *sizingCell;
    if ([post imageUrl] && [[post imageUrl]length]>0)
    {
        if ([self isPostSelected:post]){
            sizingCell = [self imagePostCell_SizingWText];
        }else{
            sizingCell = [self imagePostCell_SizingWOText];
        }
    }else{
        if ([self isPostSelected:post]){
            sizingCell = [self postCell_SizingWText];
        }else{
            sizingCell = [self postCell_SizingWOText];
        }
    }
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}


-(LTPostCell*)postCell_SizingWText
{
    static LTPostCell *_postCell_SizingWText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _postCell_SizingWText = [_mainTV dequeueReusableCellWithIdentifier:@"LTPostCell_SizingWText"];
//        UINib *cellNib = [UINib nibWithNibName:@"LTPostCell_SizingWText" bundle:nil];
//        _postCell_SizingWText = [cellNib instantiateWithOwner:nil options:nil][0];
    });
    
    return _postCell_SizingWText;
}

-(LTPostCell*)postCell_SizingWOText
{
    static LTPostCell *_postCell_SizingWOText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _postCell_SizingWOText = [_mainTV dequeueReusableCellWithIdentifier:@"LTPostCell_SizingWOText"];
//        UINib *cellNib = [UINib nibWithNibName:@"LTPostCell_SizingWOText" bundle:nil];
//        _postCell_SizingWOText = [cellNib instantiateWithOwner:nil options:nil][0];
    });
    
    return _postCell_SizingWOText;
}

-(LTPostCell*)imagePostCell_SizingWText
{
    static LTPostCell *_imagePostCell_SizingWText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imagePostCell_SizingWText = [_mainTV dequeueReusableCellWithIdentifier:@"LTImagePostCell_SizingWText"];
//        UINib *cellNib = [UINib nibWithNibName:@"LTImagePostCell_SizingWText" bundle:nil];
//        _imagePostCell_SizingWText = [cellNib instantiateWithOwner:nil options:nil][0];
    });
    
    return _imagePostCell_SizingWText;
}

-(LTPostCell*)imagePostCell_SizingWOText
{
    static LTPostCell *_imagePostCell_SizingWOText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imagePostCell_SizingWOText = [_mainTV dequeueReusableCellWithIdentifier:@"LTImagePostCell_SizingWOText"];
//        UINib *cellNib = [UINib nibWithNibName:@"LTImagePostCell_SizingWOText" bundle:nil];
//        _imagePostCell_SizingWOText = [cellNib instantiateWithOwner:nil options:nil][0];
    });
    
    return _imagePostCell_SizingWOText;
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

-(BOOL)isPostSelected:(LTPost*)post
{
    if ([[self selectedPostGUIDSet]member:[post guid]]){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTV beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.mainTV insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.mainTV deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.mainTV;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(LTPostCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTV endUpdates];
}


#pragma mark - LTPostCellDelegate
-(void)postCell:(LTPostCell *)cell didTapSourceForPost:(LTPost *)post
{
    if ([self delegate])
        [[self delegate]postsDataSourceDidTapSourceBtnForPost:post];
}

@end
