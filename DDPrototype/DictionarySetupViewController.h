//
//  DictionarySetupViewController.h
//  DDPrototype
//
//  Created by Alison Kline on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNodeHelper.h"

@class GDataXMLDocument;
@class DictionarySetupViewController;

typedef enum DocProcessType {DOC_PROCESS_REPROCESS, DOC_PROCESS_CHECK_FOR_CORRECTIONS, DOC_PROCESS_USE_EXSISTING} DocProcessType;

@protocol DictionaryIsReadyViewControllerDelegate <NSObject> //added <NSObject> so we can do a respondsToSelector: on the delegate
@optional
-(void) dictionaryIsReady:(UIViewController *)sender;
@end

@interface DictionarySetupViewController : UIViewController
@property (nonatomic) BOOL processing;
@property (nonatomic) BOOL correctionsOnly;
@property (strong, nonatomic) NSBundle *dictionaryBundle;        //The model for this MVC
@property (strong, nonatomic) GDataXMLDocument *dictionaryXMLdoc;
@property (strong, nonatomic) GDataXMLDocument *correctionsXMLdoc;
@property (strong, nonatomic) NSMutableArray *XMLdocsForProcessing;
@property (strong, nonatomic) UIViewController *rootViewControllerForPassingProcessedDictionaryAround;
@property (nonatomic, weak) id <DictionaryIsReadyViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *dictionaryName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

+ (void)loadDictionarywithName:(NSString *)dictionaryName
                  passAroundIn:(UIViewController *)rootViewController
            withImDoneDelegate:(id<DictionaryIsReadyViewControllerDelegate>)delegate
                       andTriggerView:(UIViewController*)dsvc;
+ (BOOL) use:(DictionarySetupViewController *)dsvc
   toProcess:(NSBundle *)dictionary
passDictionaryAround:(UIViewController *)rootViewController
 setDelegate:(id <DictionaryIsReadyViewControllerDelegate>)delegate
correctionsOnly:(BOOL)corrections;
- (void)processDoc:(GDataXMLDocument *)XMLdoc type:(XMLdocType)docType;
+ (NSString *) whatProcessingIsNeeded:(DocProcessType *)docProcessType;
+ (NSString *) stringForLog:(DocProcessType)docProcessType;
+ (BOOL) newVersion;
+ (void) setProcessedDictionaryAppVersion;
+ (BOOL) forceReprocessDictionary;
+ (void) setProcessedDictionarySchemaVersion;


@end
