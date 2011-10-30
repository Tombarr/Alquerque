//
//  NSAlquerqueGame.m
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

#import "NSAlquerqueGame.h"

/*
 * Implementation of NSAlquerqueGame. Use this class by
 * creating an instance of it to represent beginning a
 * new game, and setting a delegate to handle its callbacks.
 * It can be a bit scary, as it has to keep track of which
 * player is doing what, update a board structure, count
 * the number of each type of piece, etc.
 */

@implementation NSAlquerqueGame

// Synthesize our iVars
@synthesize delegate              = _delegate,
            playerToMakeNextMove  = _playerToMakeNextMove,
            playerToMakeThisMove  = _playerToMakeThisMove,
            numOfFreePieces       = _numOfFreeSpaces,
            numOfPlayerOnePieces  = _numOfPlayerOnePieces,
            numOfPlayerTwoPieces  = _numOfPlayerTwoSpaces,
            turnsTaken            = _turnsTaken,
            hasWon                = _hasWon,
            compulsion            = _compulsion,
            doubleJumpIndex         = _doubleJumpIndex,
            tmpHighlightLocations = _tmpHighlightLocations,
            state                 = _state;

#pragma mark - Moving Pieces

// Called to (possibly) move a piece and delete
// other pieces if necessary, or double jump, etc.
- (void)movePieceAtIndex:(NSInteger)originalIndex
                 toIndex:(NSInteger)newIndex
{
    // If the game was won, do nothing.
    if (self.hasWon) return;
    
    bool doubleJumpPossible = NO;
    
    // Create a move.
    NSAlquerqueMove *move = [[NSAlquerqueMove alloc] initWithMoveFrom:originalIndex
                                                                   to:newIndex
                                                              forGame:self];
    
    // If move is illegal, return the error
    if (![move isLegal])
        return [self invalidMoveOfType:[move error]];
    
    // Since we are here the player has made a valid move, now we need
    // to determine which pieces need to go where, winners, and switch
    // playerToMakeNextMove to the other player.
    
    // If the user is only moving one position over, then simply let them.
    if ([move distance] == 1)
    {
        [self removeHightlights];
        
        // No need to remove pieces, but needs to update the board.
        // Swap blank spot with the piece that was just moved.
        swap_positions(&_state, [move sourceLocation].row, [move sourceLocation].column,
                       [move destinationLocation].row, [move destinationLocation].column);
        // NOTE TO SELF: USE &_state NOT &self.state, as self.state is already
        // a pointer to _state, don't pass a pointer to a pointer!!!
    }
    // Otherwise they are moving two two places, here comes some logic!
    else
    {
                
        // Decrement player pieces count.
        if (self.state.board[[move jumpedLocation].row][[move jumpedLocation].column] == PLAYER_ONE)
            self.numOfPlayerOnePieces--;
        else
            self.numOfPlayerTwoPieces--;
        
        // Increment the number of free spaces.
        self.numOfFreePieces++;
        
        // Turn piece jumped into a free space.
        remove_position(&_state, [move jumpedLocation].row, [move jumpedLocation].column);
        
        // Swap blank spot with the piece that was just moved.
        swap_positions(&_state, [move sourceLocation].row, [move sourceLocation].column,
                       [move destinationLocation].row, [move destinationLocation].column);
        
        // Tell the UI to remove the piece jumped.
        [self.delegate removePieceFromPlayer:self.playerToMakeNextMove
                                     atIndex:[move jumpedIndex]];
        
        [self removeHightlights];
        
        // Check for the possibility to double-jump.
        // Nine is the maximum number of possible double-jump
        // locations, but anything more than one option is rare.
        alquerque_location locations[9];
        [self checkForAnotherJump:[move destinationLocation]
                     AndFillArray:locations];
        
        // Go through all locations.
        for (int i = 0; i < 9; i++)
            
            // If it is not default, it double-jumpable!
            if (locations[i].row != -1)
            {
                // Set so we can remove highlights later.
                self.tmpHighlightLocations[i] = locations[i];
                
                doubleJumpPossible = YES;
                // Tell the UI to highlight this possibility.
                [self.delegate highlightAtIndex:indexForLocation(locations[i])];
            }
    }
    
    // Update the UI and tell the piece to move.
    [self.delegate movePlayers:self.playerToMakeThisMove
                  pieceAtIndex:[move sourceIndex]
                       toIndex:[move destinationIndex]];
        
    // Swap players only if a doulbe jump is not possible.
    if (!doubleJumpPossible)
    {
        swap_players(self.playerToMakeThisMove, self.playerToMakeNextMove);
        // Increment the number of turns taken.
        self.turnsTaken++;
        
        // Reset double jump index.
        self.doubleJumpIndex = -1;
        
        // Check for a winner here.
        if (self.numOfPlayerTwoPieces == 0 || self.numOfPlayerOnePieces == 0)
            self.hasWon = true;
        if (self.numOfPlayerOnePieces == 0)
            [self.delegate onWin:PLAYER_ONE];
        if (self.numOfPlayerTwoPieces == 0)
            [self.delegate onWin:PLAYER_TWO];
    }
    else
    {
        self.doubleJumpIndex = newIndex;
    }
}

