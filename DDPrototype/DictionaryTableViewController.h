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
#import "DictionarySetupViewController.h"

@interface DictionaryTableViewController : CoreDataTableViewController <ActiveDictionaryFollower, DictionarySetupViewControllerDelegate>

//use activeDictionary for model for this MVC
@property (nonatomic) BOOL isFTU;


@end
