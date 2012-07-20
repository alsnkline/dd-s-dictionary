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

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    //see if there are any dictionary's
//    NSArray *dictionariesAvailable = [DictionaryHelper currentContentsOfdictionaryDirectory];
//    NSLog(@"dictionariesAvailable = %@", dictionariesAvailable);
//    if ([dictionariesAvailable count] == 1) {
//        NSURL *dictionaryURL = [dictionariesAvailable lastObject];
//        NSString *activeDictionaryName = [dictionaryURL lastPathComponent];
//        NSLog(@"Opening the 1 dicitonary available its name: %@", activeDictionaryName);
//        [self loadDictionarywithName:activeDictionaryName createFromXML:nil];
//    } else {
//        //Get scource file for words to populate dictionary -
//        NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
//
//        NSError *error = nil;
//        GDataXMLDocument *XMLdoc = [GDataXMLNodeHelper loadDictionaryFromXMLInDictionaryBundle:dictionaryShippingWithApp Error:&error];
//        // GDataXMLDocument *doc = [GDataXMLNodeHelper loadDictionaryFromXMLError:&error];
//
//        if (error) {
//            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary XML parsing" 
//                                                                message:[NSString stringWithFormat:@"It seems we can't read your XML Dictionary. Please confirm it conforms to the expected xml format (%@)", error] 
//                                                               delegate:self cancelButtonTitle:@"OK" 
//                                                      otherButtonTitles:nil];
//            NSLog(@"error %@ %@",error, [error userInfo]);
//            [alertUser sizeToFit];
//            [alertUser show];
//        }
//        if (XMLdoc) {
//            [self showExplanationForFrozenUI];
//            
//            NSString *dictionaryName = [GDataXMLNodeHelper dictionaryNameFor:@"bundleName" FromXMLDoc:XMLdoc];
//            
//            //Get UIManagedDocument for dictionary
//            [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase) {
//                NSLog(@"Got dictionary %@", [dictionaryDatabase.fileURL lastPathComponent]);
//                
//                //process file to populate UIManagedDocument - need to add way to force reanalysis for changes
//                [GDataXMLNodeHelper processXMLfile:XMLdoc intoManagedObjectContext:dictionaryDatabase.managedObjectContext];
//                
//                //share activeDictionary with all VC's
//                [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:self.window.rootViewController];
//            }];
//        }
//
//    }
    return YES;
}
    
//- (void)loadDictionarywithName:(NSString *)dictionaryName createFromXML:(GDataXMLDocument *)XMLdoc
//{
//    [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase) {
//        
//        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
//        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
//            
//            if (XMLdoc) {
//                
//                //process file to populate and save the UIManagedDocument
//                [GDataXMLNodeHelper processXMLfile:XMLdoc intoManagedObjectContext:dictionaryDatabase.managedObjectContext];
//                [DictionaryHelper numberOfWordsInCoreDataDocument:dictionaryDatabase];
//            }
//            
//            //share activeDictionary with all VC's
//            [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:self.window.rootViewController];
//            
//        } else {
//            NSLog(@"dictionary documentState NOT normal");
//        }
//    }];
//}
//
//- (void) showExplanationForFrozenUI
//{
//    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing" 
//                                                        message:[NSString stringWithFormat:@"Please wait while we build your dictionary for the first time."] 
//                                                       delegate:self cancelButtonTitle:@"OK" 
//                                              otherButtonTitles:nil];
//    [alertUser sizeToFit];
//    [alertUser show];
//}
							
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

@end
