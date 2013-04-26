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
#import <AVFoundation/AVFoundation.h> //for audioPlayer
#import "Word.h"
#import "Pronunciation.h"
#import "NSUserDefaultKeys.h"
#import <QuartzCore/QuartzCore.h>

@interface DisplayWordViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSArray *soundsToPlay;

@end

@implementation DisplayWordViewController
@synthesize word = _word;
@synthesize playWordsOnSelection = _playWordsOnSelection;
@synthesize useDyslexieFont = _useDyslexieFont;
@synthesize customBackgroundColor = _customBackgroundColor;
@synthesize delegate = _delegate;
@synthesize spelling = _spelling;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize listenButton = _listenButton;
@synthesize heteronymListenButton = _heteronymListenButton;
@synthesize wordView = _wordView;
@synthesize homonymButton1 = _homonymButton1;
@synthesize homonymButton2 = _homonymButton2;
@synthesize homonymButton3 = _homonymButton3;
@synthesize homonymButton4 = _homonymButton4;
@synthesize audioPlayer = _audioPlayer;
@synthesize soundsToPlay = _soundsToPlay;


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    
}

// setup of audioSession and audioSessionCategory moved to AppDelegate to enable Appington interation.


-(void)setWord:(Word *)word
{
    if (_word != word) {
        _word = word;
        [self setUpViewForWord:word];
    }
}

-(void)setCustomBackgroundColor:(UIColor *)customBackgroundColor
{
    if (_customBackgroundColor != customBackgroundColor) {
        _customBackgroundColor = customBackgroundColor;
        self.view.backgroundColor = self.customBackgroundColor;
        
        NSArray *myListenButtons = [NSArray arrayWithObjects:self.listenButton, self.heteronymListenButton, nil];
        [self setColorOfButtons:myListenButtons toColor:self.customBackgroundColor areHomonymButtons:NO];
        
        NSArray *myHomonymButtons = [NSArray arrayWithObjects:self.homonymButton1, self.homonymButton2, self.homonymButton3, self.homonymButton4, nil];
        [self setColorOfButtons:myHomonymButtons toColor:self.customBackgroundColor areHomonymButtons:YES];
        
    }
}

-(void)setUseDyslexieFont:(BOOL)useDyslexieFont
{
    if(_useDyslexieFont != useDyslexieFont) {
        _useDyslexieFont = useDyslexieFont;
        if (self.useDyslexieFont) {
            if ([self getSplitViewWithDisplayWordViewController]) { //in iPad
                [self.spelling setFont:[UIFont fontWithName:@"Dyslexiea-Regular" size:140]];
            } else { //in iphone
                [self.spelling setFont:[UIFont fontWithName:@"Dyslexiea-Regular" size:55]];
            }
            
            self.homonymButton1.titleLabel.font = [UIFont fontWithName:@"Dyslexiea-Regular" size:30];
            self.homonymButton2.titleLabel.font = [UIFont fontWithName:@"Dyslexiea-Regular" size:30];
            self.homonymButton3.titleLabel.font = [UIFont fontWithName:@"Dyslexiea-Regular" size:30];
            self.homonymButton4.titleLabel.font = [UIFont fontWithName:@"Dyslexiea-Regular" size:30];
        } else {
            if ([self getSplitViewWithDisplayWordViewController]) {
                [self.spelling setFont:[UIFont systemFontOfSize:140]];
            } else {
                [self.spelling setFont:[UIFont systemFontOfSize:55]];
            }
            self.homonymButton1.titleLabel.font = [UIFont boldSystemFontOfSize:30];
            self.homonymButton2.titleLabel.font = [UIFont boldSystemFontOfSize:30];
            self.homonymButton3.titleLabel.font = [UIFont boldSystemFontOfSize:30];
            self.homonymButton4.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        }
    }
}

-(void)setUpViewForWord:(Word *)word
{
    [self manageListenButtons];
    [UIView transitionWithView:self.wordView duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ {
                        self.spelling.text = word.spelling;
                    }
                    completion:nil];
    
    if (self.isViewLoaded && self.view.window) {
        //viewController is visible track with GA allowing iPad stats to show which word got loaded. Appington calls already handled in DictionaryTableViewController class.
        NSString *viewNameForGA = [NSString stringWithFormat:@"Viewed Word :%@", self.spelling.text];
        [GlobalHelper sendView:viewNameForGA];
    }
}

