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
#import "ErrorsHelper.h"
#import "NSUserDefaultKeys.h"
#import "GroupHelper.h"

@interface DictionarySetupViewController ()

@end

@implementation DictionarySetupViewController
@synthesize processing = _processing;
@synthesize correctionsOnly = _correctionsOnly;
@synthesize dictionaryBundle = _dictionaryBundle;
@synthesize dictionaryXMLdoc = _dictionaryXMLdoc;
@synthesize correctionsXMLdoc = _correctionsXMLdoc;
@synthesize XMLdocsForProcessing = _XMLdocsForProcessing;
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
        
        
  // manage docs for processing here to ensure they are processed in series
        if (self.correctionsOnly) {
            if (!self.correctionsXMLdoc) {
                //no corrections file and dictionary already processed
                NSString *availableDictionary = [DictionaryHelper dictionaryAlreadyProcessed];
                [DictionarySetupViewController loadDictionarywithName:availableDictionary passAroundIn:self.rootViewControllerForPassingProcessedDictionaryAround];
                self.processing = NO;
            } else {
                [self processDoc:self.correctionsXMLdoc type:DOC_TYPE_CORRECTIONS];
            }
        } else {
            [self processDoc:self.dictionaryXMLdoc type:DOC_TYPE_DICTIONARY];
        }
    }
}

- (void)setDictionaryXMLdoc:(GDataXMLDocument *)XMLdoc
{
    if (_dictionaryXMLdoc != XMLdoc) {
        _dictionaryXMLdoc = XMLdoc;

        if (!self.correctionsOnly) {
//            [self processDoc:XMLdoc type:DOC_TYPE_DICTIONARY];
            self.XMLdocsForProcessing = [NSMutableArray arrayWithObjects:self.dictionaryXMLdoc, nil];
        }
    }
}

- (void)setCorrectionsXMLdoc:(GDataXMLDocument *)XMLdoc
{
    if (_correctionsXMLdoc != XMLdoc) {
        _correctionsXMLdoc = XMLdoc;
        
//        [self processDoc:XMLdoc type:DOC_TYPE_CORRECTIONS];
        if (self.XMLdocsForProcessing) {
            [self.XMLdocsForProcessing addObject:self.correctionsXMLdoc];
        } else {
            self.XMLdocsForProcessing = [NSMutableArray arrayWithObjects:self.correctionsXMLdoc, nil];
        }
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
    [GlobalHelper sendView:viewNameForGA];
    //call Appington
    [Appington start];
    [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"processing_dictionary" andWord:nil];
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
                NSLog(@"Start Processing docType %@", docType ? @"Corrections" : @"Dictionary");
                [GDataXMLNodeHelper processXMLfile:XMLdoc type:docType intoManagedObjectContext:dictionaryDatabase.managedObjectContext];
                [DictionaryHelper numberOfWordsInCoreDataDocument:dictionaryDatabase];
                [self.XMLdocsForProcessing removeObject:XMLdoc];
                NSLog(@"still left to process %@" ,self.XMLdocsForProcessing);
//                [DictionaryHelper saveDictionary:dictionaryDatabase]; saving here seems to save a blank UIManagedDocument
                
//                [DictionaryHelper saveDictionary:dictionaryDatabase withImDoneDelegate:self.delegate andDsvc:self]; //trying to get around correction issue
//                [self.delegate DictionarySetupViewDidCompleteProcessingDictionary:self]; //trying to get around correction issue
                
            }
            
            //share activeDictionary with all VC's
            //only place where this seems to work
            //the UIManagedDoc is not saved yet - can not pass around there as it is a class method so has no sense of self.
            // but cannot show and dismiss view in iPhone because of conflict with displaying of TableView
            if (self.rootViewControllerForPassingProcessedDictionaryAround && ([self.XMLdocsForProcessing count] == 0))  //Only pass around if finished processing
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

+ (NSString *) whatProcessingIsNeeded:(DocProcessType *)docProcessType isFTU:(BOOL *)isFTU
{
    
    //see if there are any dictionary's already processed
    NSString *availableDictionary = [DictionaryHelper dictionaryAlreadyProcessed];
    BOOL forceReprocess = [DictionarySetupViewController reprocessDictionaryForNewSchema];
    BOOL newVersion = [DictionarySetupViewController isNewAppVersion];
    BOOL wasProcessingCompleted = [DictionarySetupViewController wasProcessingCompleted];
    
    if (OVERRIDE_PROCESSING) {
        forceReprocess = FORCE_REPROCESS;
        newVersion = FAKE_NEW_VERSION;
    }
    
    
    if ( forceReprocess || !availableDictionary || !wasProcessingCompleted) {
        if (!availableDictionary) {
            NSLog(@"Processing as no dictionary AKA First Time User");
            //track first time user
            [GlobalHelper trackFirstTimeUserWithAction:[GlobalHelper deviceType] withLabel:[GlobalHelper version] withValue:[NSNumber numberWithInt:1]];
            // Need to pass this back so can trigger Appington ftue after table view has been loaded.
            *isFTU = YES;
        }
        if (forceReprocess && availableDictionary) {
            NSLog(@"FORCED delete and reprocessing");
        }
        if (!wasProcessingCompleted) {
            NSLog(@"processing was INCOMPLETE, reprocessing, have availableDictionary %@", availableDictionary ? @"YES" : @"NO");
        }
        if (!forceReprocess && !availableDictionary) NSLog(@"No Dict AND current schema processed. This state shouldn't arise");
        
        [GroupHelper setProcessedGroupsJSONFileVersionIsReset:YES];
        *docProcessType = DOC_PROCESS_REPROCESS;
    } else if (newVersion){
        //set ready for processing
        *docProcessType = DOC_PROCESS_CHECK_FOR_CORRECTIONS;
    } else {
        *docProcessType = DOC_PROCESS_USE_EXSISTING;
    }

    return availableDictionary;
}

+ (BOOL)isProcessingFinishedInDsvc:(DictionarySetupViewController *)dsvc
{
    if ([dsvc.XMLdocsForProcessing count] > 0){
        return NO;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //set flag to show processing completed
        [defaults setBool:YES forKey:DICTIONARY_PROCESSING_COMPLETED];
        NSLog(@"------ PROCESSING COMPLETE -------");
        return YES;
    }
    
}

+ (void)keepProcessingWithDsvc:(DictionarySetupViewController *)dsvc
{
    GDataXMLDocument *docForProcess = [dsvc.XMLdocsForProcessing lastObject];
    if (docForProcess == dsvc.dictionaryXMLdoc) {
        [dsvc processDoc:docForProcess type:DOC_TYPE_DICTIONARY];
        NSLog(@"More Dictionary to process");
    }
    if (docForProcess == dsvc.correctionsXMLdoc) {
        [dsvc processDoc:docForProcess type:DOC_TYPE_CORRECTIONS];
        NSLog(@"More Corrections to process");
    }
}

+ (BOOL) wasProcessingCompleted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //check to see if document processing was completed
    BOOL returnValue = [defaults boolForKey:DICTIONARY_PROCESSING_COMPLETED];
    NSLog(@"Document processing %@", returnValue ? @"had been completed" : @"had NOT completed");
    
    return returnValue;
}


