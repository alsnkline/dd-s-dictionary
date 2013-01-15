//
//  SetupTableSwitchViewController.h
//  DDPrototype
//
//  Created by Alison KLINE on 1/12/13.
//
//

#import <UIKit/UIKit.h>
#import "DictionaryHelper.h"

@class DictionarySetupViewController;

@interface SetupTableSwitchViewController : UIViewController <ActiveDictionaryFollower>

@property (strong, nonatomic) DictionarySetupViewController *setupViewController;


@end
