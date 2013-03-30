//
//  SetupOrMainViewController.m
//  DDPrototype
//
//  Created by Alison KLINE on 2/9/13.
//
//

#import "SetupOrMainViewController.h"
#import "DictionarySetupViewController.h"
#import "AppDelegate.h"
#import "ErrorsHelper.h"


@interface SetupOrMainViewController () <DictionarySetupViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *setupOrTable;
@end

@implementation SetupOrMainViewController

@synthesize activeDictionary = _activeDictionary;
@synthesize setupViewController = _setupViewController;

//This class is landing page for iphone, it tests for available dictionaries and processes one if needed - acting as the delegate for processing finishing.
//once a dictionary is available it swtiches the view to the main flow.


- (UIViewController *)setupViewController
{
    if (!_setupViewController) _setupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Processing Dictionary View"];
    return _setupViewController;
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

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"SetupOrMainViewController Did Appear");
    //see if there are any dictionary's already processed
    
    DocProcessType processType = DOC_PROCESS_USE_EXSISTING; //set a default that gets over riden by the whatProcessingIsNeeded method.
    //NSString *availableDictionary =
    [DictionarySetupViewController whatProcessingIsNeeded:&processType];
    NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
    
    switch (processType) {
        case DOC_PROCESS_REPROCESS:
        {
//            if (availableDictionary) {
//                //clean out the dictionaries
//                [DictionaryHelper cleanOutDictionaryDirectory];
//            }
            [DictionarySetupViewController use:self.setupViewController toProcess:dictionaryShippingWithApp passDictionaryAround:self.view.window.rootViewController setDelegate:self correctionsOnly:NO];
            [self.view insertSubview:self.setupViewController.view atIndex:0];
            [DictionarySetupViewController setProcessedDictionarySchemaVersion]; //set schema processed into User Defaults
            [DictionarySetupViewController setProcessedDictionaryAppVersion]; //set version of app when dictionary was processed
            break;
        }
        case DOC_PROCESS_CHECK_FOR_CORRECTIONS:
        {
            [DictionarySetupViewController use:self.setupViewController toProcess:dictionaryShippingWithApp passDictionaryAround:self.view.window.rootViewController setDelegate:self correctionsOnly:YES];
            [self.view insertSubview:self.setupViewController.view atIndex:0];
            [DictionarySetupViewController setProcessedDictionaryAppVersion]; //set version of app when dictionary was processed
            break;
        }
        case DOC_PROCESS_USE_EXSISTING:
        {
            [self switchToHomeTabController];
            break;
        }
        default:
        {
            NSLog(@"Problem detecting type of Processing needed for Dictionary");
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)dsvc
{
    //processing complete add a short timer to let the saving of the Dictionary complete on all devices even slow ones :-)
    
    //This code sleeps the thread, stoping the saving also?? - although 15 secs did seem to often work.... it was still un-reliable
//    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (ver <= 5.1) {
//        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]]; //60,30, 20, 15 work, 10 secs is not long enough on simulator test
//        //delay for 5.0 and 5.1 devices to avoid blank Dictionary tables.
//    }
    
    //This code sets up a timer and worked consistently in 2.0.4 before passing the completedProcessing Delegate and dsvc into the async methods.
//    NSString *info = @"myTimer event fired";
//    NSTimer *mytimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerDone:) userInfo:info repeats:NO];
//    NSLog(@"mytimer = %@", mytimer);
    
    //processing complete switch to Home Tab Controller - moved to after timer completes in 2.0.4 back from 2.0.5
    
    if ([dsvc.XMLdocsForProcessing count] >0){
        GDataXMLDocument *docForProcess = [dsvc.XMLdocsForProcessing lastObject];
        if (docForProcess == dsvc.dictionaryXMLdoc) {
            [dsvc processDoc:docForProcess type:DOC_TYPE_DICTIONARY];
            NSLog(@"More Dictionary to process");
        }
        if (docForProcess == dsvc.correctionsXMLdoc) {
            [dsvc processDoc:docForProcess type:DOC_TYPE_CORRECTIONS];
            NSLog(@"More Corrections to process");
        }
    } else {
        NSLog(@"Switching to mainTabController");
        [self switchToHomeTabController];
    }
}

- (void) timerDone:(NSTimer *)atimer //method called when timer done used in 2.0.4 before passing the completedProcessing Delegate and dsvc into the async methods.
{
    //processing and saving! complete switch to Home Tab Controller
    NSLog(@"%@", atimer.userInfo);
    [self switchToHomeTabController];
}

- (void) switchToHomeTabController
{
    id controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Home Tab Controller"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = controller;
    [appDelegate.window makeKeyAndVisible];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
