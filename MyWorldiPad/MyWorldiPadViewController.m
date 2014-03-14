//
//  MyWorldiPadViewController.m
// My World for iPad version 1.2
//

#import "MyWorldiPadViewController.h"
#import "Annotation.h"
#import "AnnotationView.h"
#import "InfoViewController.h"
#import "TimeViewController.h"
#import "JMCGeocoder.h"
#import "NSError_custom_error_message.h"



#define InstructionsText @"Hold and Drag the Pin"
@interface MyWorldiPadViewController()
@property (strong, nonatomic) IBOutlet UILabel *shortestGreatCircleLabel;
@property (strong, nonatomic) IBOutlet UILabel *equirectangularLabel;
@property (strong,nonatomic) UIPopoverController * infoPopover;
@property (strong,nonatomic) UIPopoverController * timePopover;
@property (strong, nonatomic) JMCGeocoder * geocoder;


@end


@implementation MyWorldiPadViewController
@synthesize actionBarButton;
@synthesize infoBarButton;

@synthesize mapView, mapAnnotations,  annoCounter;
BOOL updated; // For checking if MapKit updated the user's location


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return  YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark core location

//shows user location
-(void) showStartLocation{
    mapView.showsUserLocation=YES;
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = mapView.userLocation.coordinate.latitude;
    newRegion.center.longitude = mapView.userLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 60;
    newRegion.span.longitudeDelta = 60;
    CLLocationCoordinate2D loc1=CLLocationCoordinate2DMake(37,-30);   
    MKCoordinateSpan span=MKCoordinateSpanMake(85, 85);
    MKCoordinateRegion r=MKCoordinateRegionMake(loc1, span);
    [mapView setRegion:r animated:YES];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) 
        return;
    if(!updated){
        //[self showCurrentLocation];
        updated=TRUE;
       // [self showStartLocation];
        MKCoordinateRegion newRegion;
        newRegion.center.latitude = newLocation.coordinate.latitude;
        newRegion.center.longitude =newLocation.coordinate.longitude ;
        newRegion.span.longitudeDelta=mapView.region.span.longitudeDelta *0.8;
        newRegion.span.latitudeDelta=mapView.region.span.latitudeDelta *0.8;
        // newRegion.center=mapView.region.center;
        [mapView setRegion:[mapView regionThatFits:newRegion] animated:TRUE];    
        [self showStartLocation];
    }
    [self updateUsersLocationInfo:newLocation];
}


-(void) updateUsersLocationInfo:(CLLocation *)location{
    NSString * latText=[NSString stringWithFormat:@"Latitude: %0.4f", location.coordinate.latitude];
    NSString * lonText=[NSString stringWithFormat:@"Longitude: %0.4f", location.coordinate.longitude];
    latitudeLabel.text=latText;
    longitudeLabel.text=lonText;
}


-(void)showAlertWithInfo{
    if([[defaults objectForKey:@"Alert"]isEqualToString:@"Yes"])
    {
        [self.view addSubview:customAlertView];
        customAlertView.frame=CGRectMake((self.view.frame.size.width-customAlertView.frame.size.width)/2.0, 100, customAlertView.frame.size.width, customAlertView.frame.size.height);
    }
}


- (IBAction)segmentValueChanged:(id)sender {
    if([(UISwitch *)sender isOn])   
    {
        [defaults setObject:@"Yes" forKey:@"Alert"];
    }
    else{
        [defaults setObject:@"No" forKey:@"Alert"];
        
    }
    [defaults synchronize];
}


- (IBAction)dismissCustomAlert:(id)sender {
    [customAlertView removeFromSuperview];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)// @"Distance From Me"
    {
        [self addAnnotation];
    }
    if(buttonIndex==1)// "Any Distance"
    {
        [self addTwoAnnotations:nil];
    }
    if(buttonIndex==2)//  @"How Long Does it Take?",
    {
        [self showTimeView:nil];
    }
    if(buttonIndex==3)//  Show my location,
    {
        [self findMyLocation];
    }
}


