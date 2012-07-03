//
//  DictionaryHelper.m
//  DDPrototype
//
//  Created by Alison Kline on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictionaryHelper.h"
#import "Word+Create.h"
#import "GDataXMLNode.h"

@implementation DictionaryHelper

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

+ (void)openDictionary:(NSString *)dictionaryName 
            usingBlock:(completion_block_t)completionBlock
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSURL *thisDictionaryUrl = [self dictionaryURLFor:dictionaryName];
    
    UIManagedDocument *dictionaryDatabase = [[UIManagedDocument alloc] initWithFileURL:thisDictionaryUrl];
    
    if (![localFileManager fileExistsAtPath:[dictionaryDatabase.fileURL path]]) {
        [dictionaryDatabase saveToURL:dictionaryDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success){
                completionBlock (dictionaryDatabase); 
                NSLog(@"Dictionary UIManagedDoc created");
            } else {
                NSLog(@"failed to saveForCreating %@", [dictionaryDatabase.fileURL lastPathComponent]);
            }
        }];
    } else if (dictionaryDatabase.documentState == UIDocumentStateClosed) {
        [dictionaryDatabase openWithCompletionHandler:^(BOOL success) {
            if (success){
                completionBlock (dictionaryDatabase); 
                NSLog(@"Dictionary UIManagedDoc opened");
            } else {
                NSLog(@"failed to open %@", [dictionaryDatabase.fileURL lastPathComponent]);
            }
        }];
    } else if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
        completionBlock (dictionaryDatabase);
        NSLog(@"Dictionary already ready to go");
    }
}

+ (void)getDefaultDictionaryUsingBlock:(completion_block_t)completionBlock
{
    [DictionaryHelper openDictionary:@"defaultDictionary" usingBlock:completionBlock];
}

+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsIn:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UISplitViewController class]]) { //for ipad get the splitview master's tabBarController
        UISplitViewController *svc = (UISplitViewController *)rootViewController;
        UIViewController *masterVC = [svc.viewControllers objectAtIndex:0];
        
        if ([masterVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *masterNVC = (UINavigationController *)masterVC;
            [self passActiveDictionary:activeDictionary arroundNavBarVCs:masterNVC.viewControllers];
        }

        UIViewController *detailVC = [svc.viewControllers lastObject];
        if ([detailVC conformsToProtocol:@protocol(ActiveDictionaryFollower)]) {
            id <ActiveDictionaryFollower> avc = (id <ActiveDictionaryFollower>)detailVC;
            avc.activeDictionary = activeDictionary;
        }
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]){
        //for iphone 
    }
    NSLog(@"Passed activeDictionary rootVC's vc's %@", activeDictionary.fileURL.lastPathComponent);
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

+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundNavBarVCs:(NSArray *)navViewControllers
{
    for (UIViewController * vc in navViewControllers) {
        
        if ([vc conformsToProtocol:@protocol(ActiveDictionaryFollower)]) {
            id <ActiveDictionaryFollower> avc = (id <ActiveDictionaryFollower>)vc;
            avc.activeDictionary = activeDictionary;
        }
    }
}

+ (NSURL *)fileURLForPronunciation:(NSString *)word
{
    NSString *pathForSoundName = [NSString pathWithComponents:[NSArray arrayWithObjects:@"resources.bundle",@"Sounds",word, nil]];
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


@end
