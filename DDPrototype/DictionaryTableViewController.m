//
//  DictionaryTableViewController.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictionaryTableViewController.h"
#import "DisplayWordViewController.h"
#import "Word+Create.h"
#import "DictionarySetupViewController.h"
#import "NSUserDefaultKeys.h"
#import "ErrorsHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "double_metaphone.h"


@interface DictionaryTableViewController () <DisplayWordViewControllerDelegate, UIPopoverControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic) BOOL useDyslexieFont;
@property (nonatomic) BOOL settingUpDictionary;
@property (nonatomic) BOOL tableViewFromStoryBoardHasBeenSetup;
@property (nonatomic) BOOL searchTableViewFromStoryBoardHasBeenSetup;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic, strong) UIPopoverController *popoverController;  //used to track the start up popover in iPad
@property (nonatomic, strong) DictionarySetupViewController *dsvc; //used to track the start up vc in iPhone as there is no popover
@property (nonatomic, strong) Word *selectedWord;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

@end

@implementation DictionaryTableViewController
@synthesize activeDictionary = _activeDictionary;
@synthesize playWordsOnSelection = _playWordsOnSelection;
@synthesize useDyslexieFont = _useDyslexieFont;
@synthesize isFTU = _isFTU;
@synthesize settingUpDictionary = _settingUpDictionary;
@synthesize tableViewFromStoryBoardHasBeenSetup = _tableViewFromStoryBoardHasBeenSetup;
@synthesize searchTableViewFromStoryBoardHasBeenSetup = _searchTableViewFromStoryBoardHasBeenSetup;
@synthesize searchBar = _searchBar;
@synthesize customBackgroundColor = _customBackgroundColor;
@synthesize popoverController;
@synthesize dsvc = _dsvc;
@synthesize selectedWord = _selectedWord;
@synthesize searchFetchedResultsController = _searchFetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupFetchedResultsController 
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
//    NSString *searchString = [NSString stringWithFormat:@"x"];
//    request.predicate = [NSPredicate predicateWithFormat:@"SELF.spelling contains[cd] %@", searchString]; //test for search
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.activeDictionary.managedObjectContext 
                                                                          sectionNameKeyPath:@"fetchedResultsSection" 
                                                                                   cacheName:nil];
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    NSPredicate *filterPredicate = nil;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    
    //contains search on the spelling field (often too precise)
    NSPredicate *spellingPredicate = [NSPredicate predicateWithFormat:@"SELF.spelling contains[cd] %@", searchString];  //for straight contains search
    if (LOG_PREDICATE_RESULTS) [GlobalHelper testWordPredicate:spellingPredicate inContext:self.activeDictionary.managedObjectContext];
    
    //contains search on doubleMetaphoneCodes both codes (often not precise enough)
    NSArray *doubleMetaphoneCodesForSearchString = [GlobalHelper doubleMetaphoneCodesFor:searchString];
    NSMutableArray *parr = [NSMutableArray arrayWithCapacity:4];
    
    for (NSString * string in doubleMetaphoneCodesForSearchString) {
        if ([string length]) {
            NSPredicate *dMPrimaryCodePredicate = [NSPredicate predicateWithFormat:@"SELF.doubleMetaphonePrimaryCode beginswith[cd] %@", string];
            [parr addObject:dMPrimaryCodePredicate];
            if (LOG_PREDICATE_RESULTS) [GlobalHelper testWordPredicate:dMPrimaryCodePredicate inContext:self.activeDictionary.managedObjectContext];
        
            NSPredicate *dMSecondaryPredicate = [NSPredicate predicateWithFormat:@"SELF.doubleMetaphoneSecondaryCode beginswith[cd] %@", string];
            [parr addObject:dMSecondaryPredicate];
            if (LOG_PREDICATE_RESULTS) [GlobalHelper testWordPredicate:dMSecondaryPredicate inContext:self.activeDictionary.managedObjectContext];
        }
    }
    
    NSPredicate *compoundDMFilterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:parr];
    if (LOG_PREDICATE_RESULTS) [GlobalHelper testWordPredicate:compoundDMFilterPredicate inContext:self.activeDictionary.managedObjectContext];

    
    //if contains search on spelling doesn't give results switch to the compoundDM search
    if ([GlobalHelper testWordPredicate:spellingPredicate inContext:self.activeDictionary.managedObjectContext] > 0){
        filterPredicate = spellingPredicate;
    } else {
        filterPredicate = compoundDMFilterPredicate;  //compoundDMFilterPredicate was way too fuzzy, too many hits to be useful
//        filterPredicate = [NSPredicate predicateWithFormat:@"SELF.doubleMetaphonePrimaryCode contains[cd] %@", [doubleMetaphoneCodesForSearchString lastObject]];
    }
    
