//
//  JMCGeocoder.m
//  MyWorldForiPad
//
//  Created by sadmin on 3/12/14.
//  Copyright (c) 2014 University of West Florida. All rights reserved.
//

#import "JMCGeocoder.h"
#import "NSError_custom_error_message.h"

@interface JMCGeocoder()
@property (nonatomic,strong) CLGeocoder * geocoder;
@property (nonatomic,strong) NSMutableDictionary * locationsDictionary;
@end
@implementation JMCGeocoder

/*
    Default Initializer
*/

- (id)init
{
    self = [super init];
    if (self) {
        _geocoder = [[CLGeocoder alloc]init];
        _locationsDictionary =  [NSMutableDictionary new];
    }
    return self;
}


/*
 get information about given location
 */
-(void)getInformationAboutLocationWithCoordinate:(CLLocationCoordinate2D )coordinate withResults:(void (^)(NSString* placemarks, NSError * error))result{
    if (!_geocoder){
        _geocoder = [[CLGeocoder alloc]init];
    }
   
    if(_geocoder.isGeocoding){
        NSError * myError = [NSError new];
        myError.custom_message = @"Hold on. Gecoder is currently busy.";
        
    }
    CLLocation * location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSString * hash = [NSString stringWithFormat:@"%f.%f",coordinate.latitude, coordinate.longitude];
    if(_locationsDictionary[hash]!=NULL){
        result(_locationsDictionary[hash],NULL);
        return;
    }
    
    
    [_geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error){
         NSError * myError;
         if(error){
             myError =[NSError new];
             myError.custom_message = error.localizedDescription;
         }

         NSString * combinedMessage =@"";
         for(CLPlacemark *pl in placemarks){
            NSString * message = [self getInformationFromPlacemark:pl];
            combinedMessage = [combinedMessage stringByAppendingString:[NSString stringWithFormat:@"%@ \n\n ", message]];
         }
         _locationsDictionary[hash] = combinedMessage;
    
          result(combinedMessage, error);
     }];
}

/*
 convert a placemark to string
 */

-(NSString *)getInformationFromPlacemark:(CLPlacemark *)placemark{
    NSString * message =@"";
    
    if(placemark.name &&placemark.name.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@",   placemark.name]];
    }
    
//    if(placemark.thoroughfare&&placemark.thoroughfare.length>0){
//        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n %@ ",placemark.thoroughfare]];
//    }
//
    if(placemark.locality&&placemark.locality.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n %@",placemark.locality]];
    }
    if(placemark.administrativeArea&&placemark.administrativeArea.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n %@",placemark.administrativeArea]];
    }
    if(placemark.country&&placemark.country.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n %@",placemark.country]];
    }
    if(placemark.ISOcountryCode&&placemark.ISOcountryCode.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@" (%@)",placemark.ISOcountryCode]];
    }

    if(placemark.postalCode&&placemark.postalCode.length>0){
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n %@",placemark.postalCode]];
    }
    
    return message;
}

@end

/*
 @property (nonatomic, readonly) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
 @property (nonatomic, readonly) NSString *subThoroughfare; // eg. 1
 @property (nonatomic, readonly) NSString *locality; // city, eg. Cupertino
 @property (nonatomic, readonly) NSString *subLocality; // neighborhood, common name, eg. Mission District
 @property (nonatomic, readonly) NSString *administrativeArea; // state, eg. CA
 @property (nonatomic, readonly) NSString *subAdministrativeArea; // county, eg. Santa Clara
 @property (nonatomic, readonly) NSString *postalCode; // zip code, eg. 95014
 @property (nonatomic, readonly) NSString *ISOcountryCode; // eg. US
 @property (nonatomic, readonly) NSString *country; // eg. United States
 @property (nonatomic, readonly) NSString *inlandWater; // eg. Lake Tahoe
 @property (nonatomic, readonly) NSString *ocean; // eg. Pacific Ocean
 @property (nonatomic, readonly) NSArray *areasOfInterest; // eg. Golden Gate Park
 */
