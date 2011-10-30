//
//  NSAlquerqueUtils.h
//  Alquerque
//
//  Created by Thomas Barrasso on 4/30/11.
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
 * All methods and structures are externalized into this
 * file and all implementations in the corresponding .m
 * file. Features include a game board and manipulation
 * of it, as well as players, etc. Finally, most constants
 * are declared here for use in other files.
 */

// Simple C preprocessor for swapping players
#define swap_players(i, j) {NSInteger t = i; i = j; j = t;}

// Game board structure *
typedef struct alquerque_game_board {
    NSInteger board[5][5];
} alquerque_game_board;

// Location structure
typedef struct alquerque_location {
    int row;
    int column;
} alquerque_location;

// Simple C function to swap positions, determine sign of integer,
// convert a location to an index, and remove a position.
void swap_positions(alquerque_game_board *board,
                    NSInteger i, NSInteger e, NSInteger j, NSInteger k);
void remove_position(alquerque_game_board *board, NSInteger i, NSInteger j);
int indexForLocation(alquerque_location loc);
alquerque_location locationForIndex(int index);
alquerque_location locationForRowAndColumn(int row, int column);
int sign(NSInteger i);

// Given two alquerque locations this method determines the distance.
// It is not purely mathematical such that the distance between one space
// left or right is 1, and one space diagnol is sqrt(2), but instead the
// latter would be one as well.
int distanceBetween(alquerque_location originalLoc, alquerque_location newLoc);

// Declare player & game constants
extern NSInteger const PLAYER_ONE;
extern NSInteger const PLAYER_TWO;
extern NSInteger const FREE_SPACE;

// Convenience bools
extern bool const ON;
extern bool const OFF;

// Invalid move types
// Asserts that the destination clicked MUST be a free space.
extern NSInteger const INVALID_DESTINATION_NOT_FREE;
// Asserts that the piece clicked must belong to the player
// that is making the current move.
extern NSInteger const INVALID_WRONG_PLAYERS_PIECE;
// Asserts that the piece clicked was a free space.
extern NSInteger const INVALID_ORIGIN_NOT_PLAYER;
// Asserts that the diagonal was not traversable by
// the piece at the given location.
extern NSInteger const INVALID_DIAGONAL_NOT_TRAVERSABLE;
// Asserts that a piece beinging jumped must belong
// to the player making the next move.
extern NSInteger const INVALID_JUMP_OWN_PIECE;
// Asserts that the piece cannot move that far.
extern NSInteger const INVALID_DISTANCE_TOO_FAR;
// Asserts that the player cannot move onto same location.
extern NSInteger const INVALID_NO_MOVE_MADE;
// Asserts that the player is compelled to jump
// an opponents piece (compulsion is ON).
extern NSInteger const INVALID_COMPELLED_JUMP_ELSEWHERE;
