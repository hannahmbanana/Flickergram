//
//  PhotoTableViewCell.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@protocol PhotoTableViewCellProtocol <NSObject>
- (void)userProfileWasTouchedWithUserID:(NSString *)userID;
- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes;
//- (void)photoLikesWasTouched;
@end


@interface PhotoTableViewCell : UITableViewCell

@property (nonatomic, strong, readwrite) id<PhotoTableViewCellProtocol> delegate;

- (void)updateCellWithPhotoDictionary:(NSString *)photoURL;

@end
