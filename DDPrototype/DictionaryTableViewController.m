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


@interface DictionaryTableViewController () <DisplayWordViewControllerDelegate, UIPopoverControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic) BOOL useDyslexieFont;
@property (nonatomic) BOOL settingUpDictionary;
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
@synthesize settingUpDictionary = _settingUpDictionary;
@synthesize customBackgroundColor = _backgroundColor;
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
    
    filterPredicate = [NSPredicate predicateWithFormat:@"SELF.spelling contains[cd] %@", searchString];
    
//    NSLog(@"searchString for Predicate: %@", searchString),
    NSLog(@"Predicate: %@", filterPredicate);
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    /*
     code used to test predicate during search development
     */
//    NSError *error = nil;
//    NSArray *matches = [self.activeDictionary.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"number of matches = %d", [matches count]);
//    for (Word *word in matches) {
//        NSLog(@"found: %@", word.spelling);
//    }
    //NSLog(@"matches for fetchRequest = %@", matches);
    
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
            NSString *viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: %@", self.title];
            [GlobalHelper sendView:viewNameForGA];
            [GlobalHelper callAppingtonMainTableViewShown];
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

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = self.customBackgroundColor;
    tableView.rowHeight = 55.0f; // setting row height on the search results table to match the main table.

    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"Dict Search Table Shown: %@", self.title];
    [GlobalHelper sendView:viewNameForGA];

}

-(void)viewDidAppear:(BOOL)animated
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
//    NSLog(@"TableView frame 4: %f, %f, %f, %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
//    
//    CGRect newFrame = CGRectMake(0, 44, self.tableView.bounds.size.width, self.tableView.bounds.size.height-44);
//    self.tableView.frame = newFrame;
//    
////    CGRect newFrame2 = CGRectMake(0, 0, self.tableView.tableHeaderView.bounds.size.width, 0);
////    self.tableView.tableHeaderView.bounds = newFrame2;
//    
//    NSLog(@"TableView frame 4: %f, %f, %f, %f", self.searchDisplayController.searchBar.frame.origin.x, self.searchDisplayController.searchBar.frame.origin.y, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
//    NSLog(@"TableView frame 4: %f, %f, %f, %f", self.searchDisplayController.searchResultsTableView.bounds.origin.x, self.searchDisplayController.searchResultsTableView.bounds.origin.y, self.searchDisplayController.searchResultsTableView.bounds.size.width, self.searchDisplayController.searchResultsTableView.bounds.size.height);
//    NSLog(@"searchbar superview = %@", self.searchDisplayController.searchBar.superview);
//    NSLog(@"tableView superview = %@", self.tableView.superview);
//
//    
//    [self.searchDisplayController.searchBar removeFromSuperview];
//    [self.tableView.superview addSubview:self.searchDisplayController.searchBar];
//    CGRect anotherNewFrame = CGRectMake(0, 0, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
//    self.searchDisplayController.searchBar.frame = anotherNewFrame;
//    self.searchDisplayController.searchResultsTableView.frame = anotherNewFrame;
//    
//    NSLog(@"TableView frame 5: %f, %f, %f, %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set value of backgroundColour
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
    self.playWordsOnSelection = [defaults floatForKey:PLAY_WORDS_ON_SELECTION];
    if (self.useDyslexieFont != [defaults floatForKey:USE_DYSLEXIE_FONT]) {
        self.useDyslexieFont = [defaults floatForKey:USE_DYSLEXIE_FONT];
        [self.tableView reloadData];
    }
    
    
    if (!self.activeDictionary) {  //this can't be in view did load - doesn't work as activeDictionary is still nil at that time = problems!
        self.settingUpDictionary = YES;
        [self setUpDictionary]; // used in iPad to trigger loading if necessary, in iphone it always triggers loading and passing the processed dictionary around.
    }
    
    //track with GA manually avoid subclassing UIViewController - will get many with iPhone and few with iPad
    NSString *viewNameForGA = nil;
    if (self.settingUpDictionary) {
        viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: setting up"];
    } else {
        viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: %@", self.title];
        //Call Appington event control
        [GlobalHelper callAppingtonMainTableViewShown];
    }
    [GlobalHelper sendView:viewNameForGA];

}

