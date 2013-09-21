//
//  InfoViewController.h
// My World for iPad version 1.2
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *infoSubView;
}

//- (IBAction)openAppStore:(id)sender;
- (IBAction)dismissInfoView:(id)sender;

@end
