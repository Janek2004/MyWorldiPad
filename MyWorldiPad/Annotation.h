//
//  Annotation.h
// My World for iPad version 1.2
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface Annotation : MKPlacemark {

//	NSString *__weak title;
//	NSString *__weak subtitle;
}

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) 	NSString *title;
@property (nonatomic, strong) 	NSString *subtitle;
@property (nonatomic, strong) CLPlacemark * placemark;

@end
