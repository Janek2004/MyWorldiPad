//
//  Annotation.h
// My World for iPad version 1.2
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface Annotation : MKPlacemark {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) 	NSString *title;
@property (nonatomic, assign) 	NSString *subtitle;

@end
