//
//  SetupTableSwitchViewController.m
//  DDPrototype
//
//  Created by Alison KLINE on 1/12/13.
//
//

#import "SetupTableSwitchViewController.h"
#import "DictionarySetupViewController.h"
#import "DictionaryTableViewController.h"

@interface SetupTableSwitchViewController () <DictionarySetupViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *setupOrTable;

@end

@implementation SetupTableSwitchViewController

@synthesize setupViewController = _setupViewController;
@synthesize activeDictionary = _activeDictionary;


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

- (void)viewDidAppear:(BOOL)animated
{
    
	// Do any additional setup after loading the view.
    
    if([self dictionaryAlreadyProcessed]) {
        //show TableView
        [self performSegueWithIdentifier:@"Push Dictionary Table View" sender:self];
        NSLog(@"rootViewControler = %@", self.view.window.rootViewController);
        
    } else {
        //show setupView and process dictionary
        NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
        [DictionaryTableViewController use:self.setupViewController toProcess:dictionaryShippingWithApp passDictionaryAround:self.view.window.rootViewController setDelegate:self]; //should move this to DictionarySetupViewController Class as its set up related
        [self.view insertSubview:self.setupViewController.view atIndex:0];
    }
    [super viewDidLoad];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //used for iphone only
    if ([segue.identifier isEqualToString:@"Push Dictionary Table View"]) {
        [segue.destinationViewController setActiveDictionary:self.activeDictionary];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSMutableArray *viewControllerStack = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    NSLog(@"view controllers in stack %d", [viewControllerStack count] );
    [viewControllerStack removeObjectAtIndex:0];
    self.navigationController.viewControllers = viewControllerStack;
    NSLog(@"Removed setupViewController from NavController stack");
}

-(NSString *)dictionaryAlreadyProcessed //introduced to test processing dictionary in viewDidLoad.
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // Release any cached data, images, etc that aren't in use.
    if (self.setupViewController) self.setupViewController = nil;
}

-(void) DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)sender
{
    [self performSegueWithIdentifier:@"Push Dictionary Table View" sender:self];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setSetupOrTable:nil];
    [super viewDidUnload];
}

@end