#pragma  mark Map View delegate


//Dragging
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    [mapView removeOverlays:mapView.overlays];
   
	if (oldState == MKAnnotationViewDragStateDragging) {
		Annotation *annotation = (Annotation *)annotationView.annotation;
        annotation.title=InstructionsText;
		annotation.subtitle = [NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) annotation.coordinate.latitude, (float) annotation.coordinate.longitude];
        
    }
    if(newState==MKAnnotationViewDragStateEnding)
    {
        Annotation *annotation = (Annotation *)annotationView.annotation;
        
		annotation.subtitle = [NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) annotation.coordinate.latitude, (float) annotation.coordinate.longitude];	
        
        //Draw the line between two points
        [annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
       
    }
    if (newState == MKAnnotationViewDragStateDragging) {
        NSLog(@"Dragging");

    }
    if (newState == MKAnnotationViewDragStateCanceling) {
        [annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
    
    [self updateLabels];
    [self measure:nil];
    [self drawLine];
}


//Drawing line between points
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    
    MKPolylineView * aView=[[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    if([overlay isKindOfClass:[MKGeodesicPolyline class]]){
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
     }
    else{
        aView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    }
    aView.lineWidth = 7;

    return aView;
}


//Delegate method returning view for annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
    AnnotationView *draggablePinView = (AnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    
	if (draggablePinView) {
        draggablePinView.annotation = annotation;
    } else {
		draggablePinView = [[AnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier]; 
	}
    draggablePinView.draggable=YES;
    draggablePinView.annotation = annotation;

    
    //	draggablePinView.annotation
	return draggablePinView;
}


- (void) mapView:(MKMapView *)_mapView didAddAnnotationViews:(NSArray *)views {
    CGRect visibleRect = [_mapView annotationVisibleRect]; 
    for (MKAnnotationView *view in views) {
        CGRect endFrame = view.frame;
        
        CGRect startFrame = endFrame; startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
        view.frame = startFrame;
        
        [UIView beginAnimations:@"drop" context:NULL]; 
        [UIView setAnimationDuration:1];
        
        view.frame = endFrame;
        
        [UIView commitAnimations];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if([view isKindOfClass:[AnnotationView class]] ){
        //view.annotation.
        CLLocationCoordinate2D loc= [view.annotation coordinate];
       [_geocoder getInformationAboutLocationWithCoordinate:loc withResults:^(NSString *message, NSError *error) {
           if(error){
               UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Information" message:error.custom_message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
               [al show];
           }
           else{
               UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Information" message: message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
               [al show];
           }
       }];
    }
}



-(void) drawLine{
    [mapView removeOverlays:mapView.overlays];
    if(mapAnnotations.count==0)
    {
        //No locations in the array.
    }
    else if(mapAnnotations.count==1){
        //Display distance
        CLLocationCoordinate2D point1=mapView.userLocation.coordinate;
        CLLocationCoordinate2D point2=[[mapAnnotations objectAtIndex:0]coordinate];
        CLLocationCoordinate2D  trackPoints[2];
        trackPoints[0]=point1;
        trackPoints[1]=point2;
        MKPolyline * poli=[MKPolyline polylineWithCoordinates:trackPoints count:2];
      
        
        //CLLocationCoordinate2D coords[2] = {sourceAirport.coordinate, destinationAirport.coordinate};
         MKGeodesicPolyline *flyPartPolyline = [MKGeodesicPolyline polylineWithCoordinates:trackPoints count:2];
        [mapView addOverlay:poli];
        [mapView addOverlay:flyPartPolyline];
        
    }
    else if(mapAnnotations.count==2){
        //Display distance
        CLLocationCoordinate2D point1=[[mapAnnotations objectAtIndex:1]coordinate];
        CLLocationCoordinate2D point2=[[mapAnnotations objectAtIndex:0]coordinate];
        CLLocationCoordinate2D  trackPoints[2];
        trackPoints[0]=point1;
        trackPoints[1]=point2;
        MKPolyline * poli=[MKPolyline polylineWithCoordinates:trackPoints count:2];
        MKGeodesicPolyline *flyPartPolyline = [MKGeodesicPolyline polylineWithCoordinates:trackPoints count:2];
        
        [mapView addOverlay:poli];
        [mapView addOverlay:flyPartPolyline];
    }
}


-(IBAction) segmentedControlSwitched:(id)sender{
    
    if( [(UISegmentedControl *) sender selectedSegmentIndex]==0)
    {
        self.mapView.mapType = MKMapTypeStandard;
    }
    if( [(UISegmentedControl *) sender selectedSegmentIndex]==1)
    {
        self.mapView.mapType = MKMapTypeSatellite;  
    } 
    if( [(UISegmentedControl *) sender selectedSegmentIndex]==2)
    {
        self.mapView.mapType = MKMapTypeHybrid;     
    }
}


//Calculates equirectangular projection distance along a path
-(void) calculateDistanceBetweenLocation: (CLLocation *)location1 andLocation: (CLLocation *)location2
{
    MKMapPoint  start, finish;
    start = MKMapPointForCoordinate(location1.coordinate);
    finish = MKMapPointForCoordinate(location2.coordinate);
    
    float R=6371.0; // mean radius of earth
    float lon1=location1.coordinate.longitude * M_PI/180.0;
    float lon2=location2.coordinate.longitude* M_PI/180.0;
    
    float lat1=location1.coordinate.latitude* M_PI/180.0;
    float lat2=location2.coordinate.latitude* M_PI/180.0; 
    
    float x=(lon2-lon1) * cos((lat1+lat2)/2.0);
    float y=(lat2-lat1);
    float d= sqrt(x*x + y*y) * R;
    
    distance=d; 
}

- (void)measure:(id)sender {
    miles=[defaults boolForKey:@"Miles"];    
    if(mapAnnotations.count==0)
    {
        //Error Display Alert
    }
    else if(mapAnnotations.count==1){
        //Display distance
        CLLocationCoordinate2D point1=mapView.userLocation.coordinate;
        CLLocationCoordinate2D point2=[[mapAnnotations objectAtIndex:0]coordinate];
        
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:point1.latitude longitude:point1.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:point2.latitude longitude:point2.longitude];
        
        [self calculateDistanceBetweenLocation:location1 andLocation:location2];
        
        // Now find the shortest great circle distance
        shortestDistanceKm = (([location1 distanceFromLocation:location2])/1000);
        shortestDistanceMiles = shortestDistanceKm*0.621371192237334;
    }
    else if(mapAnnotations.count==2){
        CLLocationCoordinate2D point1=[[mapAnnotations objectAtIndex:0]coordinate];
        CLLocationCoordinate2D point2=[[mapAnnotations objectAtIndex:1]coordinate];
        
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:point1.latitude longitude:point1.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:point2.latitude longitude:point2.longitude];
        [self calculateDistanceBetweenLocation:location1 andLocation:location2];
        
        // Now find the shortest great circle distance
        shortestDistanceKm = (([location1 distanceFromLocation:location2])/1000);
        shortestDistanceMiles = shortestDistanceKm * 0.621371192237334;
    }
    else{
        // do nothing
    }
    [self updateLabels];
}


#pragma mark adding annotations

-(IBAction) addAnnotation{
    [self showAlertWithInfo];
    
    [self measure:nil];
    
    // New change the coordinate depending on the zoom level - current region
    float delta = mapView.region.span.longitudeDelta;
    delta=0.2*delta;
    
    CLLocationCoordinate2D cord1=CLLocationCoordinate2DMake(mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude+delta);
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapAnnotations];
    [mapAnnotations removeAllObjects];
    Annotation * a=[[Annotation alloc]initWithCoordinate:cord1 addressDictionary:nil];
    a.title=InstructionsText;
    a.subtitle=[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude];
    [mapView addAnnotation:a];
    [mapAnnotations addObject:a];
    [self findMyLocation];
    [self drawLine];
    [self measure:nil];

}


- (IBAction)displayMenu:(id)sender {
    UIActionSheet * a=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Nothing, just looking at the Map" destructiveButtonTitle:nil otherButtonTitles:@"Distance From Me", @"Distance Between Places", @"How Long Will It Take?",@"Find me", nil];
    [a showInView:self.view];
}


- (IBAction)addTwoAnnotations:(id)sender {
    [self showAlertWithInfo];
    [self measure:nil];
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapAnnotations];
    [mapAnnotations removeAllObjects];
    float delta = mapView.region.span.longitudeDelta;
    delta=0.2*delta;
    
    CLLocationCoordinate2D cord1=CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude-delta);
    CLLocationCoordinate2D cord2=CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude+delta);
    Annotation * a=[[Annotation alloc]initWithCoordinate:cord1 addressDictionary:nil];
    Annotation * b=[[Annotation alloc]initWithCoordinate:cord2 addressDictionary:nil];
    
    a.title=InstructionsText;
    a.subtitle=[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude];
    
    b.title=InstructionsText;
    b.subtitle=[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude];
    
    [mapView addAnnotation:a];
    [mapView addAnnotation:b];
    [mapAnnotations addObject:a];
    [mapAnnotations addObject:b];
    [self findMyLocation];
    [self drawLine];
    [self measure:nil];


}