+ (NSString *) stringForLog:(DocProcessType)docProcessType
{
    NSString *docProcessForLog = nil;
    switch (docProcessType) {
        case DOC_PROCESS_REPROCESS:
        {
            docProcessForLog = [NSString stringWithFormat:@"Process or Reprocess"];
            break;
        }
        case DOC_PROCESS_CHECK_FOR_CORRECTIONS:
        {
            docProcessForLog = [NSString stringWithFormat:@"Check for Corrections"];
            break;
        }
        case DOC_PROCESS_USE_EXSISTING:
        {
            docProcessForLog = [NSString stringWithFormat:@"Use Exsisting"];
            break;
        }
        default:
        {
            NSLog(@"Problem detecting docProcessType");
            break;
        }
    }
    return docProcessForLog;
}

+(BOOL) isNewAppVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //get application version from NSUserDefaults and the current code
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *storedAppVersion = [defaults stringForKey:APPLICATION_VERSION];
    NSLog(@"This version %@, stored version %@", version, storedAppVersion);
    
    BOOL returnValue = ![version isEqualToString:storedAppVersion];
    NSLog(@"in New Version: %@", returnValue ? @"YES" : @"NO");
    
    return returnValue;
}

+ (void) setProcessedDictionaryAppVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //set version in NSUserDefaults so next time new version code doesn't run
    [defaults setObject:version forKey:APPLICATION_VERSION];
    [defaults synchronize];    
}

+ (BOOL) reprocessDictionaryForNewSchema
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //check to see if document was processed in version 2.0.5 from NSUserDefaults
    // if yes then no need to reprocess.
    BOOL returnValue = ![defaults boolForKey:PROCESSED_DOC_SCHEMA_VERSION_205];
    NSLog(@"Processed doc schema version %@", returnValue ? @"< 205" : @"= 205");
    
    return returnValue; 
}

+ (void) setProcessedDictionaryForNewSchema
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //set version in NSUserDefaults we can tell that the activeDictionary for this verison of the app is at least at 2.0.5
    [defaults setBool:YES forKey:PROCESSED_DOC_SCHEMA_VERSION_205];
    [defaults synchronize];
 
}


@end
