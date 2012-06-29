//
//  DictionaryHelper.h
//  DDPrototype
//
//  Created by Alison Kline on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *dictionaryDatabase);

@protocol ActiveDictionaryFollower <NSObject>

@property (nonatomic, strong) UIManagedDocument *activeDictionary;

@end

@interface DictionaryHelper : NSObject

+ (NSURL *)dictionaryDirectory;
+ (void)openDictionary:(NSString *)dictionaryName
          usingBlock:(completion_block_t)completionBlock;
+ (void)getDefaultDictionaryUsingBlock:(completion_block_t)completionBlock;
+ (void)passActiveDictionary:(UIManagedDocument *)activeDictionary arroundVCsIn:(UIViewController *)rootViewController;
+ (void)deleteDictionary:(NSString *)dictionaryName;

@end
