//
//  DictionaryHelper.h
//  DDPrototype
//
//  Created by Alison Kline on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionarySetupViewController.h"

#define DEFAULT_DICTIONARY_BUNDLE_NAME @"FirstThousandWords"

@class DictionarySetupViewController;

typedef void (^completion_block_t)(UIManagedDocument *dictionaryDatabase);

@protocol ActiveDictionaryFollower <NSObject>

@property (nonatomic, strong) UIManagedDocument *activeDictionary;

@end

@interface DictionaryHelper : NSObject

+ (NSBundle *)defaultDictionaryBundle;      //rename to shippingWithAppDictionaryBundle???
+ (NSURL *)directoryForXMLDictionaryWithName:(NSString *)dictionaryName;
+ (NSURL *)dictionaryDirectory;
+ (NSArray *)currentContentsOfdictionaryDirectory;
+ (BOOL)alreadyHaveDictionaryWithName:(NSString *)dictionaryName;  //will need to be normalised to just check for the UI Managed Doc called activeDictionary
+ (NSString *)dictionaryAlreadyProcessed;
+ (void)openDictionary:(NSString *)dictionaryName               //will need to normalise this to activeDictionary as this is the single UI managed Doc not a dictionary!
  withImDoneDelegate:(id <DictionaryIsReadyViewControllerDelegate>)delegate
               andTriggeringView:(UIViewController *)view
          usingBlock:(completion_block_t)completionBlock;
+ (void)getDefaultDictionaryUsingBlock:(completion_block_t)completionBlock; //Used during development only
+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsIn:(UIViewController *)rootViewController;
+ (void)deleteDictionary:(NSString *)dictionaryName;
+ (void)cleanOutDictionaryDirectory;
+ (void)saveDictionary:(UIManagedDocument *)dictionary
    withImDoneDelegate:(id<DictionaryIsReadyViewControllerDelegate>)delegate
               andTriggerView:(UIViewController *)view;
+ (NSURL *)fileURLForPronunciation:(NSString *)word;
+ (NSString *)dictionaryDisplayNameFrom:(UIManagedDocument *)activeDictionary;
//+ (NSSet *)namesOfDictionariesIn:(UIManagedDocument *)activeDictionary //possibly needed for multi dicts - maybe after force to 1 managed doc called activeDictionary
+ (void)numberOfWordsInCoreDataDocument:(UIManagedDocument *)activeDictionary;
+ (NSString *)stringForState:(UIDocumentState)state;

@end
