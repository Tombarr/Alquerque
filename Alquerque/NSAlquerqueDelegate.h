//
//  NSAlquerqueDelegate.h
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

/*
 * A class needs to conform to NSAlquerqueDelegate to
 * handle the callbacks of an NSAlquerqueGame. Here the
 * concept of a game is handled with indices& and vectors
 * representing motion from on point to the next.
 */

@protocol NSAlquerqueDelegate <NSObject>

// Called to inform that UI that a game piece should
// be added at position index for player. This method
// is invoked during setup to put all initial pieces
// in their respective places.
- (void)addPieceForPlayer:(NSInteger)player
                  atIndex:(NSInteger)index;

// Called to inform the UI that the game piece at
// index needs to be removed from the board. &&
- (void)removePieceFromPlayer:(NSInteger)player
                      atIndex:(NSInteger)index;

// Called to inform the UI that the piece at position
// originalIndex needs to be moved to position newIndex.
- (void)movePlayers:(NSInteger)player
       pieceAtIndex:(NSInteger)originalIndex
            toIndex:(NSInteger)newIndex;

// Called to inform the UI that the specified
// index needs to be highlighted (as part of
// a possible double jump).
- (void)highlightAtIndex:(NSInteger)index;

// Opposite of highlight at index, it is called
// to inform the UI to remove a highlight once
// shown from a double jump possibility. This is
// necessary because there may have been two pieces
// to double jump, player choose one so the other
// needs to be removed.
- (void)removeHighlightAtIndex:(NSInteger)index;

// Called to inform the UI that the player tried to
// make an invalid move.
- (void)onInvalidMoveByPlayer:(NSInteger)player
                       OfType:(NSInteger)type;

// Called to inform the UI that a player has won.
// There is no onLose method because that would
// simply be the inverse of onWin (when one player
// wins the other must lose, no ties). &&
- (void)onWin:(NSInteger)player;

// Call this method after an NSAlquerqueGame has been
// initialized, however, because the game does not
// specifically invoke this method, it is optional.
@optional
- (void)onGameReady;


@end

/*
 *  GAME BOARD
 *
 * &
 * This is how a game board is layed out:
 *
 * 00 01 02 03 04
 * 05 06 07 08 09
 * 10 11 12 13 14
 * 15 16 17 18 19
 * 20 21 22 23 24
 *
 * The numbers are the indices for that position.
 */

/*
 *  PLAYERS
 * 
 * &&
 * Player is of type integer where 0 is the player
 * that makes the first move, 1 is the player that
 * makes the succeeding move.
 */
