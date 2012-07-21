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


@interface DictionaryTableViewController () <DisplayWordViewControllerDelegate, UIPopoverControllerDelegate, DictionarySetupViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *autoControlButton;
@property (nonatomic) BOOL playWordsOnSelection;
@property (nonatomic, strong) UIPopoverController *popoverController;  //used to track the start up popover

@end

@implementation DictionaryTableViewController
@synthesize autoControlButton = _autoControlButton;
@synthesize activeDictionary = _activeDictionary;
@synthesize playWordsOnSelection = _playWordsOnSelection;
@synthesize popoverController;

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
    [dwvc setDelegate:self];
    self.playWordsOnSelection = NO;

}

-(void)viewDidAppear:(BOOL)animated
{
    //see if there are any dictionary's already processed
    NSArray *dictionariesAvailable = [DictionaryHelper currentContentsOfdictionaryDirectory];
    NSLog(@"dictionariesAvailable = %@", dictionariesAvailable);
    
    if ([dictionariesAvailable count] == 1) {
        NSURL *dictionaryURL = [dictionariesAvailable lastObject];
        NSString *activeDictionaryName = [dictionaryURL lastPathComponent];
        NSLog(@"Opening the 1 dictionary available its name: %@", activeDictionaryName);
        [DictionarySetupViewController loadDictionarywithName:activeDictionaryName passAroundIn:self.view.window.rootViewController];  
        
    } else {
        
        NSBundle *dictionaryShippingWithApp = [DictionaryHelper defaultDictionaryBundle];
        [self displayPopoverWhileProcessing:dictionaryShippingWithApp];
        
    }
}

- (void)viewDidUnload
{
    [self setAutoControlButton:nil];
    [super viewDidUnload];
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
    [self.popoverController dismissPopoverAnimated:YES];
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

- (void) wordSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self splitViewWithDisplayWordViewController]) {
        DisplayWordViewController *dwvc = [self splitViewWithDisplayWordViewController];
        Word *selectedWord = [self.fetchedResultsController objectAtIndexPath:indexPath];
        dwvc.word = selectedWord;
        if (self.playWordsOnSelection) {
            [dwvc playAllWords:selectedWord.pronunciations];
        }
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
        [self.tableView selectRowAtIndexPath:indexPathOfHomonymn animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self wordSelectedAtIndexPath:indexPathOfHomonymn];
    }
}
- (IBAction)autoButtonPressed:(UIButton *)sender 
{
    if (self.playWordsOnSelection) {
        self.playWordsOnSelection = NO;
        self.autoControlButton.title = @"auto:NO";
    } else {
        self.playWordsOnSelection = YES;
        self.autoControlButton.title = @"auto:YES";
    }
}

-(void)displayPopoverWhileProcessing:(NSBundle *)dictionary
{
    // instanciate a Dictionary Setup controller and show its view in a popover
    DictionarySetupViewController *dsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Processing Dictionary View"];
    dsvc.dictionaryBundle = dictionary;
    [dsvc setDelegate:self];
    
    UIPopoverController *dsPopoverC = [[UIPopoverController alloc] initWithContentViewController:dsvc];
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

}

@end
