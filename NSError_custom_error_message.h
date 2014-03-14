//
//  NSError_custom_error_message.h
//  MyWorldForiPad
//
//  Created by sadmin on 3/13/14.
//  Copyright (c) 2014 University of West Florida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSError (custom_message)
    @property (nonatomic, retain) NSString *custom_message;
@end


@implementation NSError (custom_message)

static char UIB_PROPERTY_KEY;

@dynamic custom_message;

-(void)setCustom_message:(NSString *)custom_message
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, custom_message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)custom_message
{
    return (NSString*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

@end