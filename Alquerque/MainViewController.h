//
//  MainViewController.h
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
#import <GameKit/GameKit.h>
#import "NSAlquerqueDelegate.h"
#import "NSAlquerqueGame.h"

@interface MainViewController : UIViewController
    <FlipsideViewControllerDelegate, NSAlquerqueDelegate, GKPeerPickerControllerDelegate, GKSessionDelegate> {
        int _lastTag;
        
        NSAlquerqueGame *_game;
        NSDictionary *_images;
        UIView *_pieceContainer;
        
        GKPeerPickerController *_picker;
        GKSession *_session;
        NSString *_peerID;
        bool _isConnected;
}

// Primitive iVars
@property (nonatomic, assign) int lastTag;
@property (nonatomic, assign) bool isConnected;

// Object iVars
@property (nonatomic, retain) NSAlquerqueGame *game;
@property (nonatomic, retain) NSDictionary *images;

// UIViews
@property (nonatomic, retain) IBOutlet UIView *pieceContainer;
@property (nonatomic, retain) IBOutlet UIImageView *board;

// GameKit
@property (nonatomic, retain) GKPeerPickerController *picker;
@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *peerID;

// Methods
- (void)createGame;
- (void)loadImageArray;
- (void)restoreGameFromBoard:(NSMutableArray *)state
                   AndPlayer:(NSInteger)player;

// Actions
- (IBAction)showInfo:(id)sender;
- (IBAction)pieceClicked:(id)sender;
- (IBAction)newGame:(id)sender;

@end
