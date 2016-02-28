//
//  LocationViewController.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>


@interface LocationViewController : UIViewController

@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate;

@end
