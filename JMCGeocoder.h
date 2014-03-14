//
//  JMCGeocoder.h
//  MyWorldForiPad
//
//  Created by sadmin on 3/12/14.
//  Copyright (c) 2014 University of West Florida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface JMCGeocoder : NSObject
-(void)getInformationAboutLocationWithCoordinate:(CLLocationCoordinate2D )coordinate withResults:(void (^)(NSString* placemarks, NSError * error))result;



@end
