//
//  GlobalHelper.h
//  DDPrototype
//
//  Created by Alison KLINE on 4/14/13.
//
//

#import <Foundation/Foundation.h>

#define PROCESS_VERBOSELY NO
#define LOG_PREDICATE_RESULTS YES  // must be NO for ship

//    NSLog(@"********************************");
//    NSLog(@" set OVERRIDE_PROCESSING to NO");
//    NSLog(@"       Before Ship");
//    NSLog(@"*********************************");

//****** set to NO before ship *******
#define OVERRIDE_PROCESSING NO      // must be NO for ship
#define FORCE_REPROCESS NO          //used for testing to force dictionary reprocess
#define FAKE_NEW_VERSION NO        //used for testing to force dictionary correction check

#define TEST_APPINGTON_ON NO       // must be NO for ship



@interface GlobalHelper : NSObject

+ (void) callAppingtonWithTrigger:(NSString *)trigger andValues:(NSDictionary *)controlValues;
+ (void) callAppingtonCustomisationTriggerWith:(NSDictionary *)controlValues;
+ (void) callAppingtonPronouncationTriggerWith:(NSDictionary *)controlValues;
+ (void) callAppingtonPromptsTriggerWith:(NSDictionary *)controlValues;
+ (void) callAppingtonInteractionModeTriggerWithModeName:(NSString *)mode_name andWord:(NSString *)word;

+ (void) sendView:(NSString *)viewNameForGA;
+ (void) trackEventWithCategory:(NSString*)eventCategory withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackSettingsEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackCustomisationWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackWordEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackSearchEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackFirstTimeUserWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackAppingtonEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;
+ (void) trackErrorEventWithAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;


+ (NSString *)getHexStringForColor:(UIColor *)color;
+ (NSString*) version;
+ (NSString *) deviceType;

+ (NSArray *)doubleMetaphoneCodesFor:(NSString *)spelling;
+ (NSString *)stringForDoubleMetaphoneCodesArray:(NSArray *)doubleMetaphoneCodes;
+ (NSUInteger) testWordPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;


@end
