//
//  UserModel.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, strong, readonly) NSURL    *photoURL;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *user;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFlickPhoto:(NSDictionary *)flickrPhotoDictionary NS_DESIGNATED_INITIALIZER;

@end
