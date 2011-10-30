//
//  FlipsideViewController.m
//  Alquerque
//
//  Created by Thomas Barrasso on 4/21/11.
//

//
//  Copyright 2011 Thomas Barrasso <contact@tombarrasso.com>
//
//  This file is part of Alquerque.
//
//  Alquerque is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Alquerque is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Alquerque. If not, see <http://www.gnu.org/licenses/>.
//

#import "FlipsideViewController.h"
#define DEFAULTS_FILE_NAME @"default-settings"
#define DEFAULTS_FILE_TYPE @"plist"

@implementation FlipsideViewController

@synthesize delegate = _delegate,
compulsionSwitch = _compulsionSwitch;

#pragma mark - Dealloc, Memory, & Unload

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setCompulsionSwitch:nil];
}

#pragma mark - View Loaded

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fetch defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:DEFAULTS_FILE_NAME ofType:DEFAULTS_FILE_TYPE]]];
    
    // Set compulsion to default setting (or user set preference).
    [self.compulsionSwitch setOn:[defaults boolForKey:@"Compelled"]];
}

// Support all orientations.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

// Save the value of the compulsion switch.
- (IBAction)setCompulsionPreference:(id)sender
{
    [[NSUserDefaults standardUserDefaults]
     setBool:[self.compulsionSwitch isOn]
      forKey:@"Compelled"];
}

@end
