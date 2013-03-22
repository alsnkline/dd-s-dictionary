//
//  DictionarySetupViewController.m
//  DDPrototype
//
//  Created by Alison Kline on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictionarySetupViewController.h"
#import "DictionaryHelper.h"
#import "GDataXMLNodeHelper.h"
#import "GAI.h"
#import "ErrorsHelper.h"
#import "NSUserDefaultKeys.h"

@interface DictionarySetupViewController ()

@end

@implementation DictionarySetupViewController
@synthesize processing = _processing;
@synthesize correctionsOnly = _correctionsOnly;
@synthesize dictionaryBundle = _dictionaryBundle;
@synthesize dictionaryXMLdoc = _dictionaryXMLdoc;
@synthesize correctionsXMLdoc = _correctionsXMLdoc;
@synthesize rootViewControllerForPassingProcessedDictionaryAround = _rootViewControllerForPassingProcessedDictionaryAround;
@synthesize delegate = _delegate;
@synthesize dictionaryName = _dictionaryName;
@synthesize spinner = _spinner;

- (void)setDictionaryBundle:(NSBundle *)dictionaryBundle
{
    if (_dictionaryBundle != dictionaryBundle) {
        _dictionaryBundle = dictionaryBundle;
        
        self.dictionaryXMLdoc = [self loadXML:DOC_TYPE_DICTIONARY fromXMLInDictionaryBundle:dictionaryBundle];
        self.correctionsXMLdoc = [self loadXML:DOC_TYPE_CORRECTIONS fromXMLInDictionaryBundle:dictionaryBundle];
        
        if (self.correctionsOnly && !self.correctionsXMLdoc) {
            //no corrections file and dictionary already processed
            NSString *availableDictionary = [DictionarySetupViewController dictionaryAlreadyProcessed];
            [DictionarySetupViewController loadDictionarywithName:availableDictionary passAroundIn:self.rootViewControllerForPassingProcessedDictionaryAround];
            self.processing = NO;
        }
    }
}

- (void)setDictionaryXMLdoc:(GDataXMLDocument *)XMLdoc
{
    if (_dictionaryXMLdoc != XMLdoc) {
        _dictionaryXMLdoc = XMLdoc;

        if (!self.correctionsOnly) {
            [self processDoc:XMLdoc type:DOC_TYPE_DICTIONARY];
        }
    }
}

- (void)setCorrectionsXMLdoc:(GDataXMLDocument *)XMLdoc
{
    if (_correctionsXMLdoc != XMLdoc) {
        _correctionsXMLdoc = XMLdoc;
        
        [self processDoc:XMLdoc type:DOC_TYPE_CORRECTIONS];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show name of dictionary being processed to user
    NSString *dictionaryDisplayName = [GDataXMLNodeHelper dictionaryNameFor:@"displayName" FromXMLDoc:self.dictionaryXMLdoc];
    if (self.correctionsOnly) {
        dictionaryDisplayName = [NSString stringWithFormat:@"%@ Additions",dictionaryDisplayName];
    }
    self.dictionaryName.text = [NSString stringWithFormat:@"Processing: %@",dictionaryDisplayName];
    [self.spinner startAnimating];
    
    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"Processing: %@",dictionaryDisplayName];
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:viewNameForGA];
    NSLog(@"View sent to GA %@", viewNameForGA);
}

