//
//  DictionaryHelper.m
//  DDPrototype
//
//  Created by Alison Kline on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictionaryHelper.h"
#import "Dictionary+Create.h"
#import "GDataXMLNode.h"
#import "DictionarySetupViewController.h"
#import "ErrorsHelper.h"
#import "ActiveDictionary.h"

@implementation DictionaryHelper

+ (NSBundle *)defaultDictionaryBundle       //leaving naming as default rather than change it to DictionaryShippingWithAPPBundleName or similar.
{
    NSString *pathForDictionaryBundle = [[NSBundle mainBundle] pathForResource:DEFAULT_DICTIONARY_BUNDLE_NAME ofType:@"bundle"];
    NSBundle *dictionaryBundle = [NSBundle bundleWithPath:pathForDictionaryBundle];
    return dictionaryBundle;
}

+ (NSURL *)directoryForXMLDictionaryWithName:(NSString *)dictionaryName
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *baseUrl = [[localFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *directoryName = dictionaryName;
    NSURL *dirUrl = [baseUrl URLByAppendingPathComponent:directoryName];
    
    BOOL isDir = NO;
    [localFileManager fileExistsAtPath:[dirUrl path] isDirectory:&isDir];
    
    if (!isDir ) {
        NSError *error = nil;
        [localFileManager createDirectoryAtPath:[dirUrl path] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"something went wrong with dirCreate = %@", error);
        }
    }
    return dirUrl;
}


+ (NSURL *)dictionaryDirectory      //for Core Data UIManagedDocument
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *baseUrl = [[localFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *directoryName = @"dictionaries";
    NSURL *dirUrl = [baseUrl URLByAppendingPathComponent:directoryName];
    
    BOOL isDir = NO;
    [localFileManager fileExistsAtPath:[dirUrl path] isDirectory:&isDir];
    
    if (!isDir ) {
        NSError *error = nil;
        [localFileManager createDirectoryAtPath:[dirUrl path] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"something went wrong with dirCreate = %@", error);
        }
    }
    return dirUrl;
}

+ (NSArray *)currentContentsOfdictionaryDirectory
{
    NSError *error = nil;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *dictionaryDirectoryURL = [DictionaryHelper dictionaryDirectory];
    NSArray *currentDictionaryDirectory = [localFileManager contentsOfDirectoryAtURL:dictionaryDirectoryURL includingPropertiesForKeys:nil options: NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    //    NSLog(@"currentCache = %@",currentCache);
    
    if (!error) {
        return currentDictionaryDirectory;
    } else {
        NSLog(@"error getting contentsOfDirectoryAtPath = %@",error);
        return nil;
    }
}

+ (NSURL *)dictionaryURLFor:(NSString *)dictionaryName
{
    NSURL *dirURL = [self dictionaryDirectory];
    NSURL *thisDictionaryUrl = [dirURL URLByAppendingPathComponent:dictionaryName];
    NSLog(@"This core data dictionary url = %@", thisDictionaryUrl);
    return thisDictionaryUrl;
}


+ (BOOL)alreadyHaveDictionaryWithName:(NSString *)dictionaryName
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *thisDictionaryURL = [self dictionaryURLFor:dictionaryName];    
    BOOL isAlreadyPresent = [localFileManager fileExistsAtPath:[thisDictionaryURL path]];
    return isAlreadyPresent;
}

+ (NSString *)dictionaryAlreadyProcessed //introduced to test for processing dictionary.
{
    NSString *processedDictionaryName = nil;
    
    NSArray *dictionariesAvailable = [DictionaryHelper currentContentsOfdictionaryDirectory];
    NSLog(@"dictionariesAvailable = %@", dictionariesAvailable);
    
    if ([dictionariesAvailable count] == 1) {
        NSURL *dictionaryURL = [dictionariesAvailable lastObject];
        processedDictionaryName = [dictionaryURL lastPathComponent];
    } else if ([dictionariesAvailable count] > 1) {
        NSLog(@"more than one processed dictionary");
        [ErrorsHelper showErrorTooManyDictionaries];
        [DictionaryHelper cleanOutDictionaryDirectory];
    }
    return processedDictionaryName;
}


+ (void)openDictionary:(NSString *)dictionaryName
    withImDoneDelegate:(id<DictionarySetupViewControllerDelegate>)delegate
               andDsvc:(DictionarySetupViewController *)dsvc
            usingBlock:(completion_block_t)completionBlock
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *thisDictionaryUrl = [self dictionaryURLFor:dictionaryName];
    