-(void) setUpDictionary
{
    //see if there are any dictionary's already processed
    
    DocProcessType processType = DOC_PROCESS_USE_EXSISTING;  //set a default that gets over riden by the whatProcessingIsNeeded method.
    NSString *availableDictionary = [DictionarySetupViewController whatProcessingIsNeeded:&processType];
    
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
                [DictionaryHelper cleanOutDictionaryDirectory];
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
    [super viewDidUnload];
    self.popoverController = nil;
    self.dsvc = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

    if(0){
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Search" withAction:self.title withLabel:searchText withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Search %@ %@", self.title, searchText);
    }
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
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

- (BOOL) searchHasNoResults:(NSFetchedResultsController *)fetchedResultsController
{
    BOOL hasNoResults = NO;
    
    if (self.searchDisplayController.isActive) {
        hasNoResults = [[fetchedResultsController fetchedObjects] count]? NO : YES;
    }
    
    return hasNoResults;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if ([self searchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
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
    if ([self searchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
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
    if ([self searchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
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


- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // your cell guts here
    
    cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Regular" size:20] : [UIFont boldSystemFontOfSize:20];
    
    if ([self searchHasNoResults:fetchedResultsController]) {
        cell.textLabel.text = @"";
        UIButton *button = [self getAddWordButton];
        [cell.contentView addSubview:button];
//        self.searchDisplayController.searchResultsTableView.rowHeight = 165.0f;
//        [self.searchDisplayController.searchResultsTableView reloadData]; //have to unwind the rowsize afterwards and this is not really where the cell height should be changing
        
//        cell.textLabel.text = @"Ask DD to add this word";
//        cell.textLabel.textColor = [UIColor blueColor];
//        cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Italic" size:40] : [UIFont fontWithName:@"Arial-BoldItalic" size:30];
//        cell.textLabel.font = [UIFont fontWithName:@"Dyslexiea-Italic" size:40];
//        cell.imageView.image = [UIImage imageNamed:@"resources.bundle/Images/dinoOnlyIcon.png"];
    } else {
        Word *word = [fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = word.spelling;
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
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];

    

//    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    if ([self searchHasNoResults:[self fetchedResultsControllerForTableView:tableView]]) {
        [self addwordButtonPressed];
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
    
    Word *selectedWord = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if ([self getSplitViewWithDisplayWordViewController]) { //iPad
        DisplayWordViewController *dwvc = [self getSplitViewWithDisplayWordViewController];
        dwvc.word = selectedWord;
        if (self.playWordsOnSelection) {
            [dwvc playAllWords:selectedWord.pronunciations];
        }
    } else { //iPhone (passing playWordsOnSelection handled in prepare for Segue)
        self.selectedWord = selectedWord;
        [self performSegueWithIdentifier:@"Word Selected" sender:selectedWord];
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
    NSLog(@"homonymSelected with spelling = %@",spelling);      //need to cancel search when this happens TODO 
    
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
        
        if (self.searchDisplayController.isActive) { //could enhance this further to check and see if the selected word is in the table and scroll if present not otherwise.
            NSIndexPath *selectedCell = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:selectedCell animated:NO];
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
    } else if (processing) { //iPhone different ways to show UI... replaced with extra UI Nav Controller class
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
//    id tracker = [GAI sharedInstance].defaultTracker;
//    [tracker sendEventWithCategory:@"uiAction_WordAddRequest" withAction:dictionaryTitle withLabel:requestedText withValue:[NSNumber numberWithInt:1]];
//    NSLog(@"Event sent to GA uiAction_WordAddRequest %@ %@", dictionaryTitle, requestedText);
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSDictionary *controlValues = @{
                                    @"event": @"level_end",
                                    @"level": @(2)};  //replace with Dictionary displayed in tableview.
    [GlobalHelper callAppingtonTriggerWithControlValues:controlValues];
}


@end
