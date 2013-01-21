//
//  SettingsTableViewController.m
//  DDPrototype
//
//  Created by Alison Kline on 8/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "NSUserDefaultKeys.h"
#import <MessageUI/MessageUI.h>
#import "htmlPageViewController.h"
#import "GAI.h"

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *playOnSelectionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionLable;
@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;

@end

@implementation SettingsTableViewController
@synthesize playOnSelectionSwitch = _playOnSelectionSwitch;
@synthesize versionLable = _versionLable;
@synthesize selectedCellIndexPath = _selectedCellIndexPath;

- (void)viewDidAppear:(BOOL)animated
{   
    self.playOnSelectionSwitch.on = [[NSUserDefaults standardUserDefaults] floatForKey:PLAY_WORDS_ON_SELECTION];
    [super viewDidAppear:animated];
    
    //track with GA manually avoid subclassing UIViewController - will get many with iPhone and few with iPad
    NSString *viewNameForGA = [NSString stringWithFormat:@"Settings"];
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:viewNameForGA];
    NSLog(@"View sent to GA %@", viewNameForGA);
}

- (IBAction)playOnSelectionSwitchChanged:(UISwitch *)sender 
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:PLAY_WORDS_ON_SELECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *switchSetting = sender.on ? @"ON" : @"OFF";
    [tracker sendEventWithCategory:@"uiAction_Setting" withAction:@"playOnSelectionChanged" withLabel:switchSetting withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Setting playOnSetlectionChanged %@",switchSetting);
}

- (NSString*) version {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ build %@", version, build];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.versionLable.text = [NSString stringWithFormat:@"Version: %@",[self version]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setPlayOnSelectionSwitch:nil];
    [self setVersionLable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
    NSLog(@"Indexpath of Selected Cell = %@", indexPath);
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedCellIndexPath = indexPath;
    NSLog(@"selectedCell Tag = %d", selectedCell.tag);
    if (selectedCell.tag  == 3) {
        [self sendEmail:selectedCell];
    } else if (selectedCell.tag == 1) {
        [self performSegueWithIdentifier:@"display WebView" sender:selectedCell];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //used set up webView depending upon which item was selected.
    if ([segue.identifier isEqualToString:@"display WebView"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            [segue.destinationViewController setStringForTitle:cell.textLabel.text];
            
        if ([self.selectedCellIndexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:2]]) {
            //about needed
            [segue.destinationViewController setStringForTitle:@"About"]; //overriding cell label for cleaner UI
            NSString *path = [[NSBundle mainBundle] pathForResource:@"resources.bundle/Images/settings_about" ofType:@"html"];
            [segue.destinationViewController setUrlToDisplay:[NSURL fileURLWithPath:path]];
            
        } else if ([self.selectedCellIndexPath isEqual:[NSIndexPath indexPathForItem:2 inSection:2]]) {
            //small print selected.
            NSString *path = [[NSBundle mainBundle] pathForResource:@"resources.bundle/Images/settings_smallPrint" ofType:@"html"];
            [segue.destinationViewController setUrlToDisplay:[NSURL fileURLWithPath:path]];
        }
    }
    }
}


#pragma mark - Sending an Email

- (IBAction) sendEmail: (id) sender
{
	BOOL	bCanSendMail = [MFMailComposeViewController canSendMail];
//    BOOL	bCanSendMail = NO; //for testing the no email alert
    
    //track with GA manually avoid subclassing UIViewController
    NSString *viewNameForGA = [NSString stringWithFormat:@"SendEmail triggered"];
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:viewNameForGA];
    NSLog(@"View sent to GA %@", viewNameForGA);
    
	if (!bCanSendMail)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Email Account"
                                                        message: @"You must set up an email account for your device before you can send mail."
                                                       delegate: nil
                                              cancelButtonTitle: nil
                                              otherButtonTitles: @"OK", nil];
		[alert show];
	}
	else
	{
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        
		picker.mailComposeDelegate = self;
        
		[picker setToRecipients: [NSArray arrayWithObject: @"dydifeedback@gmail.com"]];
		[picker setSubject: @"Dy-Di Feedback"];
		[picker setMessageBody: [NSString stringWithFormat:@"What do you like about Dy-Di? \r\n\r\n What would you like to see improved? \r\n\r\n What new features would be key for you? \r\n\r\n Any other thoughts? \r\n\r\n\r\n\r\n Thank you so much for taking the time to give us your feedback.\r\n\r\n Best regards Alison.\r\n (from Version: %@)",[self version]] isHTML: NO];
        
		[self presentModalViewController: picker animated: YES];
	}
    [self.tableView deselectRowAtIndexPath:self.selectedCellIndexPath animated:YES];
}

- (void) mailComposeController: (MFMailComposeViewController *) controller
           didFinishWithResult: (MFMailComposeResult) result
                         error: (NSError *) error
{
	[self dismissModalViewControllerAnimated: YES];
}


@end
