//
//  GlobalHelper.m
//  DDPrototype
//
//  Created by Alison KLINE on 4/14/13.
//
//

#import "GlobalHelper.h"
#import "double_metaphone.h"
#import "Word+Create.h"


@implementation GlobalHelper

+ (void) callAppingtonWithTrigger:(NSString *)trigger andValues:(NSDictionary *)controlValues
{
    [Appington control:trigger andValues:controlValues];
    NSLog(@"values sent to Appington %@ %@", trigger, controlValues);
}

+ (void) callAppingtonCustomisationTriggerWith:(NSDictionary *)controlValues
{
    [GlobalHelper callAppingtonWithTrigger:@"customization" andValues:controlValues];
}

+ (void) callAppingtonPronouncationTriggerWith:(NSDictionary *)controlValues
{
    [GlobalHelper callAppingtonWithTrigger:@"pronounce" andValues:controlValues];
}

+ (void) callAppingtonPromptsTriggerWith:(NSDictionary *)controlValues
{
    [GlobalHelper callAppingtonWithTrigger:@"prompts" andValues:controlValues];
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
    
    [GlobalHelper callAppingtonWithTrigger:@"interaction_mode" andValues:controlValues];
}

+ (void) sendView:(NSString *)viewNameForGA
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:viewNameForGA];
    NSLog(@"View sent to GA %@", viewNameForGA);
}

+ (void) trackEventWithCategory:(NSString*)eventCategory withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:eventCategory withAction:action withLabel:label withValue:value];
    NSLog(@"Event sent to GA %@ %@ %@ %@", eventCategory, action, label, value);
}

//[NSNumber numberWithInt:1]

+ (void) trackSettingsEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiAction_Setting"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackCustomisationWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiTracking_Customisations"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackWordEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiAction_Word"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackSearchEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiAction_Search"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackFirstTimeUserWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiTracking_FirstTimeUser"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackAppingtonEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiAction_Appington"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
}

+ (void) trackErrorEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    NSString *category = [NSString stringWithFormat:@"uiAction_Error"];
    [GlobalHelper trackEventWithCategory:category withAction:action withLabel:label withValue:value];
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

+ (NSArray *)doubleMetaphoneCodesFor:(NSString *)spelling
{
    char *primarycode;
    char *secondarycode;
    DoubleMetaphone([spelling UTF8String], &primarycode, &secondarycode);
    if (PROCESS_VERBOSELY) NSLog(@"doubleMetaphone code = %s, %s", primarycode, secondarycode);
    
    NSMutableArray *doubleMetaphoneCodes = [NSMutableArray arrayWithCapacity:2];
 
    [doubleMetaphoneCodes addObject:[NSString stringWithUTF8String:primarycode]];
    
    if(![[NSString stringWithUTF8String:primarycode] isEqualToString:[NSString stringWithUTF8String:secondarycode]])
    {
        if (PROCESS_VERBOSELY) NSLog(@"doubleMetaphoneCodes ARE different %@",doubleMetaphoneCodes);
        [doubleMetaphoneCodes addObject:[NSString stringWithUTF8String:secondarycode]];
    }
    
    return doubleMetaphoneCodes;
}

+ (NSString *)stringForDoubleMetaphoneCodesArray:(NSArray *)doubleMetaphoneCodes
{
    NSString *rtnString;
    if ([doubleMetaphoneCodes count] >1) {
        rtnString = [NSString stringWithFormat:@"%@, %@", [doubleMetaphoneCodes objectAtIndex:0],[doubleMetaphoneCodes objectAtIndex:1]];
    } else {
        rtnString = [NSString stringWithFormat:@"%@", [doubleMetaphoneCodes objectAtIndex:0]];
    }
    return rtnString;
}

+ (NSUInteger) testWordPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    if (LOG_PREDICATE_RESULTS) {
        NSLog(@"number of matches = %d", [matches count]);
        for (Word *word in matches) {
            NSLog(@"found: %@", word.spelling);
        }
    }
    return [matches count];
    
}


@end
