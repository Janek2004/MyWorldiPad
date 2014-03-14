//
//  AnnotationView.h
// My World for iPad version 1.2
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AnnotationView : MKAnnotationView {

}

@property (nonatomic,strong) CLPlacemark *placemark;
@end
