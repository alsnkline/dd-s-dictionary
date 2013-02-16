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
#import "GAI.h"
#import "ErrorsHelper.h"


@interface DictionaryTableViewController () <DisplayWordViewControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic, strong) UIPopoverController *popoverController;  //used to track the start up popover in iPad
@property (nonatomic, strong) DictionarySetupViewController *dsvc; //used to track the start up vc in iPhone as there is no popover
@property (nonatomic, strong) Word *selectedWord;

@end

@implementation DictionaryTableViewController
@synthesize activeDictionary = _activeDictionary;
@synthesize playWordsOnSelection = _playWordsOnSelection;
@synthesize customBackgroundColor = _backgroundColor;
@synthesize popoverController;
@synthesize dsvc = _dsvc;
@synthesize selectedWord = _selectedWord;

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
        self.title = [DictionaryHelper dictionaryDisplayNameFrom:activeDictionary];
        
        if (self.isViewLoaded && self.view.window) {
            //viewController is visible track with GA allowing iPad stats to show which dict got loaded.
            NSString *viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: %@", self.title];
            [self trackView:viewNameForGA];
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
    
    DisplayWordViewController *dwvc = [self splitViewWithDisplayWordViewController];
    if (dwvc) {
        //iPad
        [dwvc setDelegate:self];
    } else {
        //if iPhone to prevent the back button flashing
        [self.navigationItem setHidesBackButton:YES];
    }
}

-(void)trackView:(NSString *)viewNameForGA
{
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:viewNameForGA];
    NSLog(@"View sent to GA %@", viewNameForGA);
}

-(void)viewDidAppear:(BOOL)animated
{
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
    
    //set value of playWordsOnSelection
    self.playWordsOnSelection = [defaults floatForKey:PLAY_WORDS_ON_SELECTION];
    
    if (!self.activeDictionary) {
         [self setUpDictionary]; // used in iPad to trigger loading if necessary, in iphone it always triggers loading and passing the processed dictionary around.
    }
    
    //track with GA manually avoid subclassing UIViewController - will get many with iPhone and few with iPad
    NSString *viewNameForGA = [NSString stringWithFormat:@"Dict Table Shown: %@", self.title];
    [self trackView:viewNameForGA];
}

-(void) setUpDictionary
{
    //see if there are any dictionary's already processed
    NSString *availableDictionary = [DictionarySetupViewController dictionaryAlreadyProcessed];
    
    if ([availableDictionary isEqualToString:@"More than 1"]) {
        
        [ErrorsHelper showErrorTooManyDictionaries];
        
    } else {

        if (availableDictionary) {

            NSLog(@"Opening the 1 dictionary available its name: %@", availableDictionary);
            NSLog(@"rootViewControler = %@", self.view.window.rootViewController);
            [DictionarySetupViewController loadDictionarywithName:availableDictionary passAroundIn:self.view.window.rootViewController];
            
        } else {
            
            NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
            [self displayViewWhileProcessing:dictionaryShippingWithApp];
            
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

- (void)DictionarySetupViewDidCompleteProcessingDictionary:(DictionarySetupViewController *)sender
{
    
    if ([self splitViewWithDisplayWordViewController]) {
        // iPad
        [self.popoverController dismissPopoverAnimated:YES];
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

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
////    return [[self.fetchedResultsController sections] count];
//    return [[self alphabet] count];
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    
//    return [self alphabet];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    
// //   return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
//    return 0;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [[self alphabet] objectAtIndex:section];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Word";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = word.spelling;
    
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
    [self wordSelectedAtIndexPath:(NSIndexPath *)indexPath];
    
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
        [segue.destinationViewController setDelegate:self];
    }
}

- (void) wordSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    Word *selectedWord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self splitViewWithDisplayWordViewController]) { //iPad
        DisplayWordViewController *dwvc = [self splitViewWithDisplayWordViewController];
        dwvc.word = selectedWord;
        if (self.playWordsOnSelection) {
            [dwvc playAllWords:selectedWord.pronunciations];
        }
    } else { //iPhone (passing playWordsOnSelection handled in prepare for Segue)
        self.selectedWord = selectedWord;
        [self performSegueWithIdentifier:@"Word Selected" sender:selectedWord];
    }
}

- (DisplayWordViewController *)splitViewWithDisplayWordViewController
{
    id dwvc = [self.splitViewController.viewControllers lastObject];
    if (![dwvc isKindOfClass:[DisplayWordViewController class]]) {
        dwvc = nil;
    }
    return dwvc;
}

- (void) DisplayWordViewController:(DisplayWordViewController *)sender homonymSelectedWith:(NSString *)spelling
{
    NSLog(@"homonymSelected with spelling = %@",spelling);
    
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
        if (![self splitViewWithDisplayWordViewController]) { //iPhone
            //pop old word off navigation controller
            [self.navigationController popViewControllerAnimated:NO]; //Not animated as this is just preparing the Navigation Controller stack for the new word to be pushed on.
            
        }
        [self.tableView selectRowAtIndexPath:indexPathOfHomonymn animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self wordSelectedAtIndexPath:indexPathOfHomonymn];
    }
}

-(void)displayViewWhileProcessing:(NSBundle *)dictionary
{
    // instanciate a Dictionary Setup controller which starts processing a dictionary
    self.dsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Processing Dictionary View"];
    [DictionarySetupViewController use:self.dsvc toProcess:dictionary passDictionaryAround:self.view.window.rootViewController setDelegate:self];
    
    if ([self splitViewWithDisplayWordViewController]) { //iPad show DictionarySetupViewController in popover
    
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
    } else { //iPhone different ways to show UI... replaced with extra UI Nav Controller class
 //       [self.navigationController pushViewController:self.dsvc animated:YES];
 //       [self presentViewController:self.dsvc animated:YES completion:nil];
        [ErrorsHelper showExplanationForFrozenUI];  //never called now used during development

    }

}



@end