//    NSLog(@"searchString for Predicate: %@", searchString),
    NSLog(@"Predicate: %@", filterPredicate);
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = nil;
    
    if (self.activeDictionary)
    {
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                    managedObjectContext:self.activeDictionary.managedObjectContext
                                                                                                      sectionNameKeyPath:@"fetchedResultsSection"
                                                                                                               cacheName:nil];
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![aFetchedResultsController performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)setActiveDictionary:(UIManagedDocument *)activeDictionary
{
    if (_activeDictionary != activeDictionary) {
        _activeDictionary = activeDictionary;
        
        [self setupFetchedResultsController];
        self.title = [DictionaryHelper dictionaryDisplayNameFrom:activeDictionary];
        self.settingUpDictionary = NO;
        
        if (self.isViewLoaded && self.view.window) {
            //viewController is visible track with GA allowing iPad also useful on iPhone when setup takes time stats to show which dict got loaded.
            [self tellPartnersTableIsVisible];
        }
        
// different ways to dismiss views - all attempts to control iPhone flow from this one class caused corruption in the Nav Controller stack
//           [self.dsvc dismissViewControllerAnimated:YES completion:nil]; 
//           [self.navigationController popViewControllerAnimated:NO];

    }
}
         
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    DisplayWordViewController *dwvc = [self getSplitViewWithDisplayWordViewController];
    if (dwvc) {
        //iPad
        [dwvc setDelegate:self];
    } else {
        //if iPhone to prevent the back button flashing
        [self.navigationItem setHidesBackButton:YES];
    }
    
    
    // set up search VC delegates.
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    //self.debug = YES;
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"Dict Search Table Shown: %@", self.title];
    [GlobalHelper sendView:viewNameForGA];
    //call Appington
    [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"search" andWord:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
//    [self setupSearchBarAboveTableView]; //add back in to get somewhat close to a search bar stuck to the top of the table
    tableView.backgroundColor = self.customBackgroundColor;
    tableView.rowHeight = 55.0f; // setting row height on the search results table to match the main table.
}

- (void)setupSearchBarAboveTableView
{
    /* added when I was considering showing the search bar all the time.
     http://stackoverflow.com/questions/9340345/keep-uisearchbar-visible-even-if-user-is-sliding-down and
     UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
     searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
     searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
     self.tableView.tableHeaderView = searchBar;
     from     http://stackoverflow.com/questions/4471289/how-to-filter-nsfetchedresultscontroller-coredata-with-uisearchdisplaycontroll
     if you ever want to revisit that idea.
     View Will appear is too early view changes are overridden here.
     */
    if (!self.searchDisplayController.isActive)
    {
        //regular view
        if (!self.tableViewFromStoryBoardHasBeenSetup)
        {
            CGRect newFrame = CGRectMake(0, 44, self.tableView.bounds.size.width, self.tableView.bounds.size.height-44);
            self.tableView.frame = newFrame;
            self.tableView.tableHeaderView = nil;

            CGRect searchBarFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, 44);
            self.searchBar.frame = searchBarFrame;
            [self.tableView.superview addSubview:self.searchBar];
            
            self.tableViewFromStoryBoardHasBeenSetup = YES;
        }
    } else {
        //search view
        if (!self.searchTableViewFromStoryBoardHasBeenSetup)
        {
            CGRect searchBarFrame = CGRectMake(0, 44, self.tableView.bounds.size.width, 44);
            self.searchBar.frame = searchBarFrame;
            
            CGRect newFrame = CGRectMake(0, 0, self.navigationController.view.bounds.size.width, self.navigationController.view.bounds.size.height);
            self.searchDisplayController.searchResultsTableView.frame = newFrame;
            
            
//            [self.searchBar removeFromSuperview];
            [self.navigationController.view addSubview:self.searchBar];
            
            self.searchTableViewFromStoryBoardHasBeenSetup = YES;
        }
        
    }