//    UIManagedDocument *dictionaryDatabase = [[UIManagedDocument alloc] initWithFileURL:thisDictionaryUrl];
    ActiveDictionary *dictionaryDatabase = [[ActiveDictionary alloc] initWithFileURL:thisDictionaryUrl];
    
    if (![localFileManager fileExistsAtPath:[dictionaryDatabase.fileURL path]]) {
        [dictionaryDatabase saveToURL:dictionaryDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success){
                NSLog(@"Dictionary UIManagedDoc created");
                completionBlock (dictionaryDatabase); 
                [DictionaryHelper saveDictionary:dictionaryDatabase withImDoneDelegate:delegate andDsvc:dsvc]; //- was only place saving seemed to work - I wonder if auto save would work just as well?
 //               [delegate DictionarySetupViewDidCompleteProcessingDictionary:dsvc]; - didn't work because savedDictionary is also async!
                
            } else {
                NSLog(@"failed to saveForCreating %@", [dictionaryDatabase.fileURL lastPathComponent]);
            }
        }];
    } else if (dictionaryDatabase.documentState == UIDocumentStateClosed) {
        [dictionaryDatabase openWithCompletionHandler:^(BOOL success) {
            if (success){
                NSLog(@"Dictionary UIManagedDoc opened");
                completionBlock (dictionaryDatabase); 
                [DictionaryHelper saveDictionary:dictionaryDatabase withImDoneDelegate:delegate andDsvc:dsvc]; //to save after processing corrections have to use a full save as in iPhone the fetchResultsController is not set up and will miss the changes.
//                [delegate DictionarySetupViewDidCompleteProcessingDictionary:dsvc];  //needed to clean up processing dsvc view if you use auto save rather than explicit save (see commented out line above) - works for iPad but not iPhone
//                [dictionaryDatabase updateChangeCount:UIDocumentChangeDone]; //doesn't trigger dsvc to be removed, but triggers autosave in background thread works for iPad as FRC is already watching.
            } else {
                NSLog(@"failed to open %@", [dictionaryDatabase.fileURL lastPathComponent]);
            }
        }];
    } else if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
        completionBlock (dictionaryDatabase);
        NSLog(@"Dictionary already ready to go");
    }
}

+ (void)getDefaultDictionaryUsingBlock:(completion_block_t)completionBlock  //used during development only commented out when cleaning up async timing issues.
{
//    [DictionaryHelper openDictionary:@"defaultDictionary" usingBlock:completionBlock];

}

+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsIn:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UISplitViewController class]]) { //for ipad get the splitview master's ViewController
        NSLog(@"We have a SV controller (master)");
        UISplitViewController *svc = (UISplitViewController *)rootViewController;
        UIViewController *masterVC = [svc.viewControllers objectAtIndex:0];
        
        [self passActiveDictionary:activeDictionary arroundVCsInControllerOfControllers:masterVC];

        UIViewController *detailVC = [svc.viewControllers lastObject];
        NSLog(@"We have a SV controller (detail)");
        if ([detailVC conformsToProtocol:@protocol(ActiveDictionaryFollower)]) {
            id <ActiveDictionaryFollower> avc = (id <ActiveDictionaryFollower>)detailVC;
            avc.activeDictionary = activeDictionary;
        }
        
    } else {
        //for iphone
        [self passActiveDictionary:activeDictionary arroundVCsInControllerOfControllers:rootViewController];
    }
    NSLog(@"Passed activeDictionary rootVC's vc's %@", activeDictionary.fileURL.lastPathComponent);
    }


+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsInControllerOfControllers:(UIViewController *)viewController
{
    NSLog(@"viewController passed in for passing around %@", viewController);
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        NSLog(@"We have a nav controller");
        UINavigationController *NVC = (UINavigationController *)viewController;
        [self passActiveDictionary:activeDictionary arroundNavBarVCs:NVC.viewControllers];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        NSLog(@"We have a tab bar controller");
        UITabBarController *TBVC = (UITabBarController *)viewController;
        [self passActiveDictionary:activeDictionary arroundTabBarVCs:TBVC.viewControllers];
    }
}


