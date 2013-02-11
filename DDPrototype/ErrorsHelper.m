//
//  ErrorsHelper.m
//  DDPrototype
//
//  Created by Alison KLINE on 2/10/13.
//
//

#import "ErrorsHelper.h"
#import "GAI.h"

@implementation ErrorsHelper

+ (void) showExplanationForFrozenUI     //used during app development superceeded by setupTableSwitchedViewController.
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing"
                                                        message:[NSString stringWithFormat:@"Please wait while we build your dictionary for the first time."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
    
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Error" withAction:@"processing" withLabel:@"frozenUIWarning" withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Error processing frozenUIWarning");
}

+ (void) showErrorTooManyDictionaries     //used in SetupTableSwitchViewController and DictionaryTableViewController
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing problem"
                                                        message:[NSString stringWithFormat:@"Sorry, you have too many dictionaries processed."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
    
    
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Error" withAction:@"processing" withLabel:@"tooManyDictionaries" withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Error processing tooManyDictionaries");
}

+ (void) showErrorMuteOn
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Sound is muted"
                                                        message:[NSString stringWithFormat:@"Please set your volumn so you can hear."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
    
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Error" withAction:@"listening" withLabel:@"muteOn" withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Error listening muteOn");

}

+ (void) showXMLParsingError:(NSError *)error
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary XML parsing"
                                                        message:[NSString stringWithFormat:@"It seems we can't read your XML Dictionary. Please confirm it conforms to the expected xml format (%@)", error]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
    
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Error" withAction:@"processing" withLabel:@"XMLproblem" withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Error processing XMLproblem");
    
}



@end
