//
//  PhotoTableViewCell.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import "PhotoModel.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>


@protocol PhotoTableViewCellProtocol <NSObject>
- (void)userProfileWasTouchedWithUser:(UserModel *)user;
- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes name:(NSString *)name;
- (void)cellWasLongPressedWithPhoto:(PhotoModel *)photo;
@end


@interface PhotoTableViewCell : ASCellNode

@property (nonatomic, strong, readwrite) id<PhotoTableViewCellProtocol> delegate;

+ (CGFloat)cellHeaderFooterHeightForDataModel:(PhotoModel *)photo;

- (void)updateCellWithPhotoObject:(PhotoModel *)photo;

@end
