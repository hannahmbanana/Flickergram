//
//  PhotoFeedViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoFeedViewController.h"
#import "PhotoModel.h"
#import "PhotoTableViewCell.h"
#import "UserProfileViewController.h"
#import "LocationCollectionViewController.h"
#import "PhotoFeedModel.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface PhotoFeedViewController () <ASTableDelegate, ASTableDataSource, PhotoTableViewCellProtocol>
@end

@implementation PhotoFeedViewController
{
  PhotoFeedModel *_photoFeed;
  ASTableView    *_tableView;
}


#pragma mark - Lifecycle

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
  if (self) {
    
    
    // ASTABLEVIEW
    _tableView = [[ASTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain asyncDataFetching:YES];
    _tableView.asyncDataSource = self;
    _tableView.asyncDelegate = self;
    
    // PHOTO FEED OBJECT
    _photoFeed = [[PhotoFeedModel alloc] initWithPhotoFeedModelType:PhotoFeedModelTypePopular];
    
    // start first small fetch
    [_photoFeed refreshFeedWithCompletionBlock:^(NSArray *newPhotos){
      
      // update the tableView
      [_tableView reloadData];
      
      // immediately start second larger fetch
//      [self loadPage];
    }];
    
    
    // TABLEVIEW CONFIG
    // disable tableView cell selection
    _tableView.allowsSelection = NO;
    
    // register custom UITableViewCell subclass
//    [_tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"]; // not available in ASDK ASTableView
    
    // enable tableView pull-to-refresh & add target-action pair
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *loadData = [[UIBarButtonItem alloc] initWithTitle:@"load data" style:UIBarButtonItemStylePlain target:self action:@selector(loadPage)];
    self.navigationItem.rightBarButtonItem = loadData;
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearFeed)];
    self.navigationItem.leftBarButtonItem = clear;
    
    // navBar title
    self.navigationItem.title = @"500pixgram";
  }
  
  return self;
}

- (void)loadView
{
  [super loadView];
  
  [self.view addSubview:_tableView];  //FIXME: move these to loadView
  self.view.backgroundColor = [UIColor whiteColor]; //ditto
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  _tableView.frame = self.view.bounds;
}

#pragma mark - Gesture Handling

- (void)clearFeed
{
  [_photoFeed clearFeed];
  [_tableView reloadData];
}

- (void)refreshFeed
{
  [_photoFeed refreshFeedWithCompletionBlock:^(NSArray *newPhotos){
    
    [_tableView reloadData];
    
    NSLog(@"_photoFeed number of items = %lu", [_photoFeed numberOfItemsInFeed]);
    
//    [self.refreshControl endRefreshing];
  }];
}

- (void)loadPage
{
  NSLog(@"_photoFeed number of items = %lu", [_photoFeed numberOfItemsInFeed]);
  
  [self logPhotoIDsInPhotoFeed];

  [_photoFeed requestPageWithCompletionBlock:^(NSArray *newPhotos){
    
    [self insertNewRowsInTableView:newPhotos];
    
    [self logPhotoIDsInPhotoFeed];

  }];
}

- (void)logPhotoIDsInPhotoFeed
{
  NSLog(@"_photoFeed number of items = %lu", [_photoFeed numberOfItemsInFeed]);
  
  for (int i = 0; i < [_photoFeed numberOfItemsInFeed]; i++) {
    if (i % 4 == 0 && i > 0) {
      NSLog(@"\t-----");
    }
    
//    [_photoFeed return]
//    NSString *duplicate =  ? @"(DUPLICATE)" : @"";
    NSLog(@"\t%@  %@", [[_photoFeed objectAtIndex:i] photoID], @"");
  }
}

- (void)insertNewRowsInTableView:(NSArray *)newPhotos
{
 // instead of doing tableView reloadData, use table editing commands
  NSMutableArray *indexPaths = [NSMutableArray array];
  
  NSInteger section = 0;
  NSUInteger newTotalNumberOfPhotos = [_photoFeed numberOfItemsInFeed];
  for (NSUInteger row = newTotalNumberOfPhotos - newPhotos.count; row < newTotalNumberOfPhotos; row++) {
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    [indexPaths addObject:path];
  }
  
  [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - ASTableDelegate protocol methods
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//  if (scrollView == _tableView) {
//    CGFloat currentOffSetY = scrollView.contentOffset.y;
//    CGFloat contentHeight = scrollView.contentSize.height;
//    
//    if (currentOffSetY > (contentHeight * 3.0 / 4.0)) {
//      [self loadPage];
//    }
//  }
//}


#pragma mark - ASTableDataSource protocol methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photoFeed numberOfItemsInFeed];
}

- (ASCellNode *)tableView:(ASTableView *)tableView nodeForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  // dequeue a reusable cell
//  PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
  
  // create a new PhotoTableViewCell if no reusable ones are available in queue
//  if (!cell) {
  PhotoTableViewCell *cell = [[PhotoTableViewCell alloc] init];
  cell.delegate = self;
//  }
  
  // configure the cell for the appropriate photo
  [cell updateCellWithPhotoObject:[_photoFeed objectAtIndex:indexPath.row]];
  
  return cell;
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
  
  CGFloat numItemsLine = 3;
  layout.itemSize = CGSizeMake((self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine,
                               (self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine);
  
  LocationCollectionViewController *locationCVC = [[LocationCollectionViewController alloc] initWithCollectionViewLayout:layout coordinates:coordiantes];
  locationCVC.navigationItem.title = name;
  
  [self.navigationController pushViewController:locationCVC animated:YES];
}

- (void)cellWasLongPressedWithPhoto:(PhotoModel *)photo
{
  UIAlertAction *savePhotoAction = [UIAlertAction actionWithTitle:@"Save Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                            NSLog(@"hi");
                                                          }];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                       }];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
  
  [alert addAction:savePhotoAction];
  [alert addAction:cancelAction];
  
  [self presentViewController:alert animated:YES completion:^{}];
}


@end
