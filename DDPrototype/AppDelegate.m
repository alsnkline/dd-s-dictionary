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
#import <AudioToolbox/AudioToolbox.h>  //for system sounds
#import <AVFoundation/AVFoundation.h> //for audioPlayer

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if(0) {
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;

    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-37793922-2"];  //use -1 for any production releases
//    [[GAI sharedInstance] trackerWithTrackingId:@""]; //use for developing so counts don't polute

    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"DD's Dictionary launched"];
    [GlobalHelper sendView:viewNameForGA];

    NSSetUncaughtExceptionHandler(nil);
    }
    // Setting up audioSession
    [self setupAudioSession];
    [self setAudioSessionCategoryToPlayback];
    
    // Setting up Appington integration
    [Appington start];
    
//    //Register for Appington notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppingtonEvent:)
                                                 name:nil object:[Appington notificationObject]];
    
    //Call Appington event control
    NSDictionary *controlValues = @{
                              @"event": @"level_start",
                              @"level": @1};  //replace with App launched
    [GlobalHelper callAppingtonTriggerWithControlValues:controlValues];
    NSLog(@"values sent to Appington %@", controlValues);

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
        if(0) {
        //track event with GA
        id tracker = [GAI sharedInstance].defaultTracker;
        NSString *descriptionForNotificationObject = [[notification object] description];
        [tracker sendEventWithCategory:@"uiAction_Appington" withAction:@"audio_end" withLabel:descriptionForNotificationObject withValue:[NSNumber numberWithInt:1]];
        NSLog(@"Event sent to GA uiAction_Appington audio_end %@",descriptionForNotificationObject);
        }
    }
    if ([[notification name] isEqualToString:@"audio_start"])
    {
        if(0) {
        //track event with GA
        id tracker = [GAI sharedInstance].defaultTracker;
        NSString *descriptionForNotificationObject = [[notification object] description];
        [tracker sendEventWithCategory:@"uiAction_Appington" withAction:@"audio_start" withLabel:descriptionForNotificationObject withValue:[NSNumber numberWithInt:1]];
        NSLog(@"Event sent to GA uiAction_Appington audio_start %@",descriptionForNotificationObject);
        }
    }
    if ([[notification name] isEqualToString:@"in_app_purchase"])
    {
        if(0) {
        NSDictionary *values=[notification object];
        NSLog(@"values coming with the notification %@", values);
        NSString *valueForItem = [values objectForKey:@"item"];
        NSLog(@"value for 'item' in notification object %@", valueForItem);
        //        [MyController start_iap_with_item:[values objectForKey:@"item"]];
        }
    }
}


@end
