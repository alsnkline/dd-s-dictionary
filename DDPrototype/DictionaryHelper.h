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

+ (NSBundle *)defaultDictionaryBundle;
+ (NSURL *)directoryForXMLDictionaryWithName:(NSString *)dictionaryName;
+ (NSURL *)dictionaryDirectory;
+ (NSArray *)currentContentsOfdictionaryDirectory;
+ (BOOL)alreadyHaveDictionaryWithName:(NSString *)dictionaryName;
+ (void)openDictionary:(NSString *)dictionaryName
  withImDoneDelegate:(id <DictionarySetupViewControllerDelegate>)delegate
               andDsvc:(DictionarySetupViewController *)dsvc
          usingBlock:(completion_block_t)completionBlock;
+ (void)getDefaultDictionaryUsingBlock:(completion_block_t)completionBlock; //Used during development only
+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsIn:(UIViewController *)rootViewController;
+ (void)deleteDictionary:(NSString *)dictionaryName;
+ (void)saveDictionary:(UIManagedDocument *)dictionary
    withImDoneDelegate:(id<DictionarySetupViewControllerDelegate>)delegate
               andDsvc:(DictionarySetupViewController *)dsvc;
+ (NSURL *)fileURLForPronunciation:(NSString *)word;
+ (NSString *)dictionaryDisplayNameFrom:(UIManagedDocument *)activeDictionary;
+ (void)numberOfWordsInCoreDataDocument:(UIManagedDocument *)activeDictionary;
+ (NSString *)stringForState:(UIDocumentState)state;

@end
