//
//  SetupOrMainViewController.h
//  DDPrototype
//
//  Created by Alison KLINE on 2/9/13.
//
//

#import <UIKit/UIKit.h>
#import "DictionaryHelper.h"

@class DictionarySetupViewController;

@interface SetupOrMainViewController : UIViewController <ActiveDictionaryFollower>

@property (strong, nonatomic) DictionarySetupViewController *setupViewController;

@end
