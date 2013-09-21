//
//  InfoViewController.m
// My World for iPad version 1.2
//

#import "InfoViewController.h"


@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Unused as of version 1.2 
//- (IBAction)openAppStore:(id)sender {
//     if([sender tag]==0)
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/math-stars/id447998622?ls=1&mt=8"]];
//    }
//    else{
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/name-is/id447174222?ls=1&mt=8"]];
//    }
//}

- (IBAction)dismissInfoView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{   
    [scrollView release];
    [infoSubView release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //Setting up sroll view
    [scrollView setContentSize:infoSubView.frame.size];
    [scrollView addSubview:infoSubView];
    scrollView.scrollEnabled=YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [infoSubView release];
    infoSubView = nil;
    [scrollView release];
    scrollView = nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
