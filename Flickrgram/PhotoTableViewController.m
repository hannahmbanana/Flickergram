//
//  PhotoTableViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoModel.h"
#import "PhotoTableViewCell.h"
#import "UserProfileViewController.h"
#import "LocationCollectionViewController.h"
#import "PhotoFeedModel.h"

@interface PhotoTableViewController () <PhotoTableViewCellProtocol>
@end

@implementation PhotoTableViewController
{
  PhotoFeedModel *_photoFeed;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
    // PHOTO FEED OBJECT
    _photoFeed = [[PhotoFeedModel alloc] initWithPhotoFeedModelType:PhotoFeedModelTypePopular];
    
    // start first small fetch
    [_photoFeed fetchPageWithCompletionBlock:^{
      
      // update the tableView
      [self.tableView reloadData];
      
      // immediately start second larger fetch
      [_photoFeed fetchPageWithCompletionBlock:^{
        
        // update the tableView
        [self.tableView reloadData];
      }];
    }];
    
    
    // TABLEVIEW CONFIG
    // disable tableView cell selection
    self.tableView.allowsSelection = NO;
    
    // register custom UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // enable tableView pull-to-refresh & add target-action pair
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *test = [[UIBarButtonItem alloc] initWithTitle:@"load data" style:UIBarButtonItemStylePlain target:self action:@selector(refreshFeed)];
    self.navigationItem.rightBarButtonItem = test;
    
    // navBar title
    self.navigationItem.title = @"500pixergram";
  }
  
  return self;
}


#pragma mark - Gesture Handling

- (void)refreshFeed
{
  NSLog(@"_photoFeed number of items = %lu", [_photoFeed numberOfItemsInFeed]);
  [_photoFeed fetchPageWithCompletionBlock:^{
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
  }];
}


#pragma mark - UITableViewDelegate

//////***** JUST COPIED THIS FROM THE INTERNET - what to do??**** /////////
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//  if (scrollView == self.tableView) {
//    CGFloat currentOffsetX = scrollView.contentOffset.x;
//    CGFloat currentOffSetY = scrollView.contentOffset.y;
//    CGFloat contentHeight = scrollView.contentSize.height;
//    
//    if (currentOffSetY < (contentHeight / 6.0f)) {
//      scrollView.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY + (contentHeight/2)));
//    }
//    if (currentOffSetY > ((contentHeight * 4)/ 6.0f)) {
//      scrollView.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY - (contentHeight/2)));
//    }
//  }
//}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photoFeed numberOfItemsInFeed];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // dequeue a reusable cell
  PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
  
  // create a new PhotoTableViewCell if no reusable ones are available in queue
  if (!cell) {
    cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
    cell.delegate = self;
  }
  
  // configure the cell for the appropriate photo
  cell.delegate = self;
  [cell updateCellWithPhotoObject:[_photoFeed objectAtIndex:indexPath.row]];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  PhotoModel *photoModel = [_photoFeed objectAtIndex:indexPath.row];
  CGFloat headerFooterCombinedHeight = [PhotoTableViewCell cellHeaderFooterHeightForDataModel:photoModel];
  return headerFooterCombinedHeight + self.view.bounds.size.width; // + square photo height
}


#pragma mark - PhotoTableViewCellProtocol

- (void)userProfileWasTouchedWithUser:(UserModel *)user;
{
  UserProfileViewController *userProfileView = [[UserProfileViewController alloc] initWithUser:user];
  
  [self.navigationController pushViewController:userProfileView animated:YES];
}

- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes name:(NSString *)name
{
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumInteritemSpacing = 1;
  layout.minimumLineSpacing = 1;
  layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 200);
  
  CGFloat numItemsLine = 5;
  layout.itemSize = CGSizeMake((self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine,
                               (self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine);
  
  LocationCollectionViewController *locationCVC = [[LocationCollectionViewController alloc] initWithCollectionViewLayout:layout coordinates:coordiantes];
  locationCVC.navigationItem.title = name;
  
  [self.navigationController pushViewController:locationCVC animated:YES];
}

@end
