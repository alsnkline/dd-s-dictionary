//
//  DisplayWordViewController.h
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;
@class DisplayWordViewController;

@protocol DisplayWordViewControllerDelegate <NSObject> //added <NSObject> so we can do a respondsToSelector: on the delegate
@optional

- (void) DisplayWordViewController:(DisplayWordViewController *) sender 
                                homonymSelectedWith:(NSString *)spelling;
@end


@interface DisplayWordViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) Word *word; //word for display the model for this MVC
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic, weak) id <DisplayWordViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *spelling;
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
@property (weak, nonatomic) IBOutlet UIButton *heteronymListenButton;
@property (weak, nonatomic) IBOutlet UIView *wordView;
@property (weak, nonatomic) IBOutlet UIButton *homonymButton1;
@property (weak, nonatomic) IBOutlet UIButton *homonymButton2;
@property (weak, nonatomic) IBOutlet UIButton *homonymButton3;
@property (weak, nonatomic) IBOutlet UIButton *homonymButton4;

- (IBAction)listenToWord:(id)sender;
- (void)playAllWords:(NSSet *)pronunciations;

@end
