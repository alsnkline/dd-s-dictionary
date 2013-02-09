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
        
        [self showErrorTooManyDictionaries];
        
    } else {
        
        if (availableDictionary) {
            
            //show TableView
//            [self performSegueWithIdentifier:@"Push Dictionary Table View" sender:self];
            [self switchToHomeTabController];
//            NSLog(@"rootViewControler = %@", self.view.window.rootViewController);
            
        } else {
            
            //show setupView and process dictionary
            NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
            [DictionarySetupViewController use:self.setupViewController toProcess:dictionaryShippingWithApp passDictionaryAround:self.view.window.rootViewController setDelegate:self]; //should move this to DictionarySetupViewController Class as its set up related
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
    //processing complete switch to Home Tab Controller
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


- (void) showErrorTooManyDictionaries     //also in DictionaryTableViewContoller
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Dictionary processing problem"
                                                        message:[NSString stringWithFormat:@"Sorry, you have too many dictionaries processed."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
}


@end
