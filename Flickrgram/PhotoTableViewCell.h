//
//  PhotoTableViewCell.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewCellProtocol : NSObject
- (void)userProfileWasTouched;
- (void)photoLocationWasTouched;
- (void)photoWasTouched;
- (void)photoLikesWasTouched;
@end


@interface PhotoTableViewCell : UITableViewCell

- (void)updateCellWithPhotoDictionary:(NSString *)photoURL;

@end