#pragma mark - Double Jumping

// Determine if a double+ jump is possible.
// Double jumping is handled recursively because
// it is possible to actually have a triple, or
// more jump. Although that is a rare case.
- (void)checkForAnotherJump:(alquerque_location)location
               AndFillArray:(alquerque_location[])locations
{
    // Initialize all locations to -1, and an index.
    for (int i = 0; i < 9; i++)
        locations[i].row = locations[i].column = 
        self.tmpHighlightLocations[i].row = self.tmpHighlightLocations[i].column = -1;

    int index = 0;
    bool diagonal = YES,
         shouldCheck = YES;
    
    // Prepare yourself, this series of for loops and if statements
    // is aestetically distasteful, but logically sound.
    // It is mostly to avoid accessing an index that is out of
    // an array's bounds, and to check the proper pieces.
    
    // Check to see if this piece can move diagonally
    if ((location.column % 2 == 1 &&
        location.row % 2 == 0) ||
        (location.column % 2 == 0 &&
         location.row % 2 == 1))
        diagonal = NO;

    // Check the row above, below, and this row.
    for (int e = -1; e <= 1; e++)
        
        // Make sure that row exists.
        if (location.row+e >= 0 && location.row+e < 5)
            
            // Check left, up/down, and right.
            for (int i = -1; i <= 1; i++)
                
                // Make sure that column exists.
                if (location.column+i >= 0 && location.column+i < 5)
                    
                    // Check to see that a surround piece belongs to the other player.
                    if (self.state.board[location.row+e][location.column+i]
                        == self.playerToMakeNextMove)
                        
                        // Make sure the column & row one more position in that direction
                        // exists and that it is a free space.
                        if (location.column+i+i >= 0 && location.column+i+i < 5 &&
                            location.row+e+e >= 0 && location.row+e+e < 5)
                        {
                            // If the location in question is diagonal and we can
                            // move diagonally, test this location.
                            if ((location.column+i+i != location.column &&
                                location.row+e+e != location.row))
                                if (!diagonal)
                                    shouldCheck = NO;
                            
                            // If the location in question is blank, add it!
                            if (self.state.board[location.row+e+e][location.column+i+i]
                                == FREE_SPACE && shouldCheck)
                            {
                                // If the piece at that location belongs to the other
                                // person, add it to our array.
                                locations[index].row = location.row+e+e;
                                locations[index].column = location.column+i+i;
                                index++;
                            }
                            shouldCheck = YES; // Reset shoudCheck.
                        }
}

#pragma mark - Compulsion

