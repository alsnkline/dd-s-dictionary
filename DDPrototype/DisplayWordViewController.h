//
//  DisplayWordViewController.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;

@interface DisplayWordViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) Word *word; //word for display the model for this MVC
@property (weak, nonatomic) IBOutlet UILabel *spelling;
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
@property (weak, nonatomic) IBOutlet UIButton *heteronymListenButton;
@property (weak, nonatomic) IBOutlet UIView *wordView;

- (IBAction)listenToWord:(id)sender;
- (void)playAllWords:(NSSet *)pronunciations;

@end
