//
//  AlquerqueAppDelegate.m
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

#import "AlquerqueAppDelegate.h"
#import "MainViewController.h"

@implementation AlquerqueAppDelegate

@synthesize window = _window,
            mainViewController = _mainViewController;

#pragma mark - Application Ready

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.mainViewController;
    
    // Fetch defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *state = [defaults valueForKey:@"Board"];
    NSInteger player = [defaults integerForKey:@"Player"];
    
    // If state not set, or user has won
    if (state == nil || [defaults boolForKey:@"HasWon"])
        [self.mainViewController createGame];
    else
        [self.mainViewController restoreGameFromBoard:state AndPlayer:player];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Application Ending

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Save current game board.
    [defaults setValue:[[[self mainViewController] game] currentBoard] forKey:@"Board"];
    
    // Save current player.
    [defaults setInteger:[[[self mainViewController] game] playerToMakeThisMove] forKey:@"Player"];
    
    // Save whether or not the game has been won.
    [defaults setBool:[[[self mainViewController] game] hasWon] forKey:@"HasWon"];
}

#pragma mark - Application Deallocation

- (void)dealloc
{
    [_window release];
    [_mainViewController release];
    [super dealloc];
}

@end