// Check of see if move fulfills player's compulsion.
- (bool)moveFulfillsCompulsionFrom:(alquerque_location)loc
                                To:(alquerque_location)newLoc
{

    // Initialzie locations and bools.
    alquerque_location location;
    // 12 is the max # of pieces a player can have.
    alquerque_location locations[9];
    alquerque_location tmpHighlightLocations[9];
    bool piecesToJump = NO;
    int oldIndex = indexForLocation(loc);
    
    // If we have locations highlighted, a jump is
    // possible so don't bother with the rest.
    if (self.tmpHighlightLocations != nil)
        for (int i = 0; i < 9; i++)
            // If we already know that a double jump is possible, don't
            // bother with the rest of this logic, make sure the new
            // location is one of the highlighted options.
            if (oldIndex == self.doubleJumpIndex &&
                newLoc.row == self.tmpHighlightLocations[i].row &&
                newLoc.column == self.tmpHighlightLocations[i].column)
                return YES;
            else
                // There is no need to set this array unless we go through the board
                // loop below, which if a double jump is possible we don't need to do.
                tmpHighlightLocations[i] = self.tmpHighlightLocations[i];
    
    // If we are hear and can double jump it means that the new location
    // is not one of the highlighted, jumpable options.
    if (self.doubleJumpIndex != -1)
        return NO;
    
    // Loop through entire board.
    for (int i = 0; i < 5; i++)
        for (int e = 0; e < 5; e++)
            // If this piece belongs to current player.
            if (self.state.board[i][e] == self.playerToMakeThisMove)
            {
                location.row = i;
                location.column = e;
                
                // Check to see if the piece at this location 
                // can jump an opponent's piece.
                [self checkForAnotherJump:location
                             AndFillArray:locations];
                
                // Go through all locations.
                for (int j = 0; j < 9; j++)
                {
                    // If it is not default, it jumpable!
                    if (locations[j].row != -1)
                    {
                        // We've found a piece to jump.
                        piecesToJump = YES;
                        
                        // If this jumpable location is THIS one.
                        if (location.row == loc.row &&
                            location.column == loc.column)
                        {
                            // Reset highlights.
                            for (int l = 0; l < 9; l++)
                                self.tmpHighlightLocations[l] = tmpHighlightLocations[l];
                        
                            return YES;
                        }
                    }
                    // Reset location values.
                    locations[j].row = locations[j].column = -1;
                }
            }
    
    // Reset highlights.
    for (int l = 0; l < 9; l++)
        self.tmpHighlightLocations[l] = tmpHighlightLocations[l];
    
    return !piecesToJump;
}

// Simply determines the player at a given index.
- (NSInteger)playerForIndex:(int)index
{
    alquerque_location loc = locationForIndex(index);
    return self.state.board[loc.row][loc.column];
}

// Simply determines the player at a given location.
- (NSInteger)playerForLocation:(alquerque_location)loc
{
    return self.state.board[loc.row][loc.column];
}

#pragma mark - Output

// Creates an array of the current game board.
- (NSMutableArray *)currentBoard
{
    // Initialize string
    NSMutableArray *currentBoard = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i++)
    {
        // Create an array with five elements.
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:5];
        for (int e = 0; e < 5; e++)
            [row addObject:[NSNumber numberWithInt:self.state.board[i][e]]];

        // Add row to array.
        [currentBoard addObject:row];
    }
    
    return currentBoard;
}

#pragma mark - Log

// Creates a formatted string of the current game for the log.
- (NSMutableString *)logBoard
{
    // Initialize string
    NSMutableString *log= [[NSMutableString alloc] init];
    
    // Create a formatted XML string
    [log appendString:@"\n"];
    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 5; j++)
            [log appendFormat:@"%i ", self.state.board[i][j]];

        [log appendString:@"\n"];
    }
    
    return log;
}

#pragma mark - Invalid Move & Remove Highlight

// Informs the UI of an invalidMoveByPlayer
- (void)invalidMoveOfType:(NSInteger)type
{
    [self.delegate onInvalidMoveByPlayer:self.playerToMakeThisMove
                                  OfType:type];
}

// Removes previously set highlights.
- (void)removeHightlights
{
    // Go through all highlighted locations and clear them.
    if (self.tmpHighlightLocations != nil && self.turnsTaken > 1)
        for (int i = 0; i < 9; i++)
        {
            if (self.tmpHighlightLocations[i].row != -1
                && self.tmpHighlightLocations[i].column != -1)
                // Tell the UI to remove the highlight at this location.
                [self.delegate removeHighlightAtIndex:indexForLocation(self.tmpHighlightLocations[i])];
            self.tmpHighlightLocations[i].row = self.tmpHighlightLocations[i].column = -1;
        }
}

#pragma mark - Initialization & Restoration

