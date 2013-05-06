//
//  AppDelegate.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "DictionaryHelper.h"
#import "GDataXMLNodeHelper.h"
#import "GDataXMLNode.h"
#import "Word+Create.h"
#import "DictionarySetupViewController.h"
#import "NSUserDefaultKeys.h"
#import <AudioToolbox/AudioToolbox.h>  //for system sounds
#import <AVFoundation/AVFoundation.h> //for audioPlayer

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;

    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-37793922-2"];  //use -1 for any production releases
//    [[GAI sharedInstance] trackerWithTrackingId:@""]; //use for developing so counts don't polute

    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"DD's Dictionary launched"];
    [GlobalHelper sendView:viewNameForGA];

    NSSetUncaughtExceptionHandler(nil);
    
    // Setting up audioSession
    [self setupAudioSession];
    [self setAudioSessionCategoryToPlayback];
    
    // Setting up Appington integration
    [Appington start];
    
    //Register for Appington notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppingtonEvent:)
                                                 name:nil object:[Appington notificationObject]];
    return YES;
}

-(void)setupAudioSession
{
    //setting up the AVAudioSession and activating it.
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        NSLog(@"AVAudioSession not setup %@", activationError);
    }
}

-(void)setAudioSessionCategoryToPlayback
{
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) {
        NSLog(@"AVAudioSessionCategory not set %@", setCategoryError);
    }
}

    							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) onAppingtonEvent:(NSNotification*)notification
{
    //NSLog(@"Appington NR: %@", [notification name]);
    NSLog(@"%@",notification);
    if ([[notification name] isEqualToString:@"audio_end"])
    {
        //track event with GA
        NSString *descriptionForNotificationObject = [[notification object] description];
        [GlobalHelper trackAppingtonEventWithAction:@"audio_end"  withLabel:descriptionForNotificationObject withValue:[NSNumber numberWithInt:1]];

    }
    if ([[notification name] isEqualToString:@"audio_start"])
    {
        //track event with GA
        NSString *descriptionForNotificationObject = [[notification object] description];
        [GlobalHelper trackAppingtonEventWithAction:@"audio_start" withLabel:descriptionForNotificationObject withValue:[NSNumber numberWithInt:1]];
    }
    if ([[notification name] isEqualToString:@"prompts"])
    {
        NSDictionary *values=notification.userInfo;
        //NSLog(@"values coming with the notification %@", values);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        BOOL vForChangeable = [[values objectForKey:@"changeable"] boolValue];
        NSLog(@"value for 'changeable' in notification object %@", [values objectForKey:@"changeable"]);
        [defaults setBool:vForChangeable forKey:VOICE_HINT_AVAILABLE];
        
        
        BOOL vForEnabled = [[values objectForKey:@"enabled"] boolValue]; //could be used to control switch setting, currently just testing for similarity.
        NSLog(@"value for 'enable' in notification object %@", [values objectForKey:@"enabled"]);
        [defaults setBool:!vForEnabled forKey:NOT_USE_VOICE_HINTS];
        //inverting switch logic to get default behavior to be ON (although appington is controlling that, so I don't have to tell them about a default setting. Could revert to USE_VOICE_HINTS !

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@end
