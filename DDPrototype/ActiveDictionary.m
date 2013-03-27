//
//  ActiveDictionary.m
//  DDPrototype
//
//  Created by Alison KLINE on 3/24/13.
//
//

#import "ActiveDictionary.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// simple subclass of UIManagedDocument so that errors can be seen

@implementation ActiveDictionary

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Auto-Saving Document");
    return [super contentsForType:typeName error:outError];
}

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    NSLog(@"UIManagedDocument error: %@", error.localizedDescription);
    NSArray* errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(errors != nil && errors.count > 0) {
        for (NSError *error in errors) {
            NSLog(@"  Error: %@", error.userInfo);
        }
    } else {
        NSLog(@"  %@", error.userInfo);
    }
}

@end
