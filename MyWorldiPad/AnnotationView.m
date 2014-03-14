// AnnotationView.m
// My World for iPad version 1.2


#import "AnnotationView.h"
#import "Annotation.h"

@implementation AnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
        self.image =[UIImage imageNamed:@"Pin23"];
        self.draggable = YES;
        self.canShowCallout = YES;
        self.rightCalloutAccessoryView  =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
    
        return self;

}

@end
