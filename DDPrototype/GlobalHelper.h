//
//  GlobalHelper.h
//  DDPrototype
//
//  Created by Alison KLINE on 4/14/13.
//
//

#import <Foundation/Foundation.h>

@interface GlobalHelper : NSObject

+ (void) callAppingtonMainTableViewShown;
+ (void) callAppingtonTriggerWithControlValues:(NSDictionary *)controlValues;
+ (void) callAppingtonCustomisationTriggerWith:(NSDictionary *)controlValues;
+ (void) callAppingtonPronouncationTriggerWith:(NSDictionary *)controlValues;
+ (void) callAppingtonInteractionModeTriggerWithModeName:(NSString *)mode_name andWord:(NSString *)word;

+ (void) sendView:(NSString *)viewNameForGA;
+ (void) trackEventWithCategory:(NSString*)eventCategory withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackSettingsEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackCustomisationWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackWordEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackFirstTimeUserWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (NSString *)getHexStringForColor:(UIColor *)color;

+ (NSString*) version;
+ (NSString *) deviceType;


@end
