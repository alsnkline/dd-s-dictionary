//
//  DictionaryTableViewController.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "DictionaryHelper.h"

@interface DictionaryTableViewController : CoreDataTableViewController <ActiveDictionaryFollower>

//use activeDictionary for model for this MVC
@property (nonatomic, strong) NSArray *firstLetterList; //array of first letters NSString in words in dictionary, in alphabetical order part of Model
@property (nonatomic, strong) NSDictionary *wordsByLetter; //keys: letter NSString, values NSArray of words Word (Word.Spelling?) part of Model


@end
