//
//  FilteredDictionaryTableViewController.m
//  DDPrototype
//
//  Created by Alison KLINE on 5/13/13.
//
//

#import "FilteredDictionaryTableViewController.h"
#import "NSUserDefaultKeys.h"
#import "Word+Create.h"
#import "DisplayWordViewController.h"
#import "double_metaphone.h"

@interface FilteredDictionaryTableViewController () <DisplayWordViewControllerDelegate>
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic) BOOL useDyslexieFont;
@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic, strong) Word *selectedWord;

@end

@implementation FilteredDictionaryTableViewController

@synthesize activeDictionary = _activeDictionary;
@synthesize playWordsOnSelection = _playWordsOnSelection;
@synthesize useDyslexieFont = _useDyslexieFont;
@synthesize customBackgroundColor = _customBackgroundColor;
@synthesize selectedWord = _selectedWord;
@synthesize filterPredicate = _filterPredicate;
@synthesize stringForTitle = _stringForTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"spelling" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    if (self.filterPredicate) [request setPredicate:self.filterPredicate];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.activeDictionary.managedObjectContext
                                                                          sectionNameKeyPath:@"fetchedResultsSection"
                                                                                   cacheName:nil];
}


- (void)setActiveDictionary:(UIManagedDocument *)activeDictionary
{
    if (_activeDictionary != activeDictionary) {
        _activeDictionary = activeDictionary;
        
        [self setupFetchedResultsController];
        
        if (self.isViewLoaded && self.view.window) {
            //viewController is visible track with GA allowing iPad also useful on iPhone when setup takes time stats to show which dict got loaded.
            [self tellPartnersTableIsVisible];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self makeViewRespectDefaults]; //needed in case defaults have changed since last shown
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = self.stringForTitle;
   
    [self makeViewRespectDefaults]; // needed here to prevent white 'flashing' not sure why setting background color and font in cellForRowAtIndex didn't fix the problem.
}

- (void) tellPartnersTableIsVisible
{
    //need to implement tracking to GA and Appington.
    
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    count = [[self.fetchedResultsController sections] count];

    NSLog(@"table section count: %d", count);
    
    return count;
    //    return [[self alphabet] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger numberOfRows = 0;
        
    NSFetchedResultsController *fetchController = self.fetchedResultsController;
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }

    //    NSLog(@"table section row count: %d", numberOfRows);
    return numberOfRows;
    
}

//section title method possibly

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Filtered Word";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
//    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] isSearch:!(tableView == self.tableView)  configureCell:cell atIndexPath:indexPath];
    
    cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Regular" size:20] : [UIFont boldSystemFontOfSize:20];
    cell.backgroundColor = self.customBackgroundColor;
    
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSArray *doubleMetaphoneCodes = [GlobalHelper doubleMetaphoneCodesFor:word.spelling];
    
    cell.textLabel.text = word.spelling;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", word.spelling, [doubleMetaphoneCodes lastObject]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self wordSelectedAtIndexPath:(NSIndexPath *)indexPath fromTableView:tableView];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(Word *)sender
{
    //used for iphone only
    if ([segue.identifier isEqualToString:@"Fun Word Selected"]) {
        [segue.destinationViewController setWord:self.selectedWord];
        if (self.playWordsOnSelection) [segue.destinationViewController setPlayWordsOnSelection:self.playWordsOnSelection];
        if (self.customBackgroundColor) [segue.destinationViewController setCustomBackgroundColor:self.customBackgroundColor];
        if (self.useDyslexieFont) [segue.destinationViewController setUseDyslexieFont:self.useDyslexieFont];
        [segue.destinationViewController setDelegate:self];
    }
}

- (void) wordSelectedAtIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView
{
    
    self.selectedWord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self getSplitViewWithDisplayWordViewController]) { //iPad
        DisplayWordViewController *dwvc = [self getSplitViewWithDisplayWordViewController];
        dwvc.word = self.selectedWord;
        if (self.playWordsOnSelection) {
            [dwvc playAllWords:self.selectedWord.pronunciations];
        }
    } else { //iPhone (passing playWordsOnSelection handled in prepare for Segue)
        [self performSegueWithIdentifier:@"Fun Word Selected" sender:self.selectedWord];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeViewRespectDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set and use value of backgroundColour
    if (self.view.backgroundColor != self.customBackgroundColor) {
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
    }
    
    //set and use value of playWordsOnSelection and useDyslexieFont
    if (self.playWordsOnSelection != [defaults boolForKey:PLAY_WORDS_ON_SELECTION]) {
        self.playWordsOnSelection = [defaults boolForKey:PLAY_WORDS_ON_SELECTION];
    }
    
    //set and use value of useDyslexieFont
    if (self.useDyslexieFont != [defaults boolForKey:USE_DYSLEXIE_FONT]) {
        self.useDyslexieFont = [defaults boolForKey:USE_DYSLEXIE_FONT];
        [self.tableView reloadData];
    }

}

@end
