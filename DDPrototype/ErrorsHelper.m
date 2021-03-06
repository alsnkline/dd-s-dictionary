//
//  ErrorsHelper.m
//  DDPrototype
//
//  Created by Alison KLINE on 2/10/13.
//
//

#import "ErrorsHelper.h"

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
    [GlobalHelper trackErrorEventWithAction:@"processing" withLabel:@"frozenUIWarning" withValue:[NSNumber numberWithInt:1]];

}

+ (void) showErrorTooManyDictionaries     //used in DictionaryTableViewController
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing problem"
                                                        message:[NSString stringWithFormat:@"Sorry, you have too many dictionaries processed."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];

    //track event with GA
    [GlobalHelper trackErrorEventWithAction:@"processing" withLabel:@"tooManyDictionaries" withValue:[NSNumber numberWithInt:1]];

}


+ (void) showErrorMuteOn //not used the right way to avoid this need is to initialize an audio session, make it active and set its category to AVAudioSessionCategoryPlayback
// http://stackoverflow.com/questions/10180500/how-to-use-kaudiosessionproperty-overridecategorymixwithothers
// https://developer.apple.com/library/ios/#documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Configuration/Configuration.html
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Sound is muted"
                                                        message:[NSString stringWithFormat:@"Please set your volumn so you can hear."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];

    //track event with GA
    [GlobalHelper trackErrorEventWithAction:@"listening" withLabel:@"muteOn" withValue:[NSNumber numberWithInt:1]];

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
    [GlobalHelper trackErrorEventWithAction:@"processing" withLabel:@"XMLproblem" withValue:[NSNumber numberWithInt:1]];
}



@end