//    if (!self.reworkedSelfTableViewFromStoryBoard) {
//        //First time setup view is called only
//        NSLog(@"TableView frame 4: %f, %f, %f, %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        
//        CGRect newFrame = CGRectMake(0, 1, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
//        self.tableView.frame = newFrame;
//        
//        //    CGRect newFrame2 = CGRectMake(0, 0, self.tableView.tableHeaderView.bounds.size.width, 0);
//        //    self.tableView.tableHeaderView.bounds = newFrame2;
//        
//        NSLog(@"TableView Search Bar frame 4: %f, %f, %f, %f", self.searchDisplayController.searchBar.frame.origin.x, self.searchDisplayController.searchBar.frame.origin.y, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
//        NSLog(@"TableView Search TableView frame 8: %f, %f, %f, %f", self.searchDisplayController.searchResultsTableView.bounds.origin.x, self.searchDisplayController.searchResultsTableView.bounds.origin.y, self.searchDisplayController.searchResultsTableView.bounds.size.width, self.searchDisplayController.searchResultsTableView.bounds.size.height);
//        NSLog(@"searchbar superview = %@", self.searchDisplayController.searchBar.superview);
//        NSLog(@"tableView superview = %@", self.tableView.superview);
//        
//        
//        [self.searchDisplayController.searchBar removeFromSuperview];
//        [self.tableView.superview addSubview:self.searchDisplayController.searchBar];
//        CGRect anotherNewFrame = CGRectMake(0, 0, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
//        self.searchDisplayController.searchBar.frame = anotherNewFrame;
//        CGRect yetAnotherNewFrame = CGRectMake(0,self.searchDisplayController.searchBar.bounds.size.height, self.searchDisplayController.searchResultsTableView.frame.size.width, self.searchDisplayController.searchResultsTableView.frame.size.height-self.searchDisplayController.searchBar.bounds.size.height);
//        self.searchDisplayController.searchResultsTableView.frame = yetAnotherNewFrame;
//        
//        NSLog(@"TableView frame 5: %f, %f, %f, %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        self.reworkedSelfTableViewFromStoryBoard = YES;
//
//        [self.searchDisplayController.searchResultsTableView removeFromSuperview];
//        [self.tableView.superview addSubview:self.searchDisplayController.searchResultsTableView];
//    }
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    self.tableViewFromStoryBoardHasBeenSetup = NO;
}