- (void)viewDidUnload
{
    [self setDictionaryName:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

+ (void)loadDictionarywithName:(NSString *)dictionaryName passAroundIn:(UIViewController *)rootViewController
{
//    [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase)
    [DictionaryHelper openDictionary:dictionaryName withImDoneDelegate:nil andDsvc:nil usingBlock:^ (UIManagedDocument *dictionaryDatabase)
    {
        
        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
            
            //share activeDictionary with all VC's
            [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:rootViewController];
            
        } else {
            NSLog(@"dictionary documentState NOT normal");
        }
    }];
}

+ (NSString *)dictionaryAlreadyProcessed //introduced to test for processing dictionary.  **** Should move to dictionaryHelper probably ****
{
    NSString *processedDictionaryName = nil;
    
    NSArray *dictionariesAvailable = [DictionaryHelper currentContentsOfdictionaryDirectory];
    NSLog(@"dictionariesAvailable = %@", dictionariesAvailable);
    
    if ([dictionariesAvailable count] == 1) {
        NSURL *dictionaryURL = [dictionariesAvailable lastObject];
        processedDictionaryName = [dictionaryURL lastPathComponent];
    } else if ([dictionariesAvailable count] > 1) {
        NSLog(@"more than one processed dictionary");
        processedDictionaryName = @"More than 1";
    }
    
    return processedDictionaryName;
}

+ (BOOL) use:(DictionarySetupViewController *)dsvc
   toProcess:(NSBundle *)dictionary
passDictionaryAround:(UIViewController *)rootViewController
 setDelegate:(id <DictionarySetupViewControllerDelegate>)delegate
correctionsOnly:(BOOL)corrections
{
    dsvc.processing = YES;
    dsvc.correctionsOnly = corrections;
    [dsvc setDelegate:delegate];
    dsvc.rootViewControllerForPassingProcessedDictionaryAround = rootViewController;
    dsvc.dictionaryBundle = dictionary;
    return dsvc.processing;
}


- (GDataXMLDocument *)loadXML:(XMLdocType)type fromXMLInDictionaryBundle:(NSBundle *)bundle
{
    NSError *error = nil;
    GDataXMLDocument *XMLdoc = [GDataXMLNodeHelper loadXMLDocType:type FromXMLInDictionaryBundle:bundle Error:&error];
    // GDataXMLDocument *doc = [GDataXMLNodeHelper loadDictionaryFromXMLError:&error];
    
    if (error) {
        NSLog(@"error %@ %@",error, [error userInfo]);
        [ErrorsHelper showXMLParsingError:error];
        XMLdoc = nil;
        
//        UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary XML parsing" 
//                                                            message:[NSString stringWithFormat:@"It seems we can't read your XML Dictionary. Please confirm it conforms to the expected xml format (%@)", error] 
//                                                           delegate:self cancelButtonTitle:@"OK" 
//                                                  otherButtonTitles:nil];
//
//        [alertUser sizeToFit];
//        [alertUser show];
        
    }
    return XMLdoc;
}


-(void)processDoc:(GDataXMLDocument *)XMLdoc type:(XMLdocType)docType
{
    NSString *dictionaryName = [GDataXMLNodeHelper dictionaryNameFor:@"bundleName" FromXMLDoc:self.dictionaryXMLdoc];
    [self loadDictionarywithName:dictionaryName processXML:XMLdoc type:docType];
    
}

- (void)loadDictionarywithName:(NSString *)dictionaryName processXML:(GDataXMLDocument *)XMLdoc type:(XMLdocType)docType
{
    //Get UIManagedDocument for dictionary
    [DictionaryHelper openDictionary:dictionaryName withImDoneDelegate:self.delegate andDsvc:self usingBlock:^ (UIManagedDocument *dictionaryDatabase)
    {
        
        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
            
            if (XMLdoc) {
                
                //process file to populate the UIManagedDocument
                [GDataXMLNodeHelper processXMLfile:XMLdoc type:docType intoManagedObjectContext:dictionaryDatabase.managedObjectContext];
                [DictionaryHelper numberOfWordsInCoreDataDocument:dictionaryDatabase];
//                [DictionaryHelper saveDictionary:dictionaryDatabase]; saving here seems to save a blank UIManagedDocument
                
            }
            
            //share activeDictionary with all VC's
            //only place where this seems to work
            //the UIManagedDoc is not saved yet - can not pass around there as it is a class method so has no sense of self.
            // but cannot show and dismiss view in iPhone because of conflict with displaying of TableView
            if (self.rootViewControllerForPassingProcessedDictionaryAround)
            {
                [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:self.rootViewControllerForPassingProcessedDictionaryAround];
            }
            
//            [self.delegate DictionarySetupViewDidCompleteProcessingDictionary:self]; //didn't work when moved to end of processDoc. moved from here to ensure the async methods have all completed.
            
        } else {
            NSLog(@"dictionary documentState NOT normal");
        }
    }];
}


- (void) showExplanationForFrozenUI     //used during app development superceeded by this view.
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing" 
                                                        message:[NSString stringWithFormat:@"Please wait while we build your dictionary for the first time."] 
                                                       delegate:self cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
 //   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+(BOOL) newVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //get application version from NSUserDefaults and the current code
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *storedAppVersion = [defaults stringForKey:APPLICATION_VERSION];
    NSLog(@"This version %@, stored version %@", version, storedAppVersion);
    
    BOOL returnValue = ![version isEqualToString:storedAppVersion];
    NSLog(@"in New Version: %@", returnValue ? @"YES" : @"NO");
    
    //set version in NSUserDefaults so next time this code doesn't run
    [defaults setObject:version forKey:APPLICATION_VERSION];
    [defaults synchronize];
    
    NSLog(@"**************************");
    NSLog(@" REMOVE forced New Version");
    NSLog(@"       Before Ship");
    NSLog(@"**************************");
    return YES; //used for testing to force correction process - comment out this line before shipping
    
    //    return returnValue; // *********** uncomment this line for SHIP *********
}

+ (BOOL) forceReprocessDictionary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //get reprocessed for version 2.0.5 from NSUserDefaults
    BOOL returnValue = ![defaults boolForKey:PROCESSED_DOC_IN_VERSION_205];
    
    NSLog(@"**************************");
    NSLog(@" REMOVE forced Dict Reprocess");
    NSLog(@"       Before Ship");
    NSLog(@"**************************");
    NSLog(@"returnValue = %c", returnValue);
    return YES; //used for testing to force dictionary reprocess - comment out this line before shipping
    
    //    return returnValue; // *********** uncomment this line for SHIP *********
}

+ (void) processedDictionaryVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //set version in NSUserDefaults we can tell that the activeDictionary for this verison of the app is at least at 2.0.5
    [defaults setBool:YES forKey:PROCESSED_DOC_IN_VERSION_205];
    [defaults synchronize];
 
}


@end
