//
//  FilteredDictionaryTableViewController.h
//  DDPrototype
//
//  Created by Alison KLINE on 5/13/13.
//
//

#import "CoreDataTableViewController.h"
#import "DictionaryHelper.h"

@interface FilteredDictionaryTableViewController : CoreDataTableViewController <ActiveDictionaryFollower>

@property (nonatomic, strong) NSPredicate *filterPredicate;

@end