// Method called when the show my location button is pressed. and whenever we are adding annotations
-(void) findMyLocation{
    CLLocationCoordinate2D loc=	mapView.userLocation.location.coordinate;
    MKCoordinateSpan span=mapView.region.span;
    MKCoordinateRegion r=MKCoordinateRegionMake(loc, span);
    [mapView setRegion:r animated:YES];
}


// Delegate method that will be called whenever the location will be updated
- (void)mapView:(MKMapView *)_mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	if(!updated){
        CLLocationCoordinate2D loc=	userLocation.location.coordinate;
        MKCoordinateSpan span=MKCoordinateSpanMake(1, 1);
        MKCoordinateRegion r=MKCoordinateRegionMake(loc, span);
        [_mapView setRegion:r animated:YES];
		updated=TRUE;
	}
}

#pragma mark memory management
-(void)viewDidAppear:(BOOL)animated{
    // NSLog(@"View did appear %f", distance);
    if(distance>0)
    {
        [self measure:nil];
    }
}

-(BOOL)shouldAutorotate{
    //update labels here

    CGRect sg = self.shortestGreatCircleLabel.frame;
    CGRect ep = self.equirectangularLabel.frame;
    sg.size.width = CGRectGetWidth(self.view.bounds)/2.0;
    ep.size.width = CGRectGetWidth(self.view.bounds)/2.0;

    sg.origin = CGPointMake(0, 0);
    ep.origin = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0,0);
    
    self.shortestGreatCircleLabel.frame = sg;
    self.equirectangularLabel.frame = ep;
    
    
    return YES;

}