- (void) manageListenButtons
{
    NSSet *pronunciations = self.word.pronunciations;
    
    if ([pronunciations count] == 1) {
        self.heteronymListenButton.hidden = YES;
        self.homonymButton3.hidden = YES;
        self.homonymButton4.hidden = YES;
        self.listenButton.hidden = NO;
        
        self.listenButton.frame = CGRectMake((self.listenButton.superview.frame.size.width/2 - self.listenButton.frame.size.width/2), self.listenButton.frame.origin.y, self.listenButton.frame.size.width, self.listenButton.frame.size.height);
        
        Pronunciation *pronunciation = [[pronunciations allObjects] lastObject];
        NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.fileName];
        fileURL? (self.listenButton.enabled = YES) : (self.listenButton.enabled = NO);
                
        [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonymButton1 and:self.homonymButton2 UnderListenButton:self.listenButton];
        
    } else if ([pronunciations count] == 2) {
        self.heteronymListenButton.hidden = NO;
        self.listenButton.hidden = NO;
        
        self.listenButton.frame = CGRectMake(56, self.listenButton.frame.origin.y, self.listenButton.frame.size.width, self.listenButton.frame.size.height);
        
        for (Pronunciation *pronunciation in pronunciations) {
            NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.fileName];
            if ([pronunciation.unique hasSuffix:[NSString stringWithFormat:@"1"]]) {
                fileURL? (self.listenButton.enabled = YES) : (self.listenButton.enabled = NO);
                [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonymButton1 and:self.homonymButton2 UnderListenButton:self.listenButton];
            }
            if ([pronunciation.unique hasSuffix:[NSString stringWithFormat:@"2"]]) {
                fileURL? (self.heteronymListenButton.enabled = YES) : (self.heteronymListenButton.enabled = NO);
                [self manageHomonymsOfPronunciation:pronunciation WithButtons:self.homonymButton3 and:self.homonymButton4 UnderListenButton:self.heteronymListenButton];
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
        button1.hidden = YES;
        button2.hidden = YES;
        for (Word *word in homonyms) {
            if (word == self.word) continue;
            counter += 1;
            if (counter == 1) {
                button1.hidden = NO;
                [button1 setTitle:word.spelling forState:UIControlStateNormal];
                [self sizeHomonymButton:button1];
                //[button1 sizeToFit];
                CGRect frame = CGRectMake(listenbutton.frame.origin.x - (button1.frame.size.width/2 - listenbutton.frame.size.width/2), button1.frame.origin.y, button1.frame.size.width, button1.frame.size.height);
                button1.frame = frame;
                
                //CGRectMake((button1.superview.frame.size.width/2 - button1.frame.size.width/2), button1.frame.origin.y, button1.frame.size.width, button1.frame.size.height); 
            }
            if (counter == 2) {
                button2.hidden = NO;
                [button2 setTitle:word.spelling forState:UIControlStateNormal];
                [self sizeHomonymButton:button2];
                //[button2 sizeToFit];
                CGRect frame = CGRectMake(listenbutton.frame.origin.x - (button2.frame.size.width/2 - listenbutton.frame.size.width/2), button2.frame.origin.y, button2.frame.size.width, button2.frame.size.height);
                button2.frame = frame;
                //CGRectMake((button2.superview.frame.size.width/2 - button2.frame.size.width/2), button2.frame.origin.y, button2.frame.size.width, button2.frame.size.height);
            }
        }
    }
}

