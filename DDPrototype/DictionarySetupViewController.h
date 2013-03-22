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
@property (nonatomic) BOOL processing;
@property (nonatomic) BOOL correctionsOnly;
@property (strong, nonatomic) NSBundle *dictionaryBundle;        //The model for this MVC
@property (strong, nonatomic) GDataXMLDocument *dictionaryXMLdoc;
@property (strong, nonatomic) GDataXMLDocument *correctionsXMLdoc;
@property (strong, nonatomic) UIViewController *rootViewControllerForPassingProcessedDictionaryAround;
@property (nonatomic, weak) id <DictionarySetupViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *dictionaryName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

+ (void)loadDictionarywithName:(NSString *)dictionaryName passAroundIn:(UIViewController *)rootViewController;
+ (NSString *)dictionaryAlreadyProcessed;
+ (BOOL) use:(DictionarySetupViewController *)dsvc
   toProcess:(NSBundle *)dictionary
passDictionaryAround:(UIViewController *)rootViewController
 setDelegate:(id <DictionarySetupViewControllerDelegate>)delegate
correctionsOnly:(BOOL)corrections;
+ (BOOL) newVersion;
+ (BOOL) forceReprocessDictionary;
+ (void) processedDictionaryVersion;


@end
