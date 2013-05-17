//
//  FunWithWordsTableViewController.m
//  DDPrototype
//
//  Created by Alison KLINE on 5/13/13.
//
//

#import "FunWithWordsTableViewController.h"
#import "NSUserDefaultKeys.h"
#import "FilteredDictionaryTableViewController.h"
#import "Group+Create.h"
#import "GroupHelper.h"

@interface FunWithWordsTableViewController ()

@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic) BOOL useDyslexieFont;
@property (nonatomic, strong) NSArray *wordGroups;

@end

@implementation FunWithWordsTableViewController

@synthesize activeDictionary = _activeDictionary;
@synthesize customBackgroundColor = _customBackgroundColor;
@synthesize useDyslexieFont = _useDyslexieFont;
@synthesize wordGroups = _wordGroups;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)wordGroups
{
    NSArray *groups = _wordGroups;
    
    if (_wordGroups == nil) {
        //setup query of Groups in core Data
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"LIKE *"];
//        
//        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSError *error = nil;
        groups = [self.activeDictionary.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (LOG_PREDICATE_RESULTS) {
            NSLog(@"number of matches = %d", [groups count]);
            for (Group *group in groups) {
                NSLog(@"found: %@", group.displayName);
            }
        }
        _wordGroups = groups;
    }
    return groups;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set value of backgroundColor
    NSNumber *customBackgroundColorHue = [NSNumber numberWithFloat:[defaults floatForKey:BACKGROUND_COLOR_HUE]];
    NSNumber *customBackgroundColorSaturation = [NSNumber numberWithFloat:[defaults floatForKey:BACKGROUND_COLOR_SATURATION]];
    
    self.customBackgroundColor = [UIColor colorWithHue:[customBackgroundColorHue floatValue]  saturation:[customBackgroundColorSaturation floatValue] brightness:1 alpha:1];
    if ([self.tableView indexPathForSelectedRow]) {
        // we have to deselect
        NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:selectedCell animated:NO];
    }
    [self setCellBackgroundColor];
    
    //set useDyslexieFont if necessary
    if (self.useDyslexieFont != [defaults boolForKey:USE_DYSLEXIE_FONT]) {
        self.useDyslexieFont = [defaults boolForKey:USE_DYSLEXIE_FONT];
        [self setVisibleCellsCellTextLabelFont];
    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // see if Groups have been processed and process if they have not been
    [self processGroupsFile];
    
}

- (void) setCellBackgroundColor
{
    NSArray *tableCells = self.tableView.visibleCells;
    for (UITableViewCell *cell in tableCells)
    {
        cell.backgroundColor = self.customBackgroundColor;
    }
    
}

- (void) setVisibleCellsCellTextLabelFont
{
    NSArray *tableCells = self.tableView.visibleCells;
    for (UITableViewCell *cell in tableCells)
    {
        [self setTextLabelFontForCell:cell];
    }
    
}