-(void) sizeHomonymButton:(UIButton *)button
{
    // set background image of all buttons
    CGFloat spacingBetweenImageAndText = 2;
    CGFloat spacingToTop = 0;
    CGFloat spacingToBottom = 0;
    if (self.useDyslexieFont) {
        spacingToBottom = -3;
        spacingToTop = 3;
    }
    
    [button sizeToFit];
    CGRect buttonFrame = button.frame;
//    NSLog(@"button size from bounds = h%f w%f", button.bounds.size.height, button.bounds.size.width);
    buttonFrame.size = CGSizeMake(button.frame.size.width, 43); //forcing button height as backgroud image seems to make it large
    button.frame = buttonFrame;
    
//    NSLog(@"titleLabel = %f, %f", button.titleLabel.bounds.size.width, button.titleLabel.bounds.size.height);
//    NSLog(@"button bounds = %f, %f", button.bounds.size.width, button.bounds.size.height);
//    NSLog(@"image bounds = %f, %f", button.imageView.bounds.size.width, button.imageView.bounds.size.height);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacingBetweenImageAndText);
    button.titleEdgeInsets = UIEdgeInsetsMake(spacingToTop, spacingBetweenImageAndText, spacingToBottom, 0);
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
            
            //track event with GA auto sent with Value 2
            [GlobalHelper trackWordEventWithAction:@"ListenToWord" withLabel:pronunciation.unique withValue:[NSNumber numberWithInt:2]];
            //Tell Appington that a word has played (auto)
            NSDictionary *controlValues = @{@"word": pronunciation.unique};
            [GlobalHelper callAppingtonPronouncationTriggerWith:controlValues];
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
    
    NSURL *fileURL = [DictionaryHelper fileURLForPronunciation:pronunciation.fileName];
    
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

            //track event with GA manual sent with Value 1
            [GlobalHelper trackWordEventWithAction:@"ListenToWord" withLabel:unique withValue:[NSNumber numberWithInt:1]];
            //Tell Appington that a word has played (manual)
            NSDictionary *controlValues = @{@"word": unique};
            [GlobalHelper callAppingtonPronouncationTriggerWith:controlValues];
            
        }
    }
}


- (IBAction)homoymnButtonPressed:(UIButton *)sender 
{
    NSString *spelling = sender.titleLabel.text;
    //send to delegate
    [self.delegate DisplayWordViewController:self homonymSelectedWith:spelling];

    //track event with GA
    id tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendEventWithCategory:@"uiAction_Word" withAction:@"homoymnButtomPressed" withLabel:spelling withValue:[NSNumber numberWithInt:1]];
    NSLog(@"Event sent to GA uiAction_Word homoymnButtonPressed %@",spelling);
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

//- (void) setupCustomBackgroundColour
//{
//    self.view.backgroundColor = [UIColor colorWithHue:[self.customBackgroundColour floatValue] saturation:.20 brightness:1 alpha:1];
//}

