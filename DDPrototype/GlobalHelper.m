//
//  GlobalHelper.m
//  DDPrototype
//
//  Created by Alison KLINE on 4/14/13.
//
//

#import "GlobalHelper.h"


@implementation GlobalHelper

+ (void) callAppingtonMainTableViewShown {
    NSDictionary *controlValues = @{
                                    @"event": @"level_start",
                                    @"level": @(2)};  //replace with Dictionary displayed in tableview.
    [GlobalHelper callAppingtonTriggerWithControlValues:controlValues];
}

+ (void) callAppingtonTriggerWithControlValues:(NSDictionary *)controlValues
{
    [Appington control:@"trigger" andValues:controlValues];
    NSLog(@"values sent to Appington %@", controlValues);
}

+ (void) callAppingtonCustomisationTriggerWith:(NSDictionary *)controlValues
{
    [Appington control:@"customization" andValues:controlValues];
    NSLog(@"values sent to Appington %@", controlValues);
}

+ (void) callAppingtonPronouncationTriggerWith:(NSDictionary *)controlValues
{
    [Appington control:@"pronounce" andValues:controlValues];
    NSLog(@"values sent to Appington %@", controlValues);
}

+ (void) callAppingtonInteractionModeTriggerWithModeName:(NSString *)mode_name andWord:(NSString *)word
{
    NSDictionary *controlValues;
    if (word) {
        controlValues = @{
                          @"mode_name": mode_name,
                          @"word": word};
    } else {
        controlValues = @{@"mode_name": mode_name};
    }
    
    [Appington control:@"interaction_mode" andValues:controlValues];
    NSLog(@"values sent to Appington %@", controlValues);
}

+ (void) sendView:(NSString *)viewNameForGA
{
    if(1) {
        id tracker = [GAI sharedInstance].defaultTracker;
        [tracker sendView:viewNameForGA];
        NSLog(@"View sent to GA %@", viewNameForGA);
    }
}

+ (void) trackEventWithCategory:(NSString*)eventCategory withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:eventCategory withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@", eventCategory, action, label);
}

+ (void) trackSettingsEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *category = [NSString stringWithFormat:@"uiAction_Setting"];
    [tracker sendEventWithCategory:category withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@",category, action, label);
}

+ (void) trackCustomisationWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *category = [NSString stringWithFormat:@"uiTracking_Customisations"];
    [tracker sendEventWithCategory:category withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@",category, action, label);
}

+ (void) trackWordEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *category = [NSString stringWithFormat:@"uiAction_Word"];
    [tracker sendEventWithCategory:category withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@ %@",category ,action ,label ,value);
}

//[NSNumber numberWithInt:1]

+ (void) trackFirstTimeUserWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *category = [NSString stringWithFormat:@"uiFirstTimeUser"];
    [tracker sendEventWithCategory:category withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@ %@",category ,action ,label ,value);
}

+ (NSString *)getHexStringForColor:(UIColor *)color {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat r = roundf(red * 255.0);
    CGFloat g = roundf(green * 255.0);
    CGFloat b = roundf(blue * 255.0);
    
    NSString *hexColor = [NSString stringWithFormat:@"%02x%02x%02x", (int)r, (int)g, (int)b];
    
    return hexColor;
}


+ (NSString*) version {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ build %@", version, build];
}

+ (NSString *) deviceType {
    return [UIDevice currentDevice].model;
}


@end
