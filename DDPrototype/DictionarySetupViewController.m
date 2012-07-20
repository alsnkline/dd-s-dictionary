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
@synthesize delegate = _delegate;
@synthesize statusLable = _statusLable;

- (void)setDictionaryBundle:(NSBundle *)dictionaryBundle
{
    if (_dictionaryBundle != dictionaryBundle) {
        _dictionaryBundle = dictionaryBundle;
        
        GDataXMLDocument *doc = [self loadDictionaryFromXMLInDictionaryBundle:dictionaryBundle];
        if (doc) { 
            [self processDoc:doc];
        }
            
//        self.title = [DictionaryHelper dictionaryDisplayNameFrom:??];
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

- (void)viewDidUnload
{
    [self setStatusLable:nil];
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

- (void)processDoc:(GDataXMLDocument *)XMLdoc {
    
    NSString *dictionaryName = [GDataXMLNodeHelper dictionaryNameFor:@"bundleName" FromXMLDoc:XMLdoc];
    [self loadDictionarywithName:dictionaryName createFromXML:XMLdoc];
}

- (void)loadDictionarywithName:(NSString *)dictionaryName createFromXML:(GDataXMLDocument *)XMLdoc
{
    //Get UIManagedDocument for dictionary
    [DictionaryHelper openDictionary:dictionaryName usingBlock:^ (UIManagedDocument *dictionaryDatabase) {
        
        NSLog(@"Got dictionary %@ doc state = %@", [dictionaryDatabase.fileURL lastPathComponent], [DictionaryHelper stringForState:dictionaryDatabase.documentState]);
        if (dictionaryDatabase.documentState == UIDocumentStateNormal) {
            
            if (XMLdoc) {
                
                //process file to populate and save the UIManagedDocument (no way to force reanalysis for changes currently)
                [GDataXMLNodeHelper processXMLfile:XMLdoc intoManagedObjectContext:dictionaryDatabase.managedObjectContext];
                [DictionaryHelper numberOfWordsInCoreDataDocument:dictionaryDatabase];
            }
            
            //share activeDictionary with all VC's
            [DictionaryHelper passActiveDictionary:dictionaryDatabase arroundVCsIn:self.view.window.rootViewController];
            
            [self.delegate DictionarySetupViewDidCompleteProcessingDictionary:self];
            
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
