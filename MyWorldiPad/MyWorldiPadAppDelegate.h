//
//  MyWorldiPadAppDelegate.h
// My World for iPad version 1.2
//

#import <UIKit/UIKit.h>

@class MyWorldiPadViewController;

@interface MyWorldiPadAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet MyWorldiPadViewController *viewController;

@end