+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundTabBarVCs:(NSArray *)tabBarViewControllers
{
    for (UIViewController *atvc in tabBarViewControllers) {
        
        if ([atvc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *anvc = (UINavigationController *)atvc;
            [self passActiveDictionary:activeDictionary arroundNavBarVCs:anvc.viewControllers];
        }
    }
}

+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundNavBarVCs:(NSArray *)navViewControllers
{
    for (UIViewController * vc in navViewControllers) {
        
        if ([vc conformsToProtocol:@protocol(ActiveDictionaryFollower)]) {
            id <ActiveDictionaryFollower> avc = (id <ActiveDictionaryFollower>)vc;
            avc.activeDictionary = activeDictionary;
        }
    }
}

+ (void)deleteDictionary:(NSString *)dictionaryName
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *dirURL = [self dictionaryDirectory];
    NSURL *thisDictionaryUrl = [dirURL URLByAppendingPathComponent:dictionaryName];
    NSLog(@"This dictionary url = %@", thisDictionaryUrl);
    
    if ([localFileManager fileExistsAtPath:[thisDictionaryUrl path]]) {
        NSError *error = nil;
        [localFileManager removeItemAtURL:thisDictionaryUrl error:&error];
    } else {
        NSLog(@"No dictionary of that name here!");
    }
    
}

+ (void)cleanOutDictionaryDirectory
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSArray *dictionariesAvailable = [DictionaryHelper currentContentsOfdictionaryDirectory];
    for (NSURL *url in dictionariesAvailable) {
        NSError *error = nil;
        [localFileManager removeItemAtURL:url error:&error];
        NSLog(@"Deleted dictionary at %@", url);
    }
    NSLog(@"Deleted ALL dictionaries");
}

+ (void)saveDictionary:(UIManagedDocument *)dictionary
    withImDoneDelegate:(id<DictionarySetupViewControllerDelegate>)delegate
               andDsvc:(DictionarySetupViewController *)dsvc
{
    [dictionary saveToURL:dictionary.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^ (BOOL success) {
        if (success) {
            NSLog(@"Saved Dictionary URL = %@ doc state = %@", [dictionary.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionary.documentState]);
            [delegate DictionarySetupViewDidCompleteProcessingDictionary:dsvc];
        } else {
            NSLog(@"Save failed URL = %@ doc state = %@", [dictionary.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionary.documentState]);
        };
    }];
}


+ (NSURL *)fileURLForPronunciation:(NSString *)word
{
    NSString *pathComponentForBundle = [NSString stringWithFormat:@"%@.bundle",DEFAULT_DICTIONARY_BUNDLE_NAME];
    NSString *pathForSoundName = [NSString pathWithComponents:[NSArray arrayWithObjects:pathComponentForBundle,@"Sounds",word, nil]];
    NSLog(@"current word = %@", word);
    NSLog(@"pathForSoundName = %@",pathForSoundName);
    NSString *soundName = [[NSBundle mainBundle] pathForResource:pathForSoundName ofType:@"m4a"];
    NSLog(@"soundName = %@", soundName);
    
//    NSArray *m4pFiles = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"" subdirectory:@"resources.bundle/Sounds"];
//    NSLog(@"m4pFiles in mainBundle = %@", m4pFiles);
    
    
    NSURL *fileURL;
    if (soundName) {
        fileURL = [[NSURL alloc] initFileURLWithPath:soundName];
    }
    NSLog(@"fileURL = %@", fileURL);
    
    // Get the paths and URL's right!
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    BOOL fileFound = [localFileManager fileExistsAtPath:[fileURL path]];
    NSLog(@"fileFound for URL: %@", fileFound ? @"YES" : @"NO");
    
    if (fileFound) {
        return fileURL;
    } else {
        return nil;
    }
}

+ (NSString *)dictionaryDisplayNameFrom:(UIManagedDocument *)activeDictionary
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dictionary"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [activeDictionary.managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *displayName = nil;
    if ([matches count] == 1) {
        Dictionary *dictionary = [matches lastObject];
        displayName = dictionary.displayName;
    }
    return displayName;
}

+ (void)numberOfWordsInCoreDataDocument:(UIManagedDocument *)activeDictionary
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    NSError *error = nil;
    NSArray *results = [activeDictionary.managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"%i words in your Dictionary", [results count]);
    
}

+ (NSString *)stringForState:(UIDocumentState)state 
{ 
    NSMutableArray *states = [NSMutableArray array]; 
    if (state == 0) { 
        [states addObject:@"Normal"]; 
    } if (state & UIDocumentStateClosed) { 
        [states addObject:@"Closed"]; 
    } if (state & UIDocumentStateInConflict) { 
        [states addObject:@"In Conflict"]; 
    } if (state & UIDocumentStateSavingError) { 
        [states addObject:@"Saving error"]; 
    } if (state & UIDocumentStateEditingDisabled) { 
        [states addObject:@"Editing disabled"]; 
    } 
    return [states componentsJoinedByString:@", "]; 
}   
// Example use: NSLog(@"Loaded File URL: %@, State: %@, Last Modified: %@", [doc.fileURL lastPathComponent], [self stringForState:state], version.modificationDate.mediumString);



@end
