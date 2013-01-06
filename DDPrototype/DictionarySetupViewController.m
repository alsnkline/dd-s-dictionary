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

@interface DictionarySetupViewController ()

@end

@implementation DictionarySetupViewController
@synthesize dictionaryBundle = _dictionaryBundle;
@synthesize XMLdoc = _XMLdoc;
@synthesize rootViewControllerForPassingProcessedDictionaryAround = _rootViewControllerForPassingProcessedDictionaryAround;
@synthesize delegate = _delegate;
@synthesize progressMessageLabel = _progressMessageLable;
@synthesize dictionaryName = _dictionaryName;
@synthesize spinner = _spinner;

- (void)setDictionaryBundle:(NSBundle *)dictionaryBundle
{
    if (_dictionaryBundle != dictionaryBundle) {
        _dictionaryBundle = dictionaryBundle;
        
        self.XMLdoc = [self loadDictionaryFromXMLInDictionaryBundle:dictionaryBundle];
        
    }
}

- (void)setXMLdoc:(GDataXMLDocument *)XMLdoc
{
    if (_XMLdoc != XMLdoc) {
        _XMLdoc = XMLdoc;

        [self processDoc];
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
    NSString *dictionaryDisplayName = [GDataXMLNodeHelper dictionaryNameFor:@"displayName" FromXMLDoc:self.XMLdoc];
    self.dictionaryName.text = [NSString stringWithFormat:@"Processing: %@",dictionaryDisplayName];
    [self.spinner startAnimating];
}

- (void)viewDidUnload
{
    [self setProgressMessageLabel:nil];
    [self setDictionaryName:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

+ (void)loadDictionarywithName:(NSString *)dictionaryName passAroundIn:(UIViewController *)rootViewController
{
    [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase) {
        
        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
            
            //share activeDictionary with all VC's
            [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:rootViewController];
            
        } else {
            NSLog(@"dictionary documentState NOT normal");
        }
    }];
}

- (GDataXMLDocument *)loadDictionaryFromXMLInDictionaryBundle:(NSBundle *)bundle
{
    NSError *error = nil;
    GDataXMLDocument *XMLdoc = [GDataXMLNodeHelper loadDictionaryFromXMLInDictionaryBundle:bundle Error:&error];
    // GDataXMLDocument *doc = [GDataXMLNodeHelper loadDictionaryFromXMLError:&error];
    
    if (error) {
        UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary XML parsing" 
                                                            message:[NSString stringWithFormat:@"It seems we can't read your XML Dictionary. Please confirm it conforms to the expected xml format (%@)", error] 
                                                           delegate:self cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        NSLog(@"error %@ %@",error, [error userInfo]);
        [alertUser sizeToFit];
        [alertUser show];
        XMLdoc = nil;
    }
    return XMLdoc;
}


-(void)processDoc
{
    NSString *dictionaryName = [GDataXMLNodeHelper dictionaryNameFor:@"bundleName" FromXMLDoc:self.XMLdoc];
    [self loadDictionarywithName:dictionaryName createFromXML:self.XMLdoc];
    
}

- (void)loadDictionarywithName:(NSString *)dictionaryName createFromXML:(GDataXMLDocument *)XMLdoc
{
    //Get UIManagedDocument for dictionary
    [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase) {
        
        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
            
            if (XMLdoc) {
                
                //process file to populate the UIManagedDocument (no way to force reanalysis for changes currently)
                [GDataXMLNodeHelper processXMLfile:XMLdoc intoManagedObjectContext:dictionaryDatabase.managedObjectContext showProgressIn:self.progressMessageLabel];
                [DictionaryHelper numberOfWordsInCoreDataDocument:dictionaryDatabase];
//                [DictionaryHelper saveDictionary:dictionaryDatabase]; saving here seems to save a blank UIManagedDocument
                
            }
            
            //share activeDictionary with all VC's
            //only place where this seems to work
            //the UIManagedDoc is not saved yet - can not pass around there as it is a class method so has no sense of self.
            // but cannot show and dismiss view because of conflict with displaying of TableView
            [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:self.rootViewControllerForPassingProcessedDictionaryAround];
            
            [self.delegate DictionarySetupViewDidCompleteProcessingDictionary:self]; //didn't work when moved to end of processDoc.
            
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

@end