-(void)viewDidAppear:(BOOL)animated  //most of this could/should be in viewWillAppear! not tellPartners
{

//    [self setupSearchBarAboveTableView]; //add back in to get somewhat close to a search bar stuck to the top of the table
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set value of backgroundColor
    self.customBackgroundColor = [UIColor colorWithHue:[defaults floatForKey:BACKGROUND_COLOR_HUE] saturation:[defaults floatForKey:BACKGROUND_COLOR_SATURATION] brightness:1 alpha:1];
    if ([self.tableView indexPathForSelectedRow]) {
        // we have to deselect change color and reselect or we get the old color showing up when the selection is changed.
        NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:selectedCell animated:NO];
        self.view.backgroundColor = self.customBackgroundColor;
        [self.tableView selectRowAtIndexPath:selectedCell animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        self.view.backgroundColor = self.customBackgroundColor;
    }
    
    //set value of playWordsOnSelection and useDyslexieFont
    self.playWordsOnSelection = [defaults boolForKey:PLAY_WORDS_ON_SELECTION];
    if (self.useDyslexieFont != [defaults boolForKey:USE_DYSLEXIE_FONT]) {
        self.useDyslexieFont = [defaults boolForKey:USE_DYSLEXIE_FONT];
        [self.tableView reloadData];
    }
    
    if (!self.activeDictionary) {  //this can't be in view did load - doesn't work as activeDictionary is still nil at that time = problems!
        self.settingUpDictionary = YES;
        [self setUpDictionary]; // used in iPad to trigger loading if necessary, in iphone it always triggers loading and passing the processed dictionary around.
    }
    
    [self tellPartnersTableIsVisible];

}

-(void) setUpDictionary
{
    //see if there are any dictionary's already processed
    
    DocProcessType processType = DOC_PROCESS_USE_EXSISTING;  //set a default that gets over riden by the whatProcessingIsNeeded method.
    BOOL isFTU = NO; //set a default that gets over riden by the whatProcessingIsNeeded method
    NSString *availableDictionary = [DictionarySetupViewController whatProcessingIsNeeded:&processType isFTU:&isFTU];
    if (isFTU) self.isFTU = isFTU;  //condition required to stop isFTU over riding self.isFTU in iPhone (it was set before view was called)
    
    if (![self getSplitViewWithDisplayWordViewController]) {
        processType = DOC_PROCESS_USE_EXSISTING; //we're in an iPhone any processing has already been completed
        NSLog(@"We are in an iPhone docProcessingType reset to %@", [DictionarySetupViewController stringForLog:processType]);
    }
   
    NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
    NSLog(@"docProcessType = %@", [DictionarySetupViewController stringForLog:processType]);
    
    switch (processType) {
        case DOC_PROCESS_REPROCESS:
        {
            if (availableDictionary) {
                //clean out the dictionaries
                [DictionaryHelper cleanOutDictionaryDirectory];   //needed or forced reprocess wont work
            }
            [self displayViewWhileProcessing:dictionaryShippingWithApp correctionsOnly:NO];
            [DictionarySetupViewController setProcessedDictionaryForNewSchema]; //set schema processed into User Defaults
            [DictionarySetupViewController setProcessedDictionaryAppVersion]; //set version of app when dictionary was processed
            break;
        }
        case DOC_PROCESS_CHECK_FOR_CORRECTIONS:
        {
            [self displayViewWhileProcessing:dictionaryShippingWithApp correctionsOnly:YES];
            [DictionarySetupViewController setProcessedDictionaryAppVersion]; //set version of app when dictionary was processed
            break;
        }
        case DOC_PROCESS_USE_EXSISTING:
        {
            if (!availableDictionary) {
                NSLog(@"problem, no dictionary but want to use it");
                break; //protect from crash, but this shouldn't happen.
            }
            NSLog(@"Opening the 1 dictionary available its name: %@", availableDictionary);
//            NSLog(@"rootViewControler = %@", self.view.window.rootViewController);
            [DictionarySetupViewController loadDictionarywithName:availableDictionary passAroundIn:self.view.window.rootViewController];
            break;
        }
        default:
        {
            NSLog(@"Problem detecting type of Processing needed for Dictionary");
            break;
        }
    }
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    self.popoverController = nil;
    self.dsvc = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) tellPartnersTableIsVisible
{
    //track with GA manually avoid subclassing UIViewController - will get many with iPhone and few with iPad
    NSString *viewNameForGA = nil;
    if (self.settingUpDictionary) {
        viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: setting up"];
    } else {
        viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: %@", self.title];
        
        //Call Appington event control
        [self callAppingtonWithViewDetails];
    }
    [GlobalHelper sendView:viewNameForGA];
}

