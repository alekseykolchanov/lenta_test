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

@interface LTIOSPostsDataSource()
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
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"LTPostCellFull" forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"LTPostCellWOImage" forIndexPath:indexPath];
    }
    
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LTPostCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat lblWidth = [self mainTV].bounds.size.width-40;
    [[cell titleLbl]setPreferredMaxLayoutWidth:lblWidth];
    [[cell descriptionLbl]setPreferredMaxLayoutWidth:lblWidth];
    
    LTPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setPost:post];
    
    NSString *selectedGUID;
    if ((selectedGUID = [[self selectedPostGUIDSet]member:[post guid]])){
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
        sizingCell = [self sizingPostCellWithImage];
    }else{
        sizingCell = [self sizingPostCellWOImage];
    }
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}


-(LTPostCell*)sizingPostCellWithImage
{
    static LTPostCell *_sizingPostCellWithImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sizingPostCellWithImage = [self.mainTV dequeueReusableCellWithIdentifier:@"LTPostCellFull"];
    });
    
    return _sizingPostCellWithImage;
}

-(LTPostCell*)sizingPostCellWOImage
{
    static LTPostCell *_sizingPostCellWOImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sizingPostCellWOImage = [self.mainTV dequeueReusableCellWithIdentifier:@"LTPostCellWOImage"];
    });
    
    return _sizingPostCellWOImage;
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
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

@end
