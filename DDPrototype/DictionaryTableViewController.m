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


@interface DictionaryTableViewController ()

@end

@implementation DictionaryTableViewController

@synthesize activeDictionary = _activeDictionary;

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
        self.title = [activeDictionary.fileURL lastPathComponent];
    }
}
         


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    if ([self splitViewWithDisplayWordViewController]) {
        DisplayWordViewController *dwvc = [self splitViewWithDisplayWordViewController];
        Word *selectedWord = [self.fetchedResultsController objectAtIndexPath:indexPath];
        dwvc.word = selectedWord;
//        dwvc.spelling.text = selectedWord.spelling;
        
        //work out path for Sound - should come from Word *
        NSURL *fileURL = [DictionaryHelper fileURLForSpelling:selectedWord.spelling];
        
        if (fileURL)
        {
            dwvc.listenButton.enabled = YES;
            [dwvc listenToWord:self];
        } else {
            dwvc.listenButton.enabled = YES;        
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

@end
