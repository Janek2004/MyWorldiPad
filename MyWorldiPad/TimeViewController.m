//
//  TimeViewController.m
//  My World for iPad version 1.2
//

#import "TimeViewController.h"


@implementation TimeViewController
@synthesize distance;

#pragma mark Text Field delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)calculateWithUserSpeed:(id)sender {
    float customSpeed= [userSpeedTxtField.text floatValue];
    
    if(customSpeed>0){
        float customTime=distance/customSpeed;
        userTimeLabel.text=[NSString stringWithFormat:@"%.2f hours by your speed", customTime];
    }
    else{
        userTimeLabel.text=@"Can't go that slow";
    }   
    [userSpeedTxtField resignFirstResponder];
}


- (IBAction)milesOrKMValueChanged:(id)sender {  
    if([milesOrKmSegmentedControl selectedSegmentIndex]==0)
    {
        [defaults setBool:YES forKey:@"Miles"];
        miles=YES;
        adjDistance=distance * 1.0/1.609344;
    }
    else{
        [defaults setBool:NO forKey:@"Miles"];
        miles=NO;
        adjDistance=distance;
    }
    [defaults synchronize];
    [self updateSpeedLabels:adjDistance];
}


-(void) updateSpeedLabels:(float) _distance{  
    if(miles==TRUE) {      //converting to miles
        float planeTime=_distance/600.0;
        float carTime=_distance/50.0;
        
        planeTimeLabel.text=[NSString stringWithFormat:@"%.2f hours by plane",planeTime];
        carTimeLabel.text=[NSString stringWithFormat:@"%.2f hours by car",carTime];
        distanceSecondLabel.text=[NSString stringWithFormat:@"%.1f Miles along path",_distance]; 
    }
    else {
        float time=_distance/(600.0 *1.609344);
        float carTime=_distance/(50.0 *1.609344);
        planeTimeLabel.text=[NSString stringWithFormat:@"%.2f hours by plane",time];
        carTimeLabel.text=[NSString stringWithFormat:@"%.2f hours by car",carTime];
        distanceSecondLabel.text=[NSString stringWithFormat:@"%.1f Km along path",_distance]; 
    }
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{   [super viewDidLoad];
    defaults=[NSUserDefaults standardUserDefaults];
    userTimeLabel.text=@"";
    // Do any additional setup after loading the view from its ni
    if([defaults boolForKey:@"Miles"]){
        [milesOrKmSegmentedControl setSelectedSegmentIndex:0];
        milesOrKmSegmentedControl.selectedSegmentIndex=0;
        miles=TRUE;
    }
    else{
        [milesOrKmSegmentedControl setSelectedSegmentIndex:1];
        milesOrKmSegmentedControl.selectedSegmentIndex=1;
        miles=FALSE;
    }
    [self calculateWithUserSpeed:nil];
    [self milesOrKMValueChanged:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    userSpeedTxtField = nil;
    planeTimeLabel = nil;
    carTimeLabel = nil;
    userTimeLabel = nil;
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
