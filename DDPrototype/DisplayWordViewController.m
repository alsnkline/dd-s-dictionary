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
#import "Word.h"
#import "Pronunciation.h"

@interface DisplayWordViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSArray *soundsToPlay;

@end

@implementation DisplayWordViewController
@synthesize word = _word;
@synthesize delegate = _delegate;
@synthesize spelling = _spelling;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize listenButton = _listenButton;
@synthesize heteronymListenButton = _heteronymListenButton;
@synthesize wordView = _wordView;
@synthesize homonymButton = _homonymButton;
@synthesize homonym2Button = _homonym2Button;
@synthesize homonym3Button = _homonym3Button;
@synthesize homonym4Button = _homonym4Button;
@synthesize audioPlayer = _audioPlayer;
@synthesize soundsToPlay = _soundsToPlay;


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

-(void)setWord:(Word *)word
{
    if (_word != word) {
        _word = word;
        [self manageListenButtons];
        [UIView transitionWithView:self.wordView duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve 
                        animations:^ {
                            self.spelling.text = word.spelling;
                        }
                        completion:nil];
    }
}

- (void) manageListenButtons
{
    NSSet *pronunciations = self.word.pronunciations;
    
    if ([pronunciations count] == 1) {
        self.heteronymListenButton.hidden = YES;
        self.homonym3Button.hidden = YES;
        self.homonym4Button.hidden = YES;
        self.listenButton.hidden = NO;
        
        self.listenButton.frame = CGRectMake((self.listenButton.superview.frame.size.width/2 - self.listenButton.frame.size.width/2), self.listenButton.frame.origin.y, self.listenButton.frame.size.width, self.listenButton.frame.size.height);
        
        Pronunciation *pronunciation = [[pronunciations allObjects] lastObject];
        NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.unique];
        fileURL? (self.listenButton.enabled = YES) : (self.listenButton.enabled = NO);
                
        [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonymButton and:self.homonym2Button UnderListenButton:self.listenButton];
        
    } else if ([pronunciations count] == 2) {
        self.heteronymListenButton.hidden = NO;
        self.listenButton.hidden = NO;
        
        self.listenButton.frame = CGRectMake(56, self.listenButton.frame.origin.y, self.listenButton.frame.size.width, self.listenButton.frame.size.height);
        
        for (Pronunciation *pronunciation in pronunciations) {
            NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.unique];
            if ([pronunciation.unique hasSuffix:[NSString stringWithFormat:@"1"]]) {
                fileURL? (self.listenButton.enabled = YES) : (self.listenButton.enabled = NO);
                [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonymButton and:self.homonym2Button UnderListenButton:self.listenButton];
            }
            if ([pronunciation.unique hasSuffix:[NSString stringWithFormat:@"2"]]) {
                fileURL? (self.heteronymListenButton.enabled = YES) : (self.heteronymListenButton.enabled = NO);
                [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonym3Button and:self.homonym4Button UnderListenButton:self.heteronymListenButton];
            }
        }
    } else {
        self.listenButton.enabled = NO;
    }
}

    
- (void) manageHomonymsOfPronunciation:(Pronunciation *)pronunciation WithButtons:(UIButton *)button1 and:(UIButton *)button2 UnderListenButton:(UIButton *)listenbutton
{
    NSSet *homonyms = pronunciation.spellings;
        
    if ([homonyms count] == 1) {
        button1.hidden = YES;
        button2.hidden = YES;
    } else if ([homonyms count] > 1) {
        int counter = 0;
        for (Word *word in homonyms) {
            if (word == self.word) continue;
            counter += 1;
            if (counter == 1) {
                button1.hidden = NO;
                [button1 setTitle:word.spelling forState:UIControlStateNormal];
                [button1 sizeToFit];
                CGRect frame = CGRectMake(listenbutton.frame.origin.x - (button1.frame.size.width/2 - listenbutton.frame.size.width/2), button1.frame.origin.y, button1.frame.size.width, button1.frame.size.height);
                button1.frame = frame;
                
                //CGRectMake((button1.superview.frame.size.width/2 - button1.frame.size.width/2), button1.frame.origin.y, button1.frame.size.width, button1.frame.size.height); 
            }
            if (counter == 2) {
                button2.hidden = NO;
                [button2 setTitle:word.spelling forState:UIControlStateNormal];
                [button2 sizeToFit];
                CGRect frame = CGRectMake(listenbutton.frame.origin.x - (button2.frame.size.width/2 - listenbutton.frame.size.width/2), button2.frame.origin.y, button2.frame.size.width, button2.frame.size.height);
                button2.frame = frame;
                //CGRectMake((button2.superview.frame.size.width/2 - button2.frame.size.width/2), button2.frame.origin.y, button2.frame.size.width, button2.frame.size.height);
            }
        }
    }
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


- (void)playAllWords:(NSSet *)pronunciations
{
    if ([pronunciations count] == 1) {
        for (Pronunciation *pronunciation in pronunciations) {
            [self playWord:pronunciation];
        };
    } else {
        NSMutableArray *pronunciationsArray = [[pronunciations allObjects] mutableCopy];
        self.soundsToPlay = pronunciationsArray;
        NSLog(@"started to play first word");
        Pronunciation *pronunciationToPlay = [self.soundsToPlay lastObject];
        [self playWord:pronunciationToPlay];
    }
}

- (void)playWord:(Pronunciation *)pronunciation
{
    // can't use system sounds as needs a .caf or .wav - too big.
    
    NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.unique];
    
    NSError *error = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    self.audioPlayer = newPlayer;
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setDelegate:self];
    NSLog(@"started to play a word");
    [self.audioPlayer play];
}

- (IBAction)listenToWord:(UIButton *)sender 
{   

    NSSet *pronunciations = self.word.pronunciations;
    
    for (Pronunciation *pronunciation in pronunciations) {
        NSString *unique = pronunciation.unique;
        if (([pronunciations count] > 1 && [unique hasSuffix:[NSString stringWithFormat:@"%i",sender.tag]]) || ([pronunciations count] == 1)) {
            [self playWord:pronunciation];
        }
    }
}

- (IBAction)homoymnButtonPressed:(UIButton *)sender 
{
    NSString *spelling = sender.titleLabel.text;
    //send to delegate
    [self.delegate DisplayWordViewController:self homonymSelectedWith:spelling];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)playedSuccessfully 
{
    self.audioPlayer = nil;
    NSLog(@"finished playing a word %@", playedSuccessfully? @"successfully" : @"with error");
    
    if ([self.soundsToPlay count] > 0) {
        NSMutableArray *pronunciationsArray = [NSMutableArray arrayWithArray:self.soundsToPlay];
        [pronunciationsArray removeLastObject];
        self.soundsToPlay = pronunciationsArray;
        
        if ([self.soundsToPlay count] > 0) {
            [self playWord:[self.soundsToPlay lastObject]];
        }
    }
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
    [self setWord:nil];
    [self setSpelling:nil];
    [self setToolbar:nil];
    [self setListenButton:nil];
    [self setHeteronymListenButton:nil];
    [self setWordView:nil];
    [self setHomonymButton:nil];
    [self setHomonym2Button:nil];
    [self setHomonym3Button:nil];
    [self setHomonym4Button:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