// Custom initialization method
- (NSAlquerqueGame *)init
{
    if ((self = [super init]))
    {
        // Initialiaze primitives
        [self setNumOfFreePieces:1];
        [self setDoubleJumpIndex:-1];
        [self setNumOfPlayerOnePieces:12];
        [self setNumOfPlayerTwoPieces:12];
        [self setTmpHighlightLocations:
         (alquerque_location *) malloc (9 * sizeof(alquerque_location))];
        
        // Player two (bottom) makes the first move.
        [self setPlayerToMakeThisMove:PLAYER_TWO];
        [self setPlayerToMakeNextMove:PLAYER_ONE];
        
        // Set up initial game board (in a fairly visual manner too)!
        alquerque_game_board INITIAL_BOARD =
        {
            {
                {PLAYER_ONE, PLAYER_ONE, PLAYER_ONE, PLAYER_ONE, PLAYER_ONE},
                {PLAYER_ONE, PLAYER_ONE, PLAYER_ONE, PLAYER_ONE, PLAYER_ONE},
                {PLAYER_ONE, PLAYER_ONE, FREE_SPACE, PLAYER_TWO, PLAYER_TWO},
                {PLAYER_TWO, PLAYER_TWO, PLAYER_TWO, PLAYER_TWO, PLAYER_TWO},
                {PLAYER_TWO, PLAYER_TWO, PLAYER_TWO, PLAYER_TWO, PLAYER_TWO}
            }
        };
        
        // Reset highlight locations.
        for (int i = 0; i < 9; i++)
            self.tmpHighlightLocations[i].row = self.tmpHighlightLocations[i].column = -1;
        
        // Set the current game board to the initial board
        [self setState:INITIAL_BOARD];
    }
    
    return self;
}

// Allows a game to be initialized from an array.
- (NSAlquerqueGame *)initWithArray:(NSMutableArray *)board
                  AndCurrentPlayer:(NSInteger)player
{
    if ((self = [super init]))
    {
        // Initialize integers.
        int numOfFreePieces = 0,
            numOfPlayerOnePieces = 0,
            numOfPlayerTwoPieces = 0,
            curPiece = 0;
                
        // Initialize an empty board.
        alquerque_game_board INITIAL_BOARD;
        
        // Fill initial board with saved values.
        for (int i = 0; i < 5; i++)
            for (int e = 0; e < 5; e++)
            {
                // Add piece to game board.
                curPiece = [[[board objectAtIndex:i] objectAtIndex:e] intValue];
                INITIAL_BOARD.board[i][e] = curPiece;
                
                // Increment number of pieces justly.
                if (curPiece == PLAYER_ONE)
                    numOfPlayerOnePieces++;
                else if (curPiece == PLAYER_TWO)
                    numOfPlayerTwoPieces++;
                else
                    numOfFreePieces++;
            }
        
        // Set the current game board to the initial board
        [self setState:INITIAL_BOARD];
        
        // Initialiaze primitives
        [self setNumOfFreePieces:numOfFreePieces];
        [self setDoubleJumpIndex:-1];
        [self setNumOfPlayerOnePieces:numOfPlayerOnePieces];
        [self setNumOfPlayerTwoPieces:numOfPlayerTwoPieces];
        [self setTmpHighlightLocations:
         (alquerque_location *) malloc (9 * sizeof(alquerque_location))];
        
        // Reset highlight locations.
        for (int i = 0; i < 9; i++)
            self.tmpHighlightLocations[i].row = self.tmpHighlightLocations[i].column = -1;
        
        // Set the current and next player
        if (player == PLAYER_ONE)
        {
            // Player one (top) makes the first move.
            [self setPlayerToMakeThisMove:PLAYER_ONE];
            [self setPlayerToMakeNextMove:PLAYER_TWO];
        }
        else
        {
            // Player two (bottom) makes the first move.
            [self setPlayerToMakeThisMove:PLAYER_TWO];
            [self setPlayerToMakeNextMove:PLAYER_ONE];
        }
    }
    
    return self;
}

#pragma mark - Deallocation

// Custom deallocatoin method
- (void)dealloc
{
    free(self.tmpHighlightLocations);
    [_delegate release];
    [super dealloc];
}

@end
