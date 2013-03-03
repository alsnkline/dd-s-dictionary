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
    
    //see if there are any dictionary's already processed
    NSString *availableDictionary = [DictionarySetupViewController dictionaryAlreadyProcessed];
    
    if ([availableDictionary isEqualToString:@"More than 1"]) {
        
        [ErrorsHelper showErrorTooManyDictionaries];
        
    } else {
        
        if (availableDictionary) {
            
            //show TableView
//            [self performSegueWithIdentifier:@"Push Dictionary Table View" sender:self];
            [self switchToHomeTabController];
//            NSLog(@"rootViewControler = %@", self.view.window.rootViewController);
            
        } else {
            
            //show setupView and process dictionary
            NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
            [DictionarySetupViewController use:self.setupViewController toProcess:dictionaryShippingWithApp passDictionaryAround:self.view.window.rootViewController setDelegate:self];
            [self.view insertSubview:self.setupViewController.view atIndex:0];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)sender
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
    [self switchToHomeTabController];
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
