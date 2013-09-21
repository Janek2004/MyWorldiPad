//
//  MyWorldiPadViewController.h
// My World for iPad version 1.2
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 
#import <CoreLocation/CoreLocation.h>  

@interface MyWorldiPadViewController : UIViewController
    <MKMapViewDelegate,  UIActionSheetDelegate, UIScrollViewDelegate, CLLocationManagerDelegate> {
        //Subviews
        IBOutlet UIView *timeView;
        //  IBOutlet UIView *infoView;    
        IBOutlet MKMapView*mapView;
        
        //Other
        NSMutableArray *mapAnnotations;
        int annoCounter;
        BOOL miles; // 1 or 2
        
        IBOutlet UILabel *distanceFirstLabel;
        //Custom Alert View
        IBOutlet UISwitch *showAlertSwitch;
        IBOutlet UIView *customAlertView;
        NSUserDefaults *defaults;
        //User's location
        
        IBOutlet UILabel *latitudeLabel;
        IBOutlet UILabel *altitudeLabel;
        IBOutlet UILabel *longitudeLabel;
        CLLocationManager *locationManager;
        float distance;
        float distanceKm;
        float distanceMiles;
        float shortestDistanceKm;
        float shortestDistanceMiles;
        
        
        UIBarButtonItem *actionBarButton;
        UIBarButtonItem *infoBarButton;
    }
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionBarButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *infoBarButton;
    
//Property defined. 
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;
@property(nonatomic, assign) int annoCounter;

-(IBAction) displayMenu:(id)sender;
-(IBAction) addTwoAnnotations:(id)sender;
-(IBAction) findMyLocation;
-(IBAction) addAnnotation;
-(IBAction) measure:(id)sender;
    
-(void) drawLine;
-(void) updateLabels;
    
- (IBAction)showTimeView:(id)sender;
- (IBAction)showInfoView:(id)sender;
    
-(void)showAlertWithInfo;
    
- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)dismissCustomAlert:(id)sender;
- (void) showStartLocation;
- (void) updateUsersLocationInfo:(CLLocation *)location;

@end