-(void)viewWillAppear:(BOOL)animated{
   // [self.shortestGreatCircleLabel removeConstraints:self.shortestGreatCircleLabel.constraints];
   // [self.equirectangularLabel removeConstraints:self.shortestGreatCircleLabel.constraints];
//    NSLayoutConstraint *constrain = [NSLayoutConstraint constraintWithItem:self.shortestGreatCircleLabel
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:0
//                                                                    toItem:self.view
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                multiplier:.5
//                                                                  constant:0];
//    
//    NSLayoutConstraint *constrain2 = [NSLayoutConstraint constraintWithItem:self.equirectangularLabel
//                                                                  attribute:NSLayoutAttributeWidth
//                                                                  relatedBy:0
//                                                                     toItem:self.view
//                                                                  attribute:NSLayoutAttributeWidth
//                                                                 multiplier:.5
//                                                                   constant:0];
//    
//    NSLayoutConstraint * constrain3 = [NSLayoutConstraint constraintWithItem:self.equirectangularLabel attribute:NSLayoutAttributeTop relatedBy:0 toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100];
//      NSLayoutConstraint * constrain4 = [NSLayoutConstraint constraintWithItem:self.shortestGreatCircleLabel attribute:NSLayoutAttributeTop relatedBy:0 toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100];
//    
//    
//    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.shortestGreatCircleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1  constant:35];
//    NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:self.equirectangularLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1  constant:35];
//    
//    
//    
//     [self.view addConstraint:constrain];
//     [self.view addConstraint:constrain2];
//     [self.view addConstraint:constrain3];
//     [self.view addConstraint:constrain4];
//    
//     [self.view addConstraint:con1];
//     [self.view addConstraint:con2];
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //fix autolayout issues
    
    self.equirectangularLabel.textColor =[UIColor redColor];
    self.shortestGreatCircleLabel.textColor =[UIColor blueColor];
    
    _geocoder = [[JMCGeocoder alloc]init];
    defaults=[NSUserDefaults standardUserDefaults];
    
//    if(![[defaults objectForKey:@"Alert"]isEqualToString:@"No"])
//    {
//        [defaults setObject:@"Yes" forKey:@"Alert"];
//    }
//    else{
        if([[defaults objectForKey:@"Alert"]isEqualToString:@"Yes"])
        {
            [showAlertSwitch setOn:YES];
        }
//        else{
//            [defaults setObject:@"No" forKey:@"Alert"];
//            [showAlertSwitch setOn:NO];
//        }
    
//    }
    miles=[defaults boolForKey:@"Miles"];
    
    [defaults synchronize];
    distanceFirstLabel.text=@"";
    
    //  mapView.showsUserLocation=YES;
	annoCounter = 0;
    mapView.delegate=self;
	mapView.mapType=MKMapTypeHybrid;
	mapAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
    // miles=FALSE;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // Set a movement threshold for new events.
    [self showStartLocation];
    [locationManager startMonitoringSignificantLocationChanges];

}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setInfoBarButton:nil];
    [self setActionBarButton:nil];
    locationManager.delegate=nil;
    mapView.delegate=nil;
    longitudeLabel = nil;
    altitudeLabel = nil;
    latitudeLabel = nil;
    customAlertView = nil;
    showAlertSwitch = nil;
    distanceFirstLabel = nil;
    timeView = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

