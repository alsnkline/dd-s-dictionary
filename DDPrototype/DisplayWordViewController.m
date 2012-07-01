//
//  DisplayWordViewController.m
//  DDPrototype
//
//  Created by Alison Kline on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisplayWordViewController.h"
#import "DictionaryHelper.h"
#import <AudioToolbox/AudioToolbox.h>  //for system sounds
#import <AVFoundation/AVAudioPlayer.h> //for audioPlayer

@interface DisplayWordViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation DisplayWordViewController
@synthesize word = _word;
@synthesize spelling = _spelling;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize listenButton = _listenButton;
@synthesize audioPlayer = _audioPlayer;


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
//    return UIInterfaceOrientationIsPortrait(orientation);
    return NO;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Dictionary";    //need to localise
    self.splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController 
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)listenToWord:(id)sender 
{   
// can't use system sounds as needs a .caf or .wav - too big.
    
    NSURL *fileURL = [DictionaryHelper fileURLForSpelling:self.spelling.text];
    
    // Trying to figure out if I have my paths and URL's right!
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    BOOL fileFound = [localFileManager fileExistsAtPath:[fileURL path]];
    NSLog(@"fileFound for URL: %@", fileFound ? @"YES" : @"NO");
    
    NSError *error = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    self.audioPlayer = newPlayer;
 
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer play];

}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)playedSuccessfully 
{
    self.audioPlayer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view. 
    
    //bundle image access test - note device is case sensitive
//    NSString *imgName = @"resources.bundle/Images/1340506912_sound_high.png";
//    UIImage *myImage = [UIImage imageNamed:imgName];
//    UIImageView *newImageView = [[UIImageView alloc] initWithImage:myImage];
//    [self.view addSubview:newImageView];
    
    self.word ? (self.listenButton.enabled = YES) : (self.listenButton.enabled = NO);
    
}

- (void)viewDidUnload
{
    [self setSpelling:nil];
    [self setToolbar:nil];
    [self setListenButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
