//
//  TimeViewController.h
// My World for iPad version 1.2
//

#import <UIKit/UIKit.h>


@interface TimeViewController : UIViewController<UITextFieldDelegate> {
    float distance;
    float adjDistance;
    IBOutlet UILabel *userTimeLabel;
    IBOutlet UILabel *carTimeLabel;
    IBOutlet UILabel *planeTimeLabel;
    IBOutlet UITextField *userSpeedTxtField;
    IBOutlet UILabel *distanceSecondLabel;
    IBOutlet UISegmentedControl *milesOrKmSegmentedControl;
    NSUserDefaults * defaults;
    BOOL miles;
}
@property(nonatomic,assign)float distance;
-(IBAction)calculateWithUserSpeed:(id)sender;
-(IBAction)milesOrKMValueChanged:(id)sender;
-(void) updateSpeedLabels:(float)distance;
- (IBAction)dismissView:(id)sender;

@end
