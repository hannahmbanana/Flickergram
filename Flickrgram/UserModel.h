//
//  UserModel.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *userFirstName;
@property (nonatomic, strong, readonly) NSString *userLastName;
@property (nonatomic, strong, readonly) NSString *userCity;
@property (nonatomic, strong, readonly) NSString *userCountry;
@property (nonatomic, strong, readonly) NSURL    *userPicURL;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWith500pxPhoto:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
