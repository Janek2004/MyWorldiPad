//
//  MyWorldiPadViewController.m
// My World for iPad version 1.2
//

#import "MyWorldiPadViewController.h"
#import "Annotation.h"
#import "AnnotationView.h"
#import "InfoViewController.h"
#import "TimeViewController.h"


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
    // [mapView setRegion:[mapView regionThatFits:newRegion] animated:TRUE];
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
    distanceFirstLabel.text=@"";
	if (oldState == MKAnnotationViewDragStateDragging) {
		Annotation *annotation = (Annotation *)annotationView.annotation;
        annotation.title=@"Drag Me";
		annotation.subtitle = [[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) annotation.coordinate.latitude, (float) annotation.coordinate.longitude]retain];
        
    }
    if(newState==MKAnnotationViewDragStateEnding)
    {
        Annotation *annotation = (Annotation *)annotationView.annotation;
        //annotation.title=@"Drag Me";
		annotation.subtitle = [[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) annotation.coordinate.latitude, (float) annotation.coordinate.longitude]retain];	
        
        //Draw the line between two points
        [self drawLine];
        [self measure:nil];
    }
    if (newState == MKAnnotationViewDragStateDragging) {
        //NSLog(@"Dragging");
    }
}


//Drawing line between points
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    
    MKPolylineView * aView=[[[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay]autorelease];
    //  aView.fillColor = [[UIColor blueColor]   colorWithAlphaComponent:1.0];
    aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
    aView.lineWidth = 7;
    return aView;
}


//Delegate method returning view for annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    draggablePinView.draggable=YES;
	if (draggablePinView) {
        draggablePinView.annotation = annotation;
    } else {
		draggablePinView = [[AnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier]; 
	}		
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
        [mapView addOverlay:poli];
    }
    else if(mapAnnotations.count==2){
        //Display distance
        CLLocationCoordinate2D point1=[[mapAnnotations objectAtIndex:1]coordinate];
        CLLocationCoordinate2D point2=[[mapAnnotations objectAtIndex:0]coordinate];
        CLLocationCoordinate2D  trackPoints[2];
        trackPoints[0]=point1;
        trackPoints[1]=point2;
        MKPolyline * poli=[MKPolyline polylineWithCoordinates:trackPoints count:2];
        [mapView addOverlay:poli];
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
    a.title=@"Drag Me";
    a.subtitle=[[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude]retain];
    [mapView addAnnotation:a];
    [mapAnnotations addObject:a];
    [self findMyLocation];
    [self drawLine];
}


- (IBAction)displayMenu:(id)sender {
    UIActionSheet * a=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Nothing, just looking at the Map" destructiveButtonTitle:nil otherButtonTitles:@"Distance From Me", @"Distance Between Places", @"How Long Will It Take?",@"Find me", nil];
    [a showInView:self.view];
    [a release];
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
    
    a.title=@"Drag Me";
    a.subtitle=[[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude]retain];
    
    b.title=@"Drag Me";
    b.subtitle=[[NSString stringWithFormat:@"Latitude %7.4f Longitude %8.4f", (float) a.coordinate.latitude, (float) a.coordinate.longitude]retain];
    
    [mapView addAnnotation:a];
    [mapView addAnnotation:b];
    [mapAnnotations addObject:a];
    [mapAnnotations addObject:b];
    [self findMyLocation];
    [self drawLine];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    defaults=[NSUserDefaults standardUserDefaults];
    
    if(![[defaults objectForKey:@"Alert"]isEqualToString:@"No"])
    {
        [defaults setObject:@"Yes" forKey:@"Alert"];
    }
    else{
        if([[defaults objectForKey:@"Alert"]isEqualToString:@"Yes"])
        {
            [showAlertSwitch setOn:YES];
        }
        else{
            [defaults setObject:@"No" forKey:@"Alert"];
            [showAlertSwitch setOn:NO];
        }
    }
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
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 100;    
    [locationManager startUpdatingLocation];
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
    [longitudeLabel release];
    longitudeLabel = nil;
    [altitudeLabel release];
    altitudeLabel = nil;
    [latitudeLabel release];
    latitudeLabel = nil;
    [customAlertView release];
    customAlertView = nil;
    [showAlertSwitch release];
    showAlertSwitch = nil;
    [distanceFirstLabel release];
    distanceFirstLabel = nil;
    [timeView release];
    timeView = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

//Information is released.
- (void)dealloc {
    [locationManager release];
	[mapView release];
	[mapAnnotations release];
    [distanceFirstLabel release];
    [timeView release];
    [showAlertSwitch release];
    [customAlertView release];
    [latitudeLabel release];
    [altitudeLabel release];
    [longitudeLabel release];
    [actionBarButton release];
    [infoBarButton release];
	[super dealloc];
}

-(void) updateLabels {
    //Update labels
    distanceKm = distance;
    distanceMiles= distance * 1.0/1.609344;
    distanceFirstLabel.text=[NSString stringWithFormat:@"Equirectangular distance of line: %.1f Km / %.1f Miles          Shortest great circle distance: %.1f Km / %.1f Miles", distanceKm, distanceMiles, shortestDistanceKm, shortestDistanceMiles];
}


- (IBAction)showInfoView:(id)sender {
    InfoViewController * i=[[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
   // i.contentSizeForViewInPopover=i.view.frame.size;
    // [self presentModalViewController:i animated:YES];
    UIPopoverController * pop=[[UIPopoverController alloc]initWithContentViewController:i];
    [pop presentPopoverFromBarButtonItem:infoBarButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
    // [time release];
    // [i release];
}


- (IBAction)showTimeView:(id)sender{
    TimeViewController *time=[[TimeViewController alloc]initWithNibName:@"TimeViewController" bundle:nil];
    time.distance=distanceKm;
   // time.contentSizeForViewInPopover=time.view.frame.size;
    UIPopoverController * pop=[[UIPopoverController alloc]initWithContentViewController:time];
    [pop presentPopoverFromBarButtonItem:actionBarButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    // [time release];
    // [pop release];
}

@end
