//
//  AnnotationView.m
// My World for iPad version 1.2
//

#import "AnnotationView.h"


@implementation AnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
       MKPinAnnotationView * annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
       // annotationView.image =[UIImage imageNamed:@"Pin23"];
        annotationView.draggable = YES;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    return self;
}

@end
