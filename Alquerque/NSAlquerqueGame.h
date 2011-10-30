//
//  NSAlquerqueGame.h
//  Alquerque
//
//  Created by Thomas Barrasso on 4/18/11.
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

#import <Foundation/Foundation.h>
#import "NSAlquerqueDelegate.h"
#import "NSAlquerqueMove.h"
#import "NSAlquerqueUtils.h"

/*
 * NSAlquerqueGame is the class from which you
 * instantiate to begin a game. It requires an
 * NSAlquerqueDelegate to be defined to handle
 * callbacks for updating the UI.
 */

@interface NSAlquerqueGame : NSObject {
    
    int _numOfPlayerOnePieces;
    int _numOfPlayerTwoSpaces;
    int _numOfFreeSpaces;
    int _turnsTaken;
    bool _hasWon;
    bool _compulsion;
    NSInteger _doubleJumpIndex;
    NSInteger _playerToMakeNextMove;
    NSInteger _playerToMakeThisMove;
    alquerque_location *_tmpHighlightLocations;
    alquerque_game_board _state;
    
    id<NSAlquerqueDelegate> _delegate;
}

// Primitives
@property (nonatomic, assign) int numOfPlayerOnePieces;
@property (nonatomic, assign) int numOfPlayerTwoPieces;
@property (nonatomic, assign) int numOfFreePieces;
@property (nonatomic, assign) int turnsTaken;
@property (nonatomic, assign) bool hasWon;
@property (nonatomic, assign) bool compulsion;
@property (nonatomic, assign) NSInteger doubleJumpIndex;
@property (nonatomic, assign) NSInteger playerToMakeNextMove;
@property (nonatomic, assign) NSInteger playerToMakeThisMove;
@property (nonatomic, assign) alquerque_game_board state;

// Objects (and non-primitives)
@property (nonatomic, assign) alquerque_location *tmpHighlightLocations;
@property (nonatomic, retain) id<NSAlquerqueDelegate> delegate;

// Methods

// Creates an array of the current game board.
- (NSMutableArray *)currentBoard;

// Creates a string of the board to be dumped to the log.
- (NSMutableString *)logBoard;

// Internal method used to inform the UI that player has
// attempted to make an invalid move.
- (void)invalidMoveOfType:(NSInteger)type;

// Internal method to inform the UI to remove certain highlights.
- (void)removeHightlights;

// Determine the player at an index on the board.
- (NSInteger)playerForIndex:(int)index;

// Determines the player at a given location.
- (NSInteger)playerForLocation:(alquerque_location)loc;

// Makes sure that if compulsion is set on, the player is
// fulfilling that compulsion by jumping an opponents piece.
- (bool)moveFulfillsCompulsionFrom:(alquerque_location)loc
                                To:(alquerque_location)newLoc;

// Determine if (and where) another jump is possible.
- (void)checkForAnotherJump:(alquerque_location)location
               AndFillArray:(alquerque_location[])locations;

// Called when a player chooses to move a game piece
// at originalIndex to newIndex.
- (void)movePieceAtIndex:(NSInteger)originalIndex
                 toIndex:(NSInteger)newIndex;

// Custom init to begin game from a saved state.
// Note that - (id)init has been overriden as well.
- (NSAlquerqueGame *)initWithArray:(NSMutableArray *)board
                  AndCurrentPlayer:(NSInteger)player;

// * Note: I am using a simple structure like this not because
// it is more optimal, but because it makes the game more portable,
// and I intend to port this game to Android if I have any success.

@end