- (void) setTextLabelFontForCell:(UITableViewCell *)cell
{
    cell.textLabel.font = self.useDyslexieFont ? [UIFont fontWithName:@"Dyslexiea-Regular" size:18] : [UIFont boldSystemFontOfSize:20];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section //tweeked when I thought I could mix static and dynamic tables
//{
//    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
//    if (section == 1) count = [self.wordGroups count];
//    return count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (section == 1) {
        Group *groupForCell = [self.wordGroups objectAtIndex:row];
        cell.textLabel.text = groupForCell.displayName;
    }
    
    // Configure the cell...
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.customBackgroundColor;
    [self setTextLabelFontForCell:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //need to implement push segue called "Fun Group Selected"
    
    NSLog(@"Indexpath of Selected Cell = %@", indexPath);
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"Fun Group Selected" sender:selectedCell];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Fun Group Selected"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSLog(@"Cell Label = %@", cell.textLabel.text);
            
            NSInteger switchValue;  //not really used yet, set up incase options got out of control
            NSString *stringForPredicate = @"";
            NSPredicate *selectionPredicate;
            
            if ([cell.textLabel.text isEqualToString:@"homophones"]) {
                switchValue = 0;
                selectionPredicate = [NSPredicate predicateWithFormat:@"isHomophone = YES"];
            } else if ([cell.textLabel.text isEqualToString:@"heteronyms"]) {
                switchValue = 1;
                selectionPredicate = [NSPredicate predicateWithFormat:@"pronunciations.@count > 1"];
                // from http://www.raywenderlich.com/14742/core-data-on-ios-5-tutorial-how-to-work-with-relations-and-predicates
//            } else if ([cell.textLabel.text isEqualToString:@"'tion'"]) {
//                switchValue = 2;
//                stringForPredicate = @"tion";
//            } else if ([cell.textLabel.text isEqualToString:@"'ould'"]) {
//                switchValue = 3;
//                stringForPredicate = @"ould";
//            } else if ([cell.textLabel.text isEqualToString:@"'ight'"]) {
//                switchValue = 4;
//                stringForPredicate = @"ight";
            } else {
                switchValue = 5;
                NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"'"];
                stringForPredicate = [cell.textLabel.text stringByTrimmingCharactersInSet:charactersToRemove];
            }
            
            if (![stringForPredicate isEqualToString:@""]) selectionPredicate = [NSPredicate predicateWithFormat:@"%@ IN SELF.inGroups.displayName", cell.textLabel.text];
                //selectionPredicate = [NSPredicate predicateWithFormat:@"SELF.spelling contains[cd] %@", stringForPredicate];
            
            //selectionPredicate = [NSPredicate predicateWithFormat:@"inGroups.@count > 0"]; //worked
            //selectionPredicate = [NSPredicate predicateWithFormat:@"%@ IN SLEF.inGroups.displayName", cell.textLabel.text];

            
            NSLog(@"predicate = %@", selectionPredicate);
            if (LOG_PREDICATE_RESULTS) [GlobalHelper testWordPredicate:selectionPredicate inContext:self.activeDictionary.managedObjectContext];
            
            [segue.destinationViewController setStringForTitle:cell.textLabel.text];
            [segue.destinationViewController setFilterPredicate:selectionPredicate];
            [segue.destinationViewController setActiveDictionary:self.activeDictionary];
            [segue.destinationViewController setCustomBackgroundColor:self.customBackgroundColor];
            [segue.destinationViewController setUseDyslexieFont:self.useDyslexieFont];
            
        }
    }
}

- (void)processGroupsFile
{
    if ([self isNewGroupsJSONFileVersion]) {
        NSArray *json = [GroupHelper contentsOfLatestJSONGroupsFile];
        [Group processGroupsFile:json inManagedObjectContext:self.activeDictionary.managedObjectContext];
        [self setProcessedGroupsJSONFileVersion];
    }
}

// candidate for refactoring as these two methods are very similar to 2 other pairs used to manage APPLICATION_VERSION and PROCESSED_DOC_SCHEMA_VERSION_205
- (BOOL) isNewGroupsJSONFileVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //get version from NSUserDefaults and the current code
    NSString *version = [GroupHelper latestGroupsJSONfileVersionNumber];
    NSString *storedVersion = [defaults stringForKey:GROUPS_JSON_DOC_PROCESSED_VERSION];
    NSLog(@"This version %@, stored version %@", version, storedVersion);
    
    BOOL returnValue = ![version isEqualToString:storedVersion];
    NSLog(@"in New Groups JSON File Version: %@", returnValue ? @"YES" : @"NO");
    
    return returnValue;
}

- (void) setProcessedGroupsJSONFileVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [GroupHelper latestGroupsJSONfileVersionNumber];
    //set version in NSUserDefaults so next time new version code doesn't run
    [defaults setObject:version forKey:GROUPS_JSON_DOC_PROCESSED_VERSION];
    [defaults synchronize];
}





@end
