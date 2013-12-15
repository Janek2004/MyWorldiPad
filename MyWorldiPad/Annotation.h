//
//  Annotation.h
// My World for iPad version 1.2
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface Annotation : MKPlacemark {
	CLLocationCoordinate2D coordinate;
	NSString *__weak title;
	NSString *__weak subtitle;
}
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) 	NSString *title;
@property (nonatomic, weak) 	NSString *subtitle;

@end