//Information is released.

-(void) updateLabels {
    //Update labels
    distanceKm = distance;
    distanceMiles= distance * 1.0/1.609344;
    distanceFirstLabel.text=[NSString stringWithFormat:@"Equirectangular distance of line: %.1f Km / %.1f Miles          Shortest great circle distance: %.1f Km / %.1f Miles", distanceKm, distanceMiles, shortestDistanceKm, shortestDistanceMiles];
    
    self.shortestGreatCircleLabel.text =[NSString stringWithFormat:@"Shortest great circle distance: %.1f Km / %.1f Miles",shortestDistanceKm,shortestDistanceMiles];
    self.equirectangularLabel.text =[NSString stringWithFormat:@"Equirectangular distance of line: %.1f Km / %.1f Miles", distanceKm, distanceMiles];
}


- (IBAction)showInfoView:(id)sender {
    InfoViewController * i=[[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];

    if(!_infoPopover){
        _infoPopover=[[UIPopoverController alloc]initWithContentViewController:i];
    }
    if(_infoPopover.isPopoverVisible){
       
        [_infoPopover dismissPopoverAnimated:YES];
    }
     [_infoPopover presentPopoverFromBarButtonItem:infoBarButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)showTimeView:(id)sender{
    TimeViewController *time=[[TimeViewController alloc]initWithNibName:@"TimeViewController" bundle:nil];
    time.distance=distanceKm;
   // time.contentSizeForViewInPopover=time.view.frame.size;
    if(_timePopover.isPopoverVisible){
        [_timePopover dismissPopoverAnimated:YES];
    }
    
        self.timePopover=[[UIPopoverController alloc]initWithContentViewController:time];
    
    
    [_timePopover presentPopoverFromBarButtonItem:actionBarButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

}

@end
