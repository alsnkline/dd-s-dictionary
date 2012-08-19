//
//  AboutViewController.m
//  DDPrototype
//
//  Created by Alison Kline on 8/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation AboutViewController
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.webView.delegate = self;
    
//    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"icon-72e" ofType:@"png"];
//    NSLog(@"found icon file at path %@", filepath);
//    NSURL* urlForIcon = [NSURL URLWithString:filepath];
//    NSLog(@"url = %@", urlForIcon);
//    
//    
//    NSString *html = @"<html><body><div align=""center""><img src=""icon-72e.png"" width=""72"" height=""72"" />    </div><h1  align=""center""> Dy-Di the <br /> Dyslexic's Dictionary </h1>   <p>I have managed my reading and writing challenges all my life and am now supporting my daughter as she starts  the same journey. I decided to create The Dyslexic’s Dictionary or Dy-Di (pronounced 'Dee Dee') to give those having difficulty spelling, a tool for independent discovery of an unknown spelling or a quick check of an uncertain one.</p>        <h2>Future enhancements </h2>        <p>I would love to hear your thougths and ideas for future enhancements. Some of the ideas I have had are:</p>            <ul>            <li>Contraction roots, <br /> ie showing ""he will"" by ""he'll""</li>            <li>Additional dictionaries with grade appropriate word lists</li>            <li>The ability to favorite words</li>            <li>Showing groups of words with similar components</li>            </ul></body></html>";
//    NSURL *baseURL = [NSURL URLWithString:@"http://www.google.com"];
//    [self.webView loadHTMLString:html baseURL:baseURL];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"resources.bundle/Images/settings_about" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