- (void) callAppingtonWithViewDetails
{
    [Appington start];
    if (self.isFTU) {
        [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"ftue" andWord:nil];
        self.isFTU = NO;
    }
    
    DisplayWordViewController *dwvc = [self getSplitViewWithDisplayWordViewController];
    if (dwvc) {         // we're in an ipad
        NSString *currentlyShowingText = dwvc.spelling.text;
        [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"word_list_view" andWord:currentlyShowingText];
        if (!self.title) [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"word_list_view" andWord:@"no_dictionary"];
    } else {            // we're in an iPhone
        [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"word_list" andWord:nil];
        if (!self.title) [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"word_list" andWord:@"no_dictionary"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//popover Controller delegate and contents of popover controller delegate management methods.

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return NO;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController = nil;
}

- (void)DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)dsvc
{
    if (![DictionarySetupViewController isProcessingFinishedInDsvc:dsvc]){
        [DictionarySetupViewController keepProcessingWithDsvc:dsvc];
    } else {
        // successfully completed dictionary processing
        if ([self getSplitViewWithDisplayWordViewController]) {
            // iPad
            [self.popoverController dismissPopoverAnimated:YES];
        }
    }
}


//- (NSArray *)alphabet
//{
//    NSMutableArray *alphabet = [NSMutableArray array]; 
//    for (char a = 'a'; a <= 'z'; a++) {
//        [alphabet addObject:[NSString stringWithFormat:@"%c", a]];
//    }
//    return [alphabet copy];
//}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the old SearchFRC and create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the searchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
    
    self.searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:searchText];

    //track event with GA
    [GlobalHelper trackSearchEventWithAction:self.title withLabel:searchText withValue:[NSNumber numberWithInt:1]];

    //call Appington
    [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"search" andWord:searchText];
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    self.searchTableViewFromStoryBoardHasBeenSetup = NO;
    
    if ([[self fetchedResultsControllerForTableView:self.tableView].fetchedObjects containsObject:self.selectedWord]) {
        NSIndexPath *indexPathOfSelectedWord = [self.fetchedResultsController indexPathForObject:self.selectedWord];
        [self.tableView selectRowAtIndexPath:indexPathOfSelectedWord animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark Search Bar Delegate methods
//over riding some of those in the coreDataTableViewController parent class to make search work.

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
//    [tableView beginUpdates];
    
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    if (self.beganUpdates){
        [tableView endUpdates];
    }
}

#pragma mark - Table view data source

- (BOOL) DictionaryIsStillLoadingOrsearchHasNoResults:(NSFetchedResultsController *)fetchedResultsController
{
//    BOOL hasNoResults = NO;
//    
//    if (self.searchDisplayController.isActive) {
//        hasNoResults = [[fetchedResultsController fetchedObjects] count]? NO : YES;
//    }
//    
//    return hasNoResults;
    return [[fetchedResultsController fetchedObjects] count]? NO : YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if ([self DictionaryIsStillLoadingOrsearchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
        count = 1;
    } else {
        count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    }
    NSLog(@"table section count: %d", count);
    
    return count;
    //    return [[self alphabet] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSInteger numberOfRows = 0;
    if ([self DictionaryIsStillLoadingOrsearchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
        numberOfRows = 1;
    } else {
    
        NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
        NSArray *sections = fetchController.sections;
        if(sections.count > 0)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
    }
//    NSLog(@"table section row count: %d", numberOfRows);
    return numberOfRows;
    
}


//overiding section managment to get Search to work

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString *titleForSection = nil;
    if ([self DictionaryIsStillLoadingOrsearchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
        titleForSection = nil; // is called but nil is OK
    } else {
        titleForSection = [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
    }
    
    return titleForSection;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index //overiding in DictTableView to get Search to work
{
	
    if (self.searchDisplayController.isActive) // return from sections for search table.
    {
        return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
        
    } else if (index >0) { // return from sections adjusted for the search icon for main table.
        
        return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index-1];
        
    } else {  // force table to top of is show search if search icon is selected.
        self.tableView.contentOffset = CGPointZero;
        return NSNotFound;
//        return 0;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView //overiding in DictTableView to get Search to work
{
    NSFetchedResultsController *FRC = [self fetchedResultsControllerForTableView:tableView];
    
    if (!self.searchDisplayController.isActive)
    {
        NSMutableArray *index = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        NSArray *initials = [FRC sectionIndexTitles];
        [index addObjectsFromArray:initials];
        return index;
    } else {
        return [FRC sectionIndexTitles];
    }
    
//    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

- (UIActivityIndicatorView *) getSpinnerView
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake((self.tableView.frame.size.width/2 - 12), (55+55/2-12), 24, 24);
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    return spinner;

}

-(UIButton *)getAddWordButton
{
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [myButton addTarget:self action:@selector(addwordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat buttonWidth = 225;  //hard coded for now
    CGFloat leftSpacing = (self.tableView.frame.size.width/2)-(buttonWidth/2);  //centralizing the button in the tableView
    CGFloat cRadius = 8; //corner radius for button
    CGFloat spacing = 4; // the amount of spacing to appear between image and title
    NSLog(@"spacing = %f, buttonWidth = %f", leftSpacing, buttonWidth);
    myButton.frame = CGRectMake(leftSpacing, 4, buttonWidth, 45);
    
    [myButton setImage:[UIImage imageNamed:@"resources.bundle/Images/dinoOnlyIcon32x32.png"] forState:UIControlStateNormal];
    [myButton setTitle:@"Ask DD to add this word" forState:UIControlStateNormal];
    myButton.tintColor = [UIColor grayColor];
    
    UIImage *backImage = [DisplayWordViewController createImageOfColor:self.customBackgroundColor ofSize:CGSizeMake(40, 25) withCornerRadius:cRadius];
//    UIImage* stretchableImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch];
    UIImage *stretchableImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [myButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    

    myButton.layer.masksToBounds = YES;
    myButton.layer.cornerRadius = cRadius;
    myButton.layer.needsDisplayOnBoundsChange = YES;
    

    myButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    myButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    
    //myButton.titleLabel.text = @"Ask DD to add this word";
    //myButton.imageView.image = [UIImage imageNamed:@"resources.bundle/Images/dinoOnlyIcon.png"];
    
    return myButton;
}

#define ADD_WORD_BUTTON_TAG 1111
#define SPINNER_TAG 2222

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController isSearch:(BOOL)isSearch configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // your cell guts here
    
    cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Regular" size:20] : [UIFont boldSystemFontOfSize:20];
    
    if ([self DictionaryIsStillLoadingOrsearchHasNoResults:fetchedResultsController]) {
        if (isSearch) { //Search has no results
            if (![cell.contentView viewWithTag:ADD_WORD_BUTTON_TAG]) { //button isn't already present
                cell.textLabel.text = @"";
                UIButton *button = [self getAddWordButton];
                button.tag = ADD_WORD_BUTTON_TAG;
                [cell.contentView addSubview:button];
                
                //        cell.textLabel.text = @"Ask DD to add this word";
                //        cell.textLabel.textColor = [UIColor blueColor];
                //        cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Italic" size:40] : [UIFont fontWithName:@"Arial-BoldItalic" size:30];
                //        cell.textLabel.font = [UIFont fontWithName:@"Dyslexiea-Italic" size:40];
                //        cell.imageView.image = [UIImage imageNamed:@"resources.bundle/Images/dinoOnlyIcon.png"];
            }
            
        } else {   //Dictionary Is Still Loading/Opening
            if (![cell.contentView viewWithTag:SPINNER_TAG]) {
                cell.textLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                UIActivityIndicatorView *spinner = [self getSpinnerView];
                spinner.tag = SPINNER_TAG;
                [cell.contentView addSubview:spinner];
            }
        }
    } else {
        Word *word = [fetchedResultsController objectAtIndexPath:indexPath];
//        NSLog(@"Before reconfigure Cell content view %@", cell.contentView.subviews);
        //clean out UIButton and UIActivityIndicator views if cell is being reused
        if ([cell.contentView viewWithTag:SPINNER_TAG]) [[cell.contentView viewWithTag:SPINNER_TAG] removeFromSuperview];
        if ([cell.contentView viewWithTag:ADD_WORD_BUTTON_TAG]) [[cell.contentView viewWithTag:ADD_WORD_BUTTON_TAG] removeFromSuperview];
        if ([cell.contentView.subviews count] == 0 ) [cell.contentView addSubview:cell.textLabel]; //don't really need this but seems right and is needed for the log messages to look correct.
        
        NSArray *doubleMetaphoneCodes = [GlobalHelper doubleMetaphoneCodesFor:word.spelling];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", word.spelling, [GlobalHelper stringForDoubleMetaphoneCodesArray:doubleMetaphoneCodes]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        NSLog(@"After reconfigure Cell content view %@", cell.contentView.subviews);
    //    NSLog(@"cell: %@", word.spelling);
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Word";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
        // Configure the cell...
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] isSearch:!(tableView == self.tableView)  configureCell:cell atIndexPath:indexPath];

    

//    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath]; //moved to get search to work.
//    cell.textLabel.text = word.spelling; //moved to get Search to work.
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self DictionaryIsStillLoadingOrsearchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
        if (self.searchDisplayController.isActive) [self addwordButtonPressed];
    } else {
        [self wordSelectedAtIndexPath:(NSIndexPath *)indexPath fromTableView:tableView];
    }
}

- (void) addwordButtonPressed {
    [DictionaryTableViewController showAddWordRequested:self.title and:self.searchDisplayController.searchBar.text];
    self.searchDisplayController.searchBar.text = @"";
    [self.searchDisplayController setActive:NO];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //used for iphone only
    if ([segue.identifier isEqualToString:@"Word Selected"]) {
        [segue.destinationViewController setWord:self.selectedWord];
        if (self.playWordsOnSelection) {
            [segue.destinationViewController setPlayWordsOnSelection:self.playWordsOnSelection];
        }
        if (self.customBackgroundColor) {
            [segue.destinationViewController setCustomBackgroundColor:self.customBackgroundColor];
        }
        if (self.useDyslexieFont) {
            [segue.destinationViewController setUseDyslexieFont:self.useDyslexieFont];
        }
        [segue.destinationViewController setDelegate:self];
    }
}

- (void) wordSelectedAtIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView
{
    
    self.selectedWord = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if ([self getSplitViewWithDisplayWordViewController]) { //iPad
        DisplayWordViewController *dwvc = [self getSplitViewWithDisplayWordViewController];
        dwvc.word = self.selectedWord;
        if (self.playWordsOnSelection) {
            [dwvc playAllWords:self.selectedWord.pronunciations];
        }
        [self callAppingtonWithViewDetails];   //all iPad appington call handled in DictionaryTableViewController class
    } else { //iPhone (passing playWordsOnSelection handled in prepare for Segue)
        [self performSegueWithIdentifier:@"Word Selected" sender:self.selectedWord];
    }
}

- (DisplayWordViewController *)getSplitViewWithDisplayWordViewController
{
    id dwvc = [self.splitViewController.viewControllers lastObject];
    if (![dwvc isKindOfClass:[DisplayWordViewController class]]) {
        dwvc = nil;
    }
    return dwvc;
}

- (void) DisplayWordViewController:(DisplayWordViewController *)sender homonymSelectedWith:(NSString *)spelling
{
    NSLog(@"homonymSelected with spelling = %@",spelling);      //need to cancel search when this happens TODO maybe - or at least scroll to it if in view
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"spelling = %@",spelling];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.activeDictionary.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] != 1)) {
        //handle error
    } else if ([matches count] == 1) {
        Word *homonymn = [matches lastObject];
        NSIndexPath *indexPathOfHomonymn = [self.fetchedResultsController indexPathForObject:homonymn];
        if (![self getSplitViewWithDisplayWordViewController]) { //iPhone
            //pop old word off navigation controller
            [self.navigationController popViewControllerAnimated:NO]; //Not animated as this is just preparing the Navigation Controller stack for the new word to be pushed on.
        }
    
        if (self.searchDisplayController.isActive) {
            
            if ([self.searchFetchedResultsController.fetchedObjects containsObject:homonymn]) {
                NSIndexPath *indexPathOfSelectedWord = [self.searchFetchedResultsController indexPathForObject:homonymn];
                [self.searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPathOfSelectedWord animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            } else {
                NSIndexPath *selectedCell = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:selectedCell animated:NO];
            }
            
        } else {
            [self.tableView selectRowAtIndexPath:indexPathOfHomonymn animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        [self wordSelectedAtIndexPath:indexPathOfHomonymn fromTableView:self.tableView];
    }
}

-(void)displayViewWhileProcessing:(NSBundle *)dictionary correctionsOnly:(BOOL)corrections
{
    // instanciate a Dictionary Setup controller which starts processing a dictionary
    self.dsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Processing Dictionary View"];
    BOOL processing = [DictionarySetupViewController use:self.dsvc toProcess:dictionary passDictionaryAround:self.view.window.rootViewController setDelegate:self correctionsOnly:corrections];
    
    if ([self getSplitViewWithDisplayWordViewController] && processing) { //iPad show DictionarySetupViewController in popover
    
        UIPopoverController *dsPopoverC = [[UIPopoverController alloc] initWithContentViewController:self.dsvc];
        self.popoverController = dsPopoverC;
        dsPopoverC.popoverContentSize = CGSizeMake(457, 247);
        NSLog(@"self.view.window = %@", self.view.window);
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if ((orientation == UIDeviceOrientationPortrait) || 
            (orientation == UIDeviceOrientationPortraitUpsideDown)) {
            [dsPopoverC presentPopoverFromRect:CGRectMake(self.view.window.frame.size.width/2, 400, 1, 1) inView:self.splitViewController.view permittedArrowDirections:0 animated:YES];
            NSLog(@"portrait");
        } else if ((orientation == UIDeviceOrientationLandscapeLeft) || 
                   (orientation == UIDeviceOrientationLandscapeRight)) {
            [dsPopoverC presentPopoverFromRect:CGRectMake(self.view.window.frame.size.height/2, 300, 1, 1) inView:self.splitViewController.view permittedArrowDirections:0 animated:YES];
            NSLog(@"landscape");
        }
        
        [dsPopoverC setDelegate:self];
    } else if (processing) { //iPhone different ways to show UI... replaced with its own UI Nav Controller class SetupOrMainViewController
 //       [self.navigationController pushViewController:self.dsvc animated:YES];
 //       [self presentViewController:self.dsvc animated:YES completion:nil];
        [ErrorsHelper showExplanationForFrozenUI];  //never called now used during development
    }

}

+ (void) showAddWordRequested:(NSString *)dictionaryTitle and:(NSString *)requestedText     //used if no results and user requests words to be added to dictionary
{
    UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Word Requested"
                                                        message:[NSString stringWithFormat:@"Thank you for asking for '%@' to be added to '%@'.\nDD with work to included it in an update soon.",requestedText, dictionaryTitle]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertUser sizeToFit];
    [alertUser show];
    

    //track event with GA
    [GlobalHelper trackEventWithCategory:@"uiAction_WordAddRequest" withAction:dictionaryTitle withLabel:requestedText withValue:[NSNumber numberWithInt:1]];
}



@end