- (void)viewWillAppear:(BOOL)animated
{
    //check if correct background color is set - needed if user changed color in setting while a work is showing in iPhone.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIColor *currentDesiredColor = [UIColor colorWithHue:[defaults floatForKey:BACKGROUND_COLOR_HUE] saturation:[defaults floatForKey:BACKGROUND_COLOR_SATURATION] brightness:1 alpha:1];
    if (![self.customBackgroundColor isEqual:currentDesiredColor]) {
        self.customBackgroundColor = currentDesiredColor;
    }
    
    self.useDyslexieFont = [defaults floatForKey:USE_DYSLEXIE_FONT];
    
    if (self.word) {
        [self setUpViewForWord:self.word];
        if (self.playWordsOnSelection) { //only used in iPhone - playwords on iPad done from DictionaryTableViewController
            [self playAllWords:self.word.pronunciations];
        }
    }
    
    NSString *viewNameForGA = [NSString stringWithFormat:@"Viewed Word :%@", self.spelling.text];
    [GlobalHelper sendView:viewNameForGA];
    
//    NSNumber *forControl = self.word.isHomophone;
    //call Appington if in iphone (ipad calls handled in DictionaryTableViewContorller
    if (![self getSplitViewWithDisplayWordViewController]) {
        [GlobalHelper callAppingtonInteractionModeTriggerWithModeName:@"word_view" andWord:self.spelling.text];
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
    [self setHomonymButton1:nil];
    [self setHomonymButton2:nil];
    [self setHomonymButton3:nil];
    [self setHomonymButton4:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //iOS 5 not 6
{
//    if ([self splitViewWithDisplayWordViewController]) {
        return YES;
//    } else {
//        return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    } iOS 6 makes supporting rotation on iPhone harder (changes in how its done - so just supporting portrait for now - upsidedown is also out without category on UINavController and UITabController to override the default no upsidedown on iPhone. http://stackoverflow.com/questions/12520030/how-to-force-a-uiviewcontroller-to-portait-orientation-in-ios-6
    
}


- (DisplayWordViewController *)getSplitViewWithDisplayWordViewController
{
    id dwvc = [self.splitViewController.viewControllers lastObject];
    if (![dwvc isKindOfClass:[DisplayWordViewController class]]) {
        dwvc = nil;
    }
    return dwvc;
}

- (void) setColorOfButtons:(NSArray*)buttons toColor:(UIColor *)color areHomonymButtons:(BOOL)areHomonyms
{
    //raw idea at http://stackoverflow.com/questions/7238507/change-round-rect-button-background-color-on-statehighlighted
    //modified to take UIColor on input not a color spec
    
    if (buttons.count == 0) {
        return;
    }
    
    // get the first button
    NSEnumerator* buttonEnum = [buttons objectEnumerator];
    UIButton* button = (UIButton*)[buttonEnum nextObject];
    
    UIColor *highlightColor = color;
    [button setTintColor:highlightColor];
    
    float cRadius = 8;
//    NSLog(@"button size from imageView.image = h%f w%f", button.imageView.image.size.height, button.imageView.image.size.width);
//    NSLog(@"button size from layer.frame = h%f w%f", button.layer.frame.size.height, button.layer.frame.size.width);
//    NSLog(@"button size from button.bounds = h%f w%f", button.bounds.size.height, button.bounds.size.width);
    UIImage *image = [DisplayWordViewController createImageOfColor:highlightColor ofSize:CGSizeMake(40, 25) withCornerRadius:cRadius];
//    NSLog(@"created image size = %f, %f", image.size.width, image.size.height);
    
    UIImage* stretchableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch];
    
    // set background image of all buttons
    
    do {
        
        [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = cRadius;
        button.layer.needsDisplayOnBoundsChange = YES;
        
        if (areHomonyms) {
            [self sizeHomonymButton:button];
        }
        
    } while (button = (UIButton*)[buttonEnum nextObject]);
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    gradient.frame = rect;
    //    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    //    [view.layer insertSublayer:gradient atIndex:0];
}

+ (UIImage *)createImageOfColor:(UIColor *)color ofSize:(CGSize)size withCornerRadius:(float)cRadius
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // image drawing code here

    
//    Used to draw a perfect rectangle for use as button background during development.
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 0, 0);
//    CGContextAddLineToPoint(context, 0, image.size.height);
//    CGContextAddLineToPoint(context, image.size.width, image.size.height);
//    CGContextAddLineToPoint(context, image.size.width, 0);
//    CGContextAddLineToPoint(context, 0, 0);
//    CGContextClosePath(context);
//    CGContextFillPath(context);
    
    [color setFill];
    [[UIColor grayColor] setStroke];
    
    UIGraphicsPushContext(context);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: cRadius];
    [roundedRect fillWithBlendMode: kCGBlendModeNormal alpha:1.0f];
    
//    [[UIColor yellowColor] setFill];
    CGFloat hue;   CGFloat sat;   CGFloat bright;   CGFloat alpha;
    [color getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    CGFloat darkest=0.8;
    int loopMax = 5;  //loops 1 times less than this
    int stepSize = 1;
    
    for (int i = 1 ; i < loopMax ; i++)
    {

        CGFloat increaseBrightnessEachLoop = (1-darkest)/(loopMax-1);
        CGFloat brightThisLoop = darkest + increaseBrightnessEachLoop*i;
 //       NSLog(@"brightThisLoop = %f", brightThisLoop);
        [[UIColor colorWithHue:hue saturation:sat brightness:brightThisLoop alpha:alpha] setFill];
     
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, size.height-stepSize*(i-1));
        CGContextAddLineToPoint(context, size.width, size.height-stepSize*(i-1));
        CGContextAddLineToPoint(context, size.width, size.height-stepSize*i);
        CGContextAddLineToPoint(context, 0, size.height-stepSize*i);
        CGContextAddLineToPoint(context, 0, size.height-stepSize*(i-1));
        CGContextClosePath(context);
        CGContextFillPath(context);
//        NSLog(@"rectangle this loop tl:%f,%f tr:%f,%f br:%f,%f bl:%f,%f",
//              0.0f,size.height-stepSize*(i-1),
//              size.width,size.height-stepSize*(i-1),
//              size.width,size.height-stepSize*i,
//              0.0f,size.height-stepSize*i);
        
    }
    
    CGFloat lineWidth = 2.0;
    CGRectInset(rect, lineWidth/2.0, lineWidth/2.0);
    [roundedRect strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
    
    UIGraphicsPopContext();
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    NSLog(@"image I'm passing back %@", coloredImage);
    return coloredImage;
    
    
}

@end
