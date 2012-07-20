//
//  DictionarySetupViewController.h
//  DDPrototype
//
//  Created by Alison Kline on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDataXMLDocument;
@class DictionarySetupViewController;

@protocol DictionarySetupViewControllerDelegate <NSObject> //added <NSObject> so we can do a respondsToSelector: on the delegate
@optional
-(void) DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)sender;
@end

@interface DictionarySetupViewController : UIViewController
@property (strong, nonatomic) NSBundle *dictionaryBundle;        //The model for this MVC
@property (nonatomic, weak) id <DictionarySetupViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *progressMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dictionaryName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

+ (void)loadDictionarywithName:(NSString *)dictionaryName passAroundIn:(UIViewController *)rootViewController;

@end
