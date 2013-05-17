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

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set value of backgroundColor
    NSNumber *customBackgroundColorHue = [NSNumber numberWithFloat:[defaults floatForKey:BACKGROUND_COLOR_HUE]];
    NSNumber *customBackgroundColorSaturation = [NSNumber numberWithFloat:[defaults floatForKey:BACKGROUND_COLOR_SATURATION]];
    
    self.customBackgroundColor = [UIColor colorWithHue:[customBackgroundColorHue floatValue]  saturation:[customBackgroundColorSaturation floatValue] brightness:1 alpha:1];
    
    NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
    if (selectedCell) {
        // we have to deselect
        [self.tableView deselectRowAtIndexPath:selectedCell animated:NO]; //not animated so it takes effect immediately
    }
    [self setCellBackgroundColor];
    if (selectedCell) {
        [self.tableView selectRowAtIndexPath:selectedCell animated:NO scrollPosition:UITableViewScrollPositionNone]; //not animated so it takes effect immediately
        [self.tableView deselectRowAtIndexPath:selectedCell animated:YES]; //animated so the user sees it deselect gracefully.
    }
    
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
    self.clearsSelectionOnViewWillAppear = NO; //taking control manually so that the background color change can be done after this.
 
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger sectionNumber = 1;
    if ([self.wordGroups count] > 0) sectionNumber = 2;
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 2;
    if (section == 1) rowCount = [self.wordGroups count];
    return rowCount;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleForSection = nil;
    if (section == 0) {
        titleForSection = [NSString stringWithFormat:@"Word types:"];
    } else if (section == 1) {
        titleForSection = [NSString stringWithFormat:@"Word groups:"];
    }
    return titleForSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath]; //used for updating a static cell programatically
    
    static NSString *cellIdentifier = @"Fun With Words Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (section == 0) {
        if (row == 0) cell.textLabel.text = [NSString stringWithFormat:@"homophones"];
        if (row == 1) cell.textLabel.text = [NSString stringWithFormat:@"heteronyms"];
    }
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
            
            [segue.destinationViewController setCustomBackgroundColor:self.customBackgroundColor];
            [segue.destinationViewController setUseDyslexieFont:self.useDyslexieFont];
            [segue.destinationViewController setStringForTitle:cell.textLabel.text];
            [segue.destinationViewController setFilterPredicate:selectionPredicate];
            [segue.destinationViewController setActiveDictionary:self.activeDictionary];
            
            
        }
    }
}

- (void)processGroupsFile
{
    if ([GroupHelper isNewGroupsJSONFileVersion]) {
        NSArray *json = [GroupHelper contentsOfLatestJSONGroupsFile];
        [Group processGroupsFile:json inManagedObjectContext:self.activeDictionary.managedObjectContext];
        [GroupHelper setProcessedGroupsJSONFileVersionIsReset:NO];
        [DictionaryHelper saveDictionary:self.activeDictionary withImDoneDelegate:nil andDsvc:nil];
    }
}






@end
