//
//  PhotoTableViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "FlickrKit.h"
#import "PhotoTableViewCell.h"

@implementation PhotoTableViewController
{
  FKFlickrNetworkOperation  *_todaysInterestingOp;
  NSArray                   *_photos;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
    // register custom UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // start downloading interesting images for feed
    [self downloadInterestingImages];
    
    // navigation bar
    self.navigationItem.title = @"flickrgram";
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor purpleColor]];
  }
  
  return self;
}


#pragma mark - Helper Methods

- (void)downloadInterestingImages
{
  FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
  interesting.per_page = @"100";
  interesting.extras = @"<code>description</code>, <code>date_upload</code>, <code>owner_name</code>, <code>geo</code>, <code>tags</code>, <code>machine_tags</code>, <code>url_q</code>";
  
  _todaysInterestingOp = [[FlickrKit sharedFlickrKit] call:interesting completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (response) {
        
        NSMutableArray *photoDictionaries = [NSMutableArray array];
        
        for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
          [photoDictionaries addObject:photoDictionary];
        }
        _photos = photoDictionaries;
        
        // reload table data once _photos data model is populated
        [self.tableView reloadData];
      }
    });				
  }];
}


#pragma mark - TableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  #warning H: call class method on cell heightForRowWithDataModel
  return self.view.bounds.size.width;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // dequeue a reusable cell
  PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
  
  // create a new PhotoTableViewCell if no reusable ones are available in queue
  if (!cell) {
    cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
  }
  
  // configure the cell for the appropriate photo
  [cell updateCellWithPhotoDictionary:[_photos objectAtIndex:indexPath.row]];
  
  return cell;
}

@end
