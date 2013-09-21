//
//  MyWorldiPadAppDelegate.h
// My World for iPad version 1.2
//

#import <UIKit/UIKit.h>

@class MyWorldiPadViewController;

@interface MyWorldiPadAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MyWorldiPadViewController *viewController;

@end
