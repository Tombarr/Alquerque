//
//  NSAlquerqueMove.h
//  Alquerque
//
//  Created by Thomas Barrasso on 4/29/11.
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

#import "NSAlquerqueMove.h"

@implementation NSAlquerqueMove

@synthesize isJump = _isJump,
            isLegal = _isLegal,
            sourceIndex = _sourceIndex,
            destinationIndex = _destinationIndex,
            jumpedIndex = _jumpedIndex,
            distance = _distance,
            sourceLocation = _sourceLocation,
            destinationLocation = _destinationLocation,
            jumpedLocation = _jumpedLocation,
            error = _error;

// Initialize a move with a source, destination, and game.
- (NSAlquerqueMove *)initWithMoveFrom:(int)sIndex
                                   to:(int)dIndex
                              forGame:(NSAlquerqueGame *)game;
{
    if ((self = [super init]))
    {
        [self setIsLegal:YES];
        // Determine locations, distances, etc.
        [self setSourceIndex:sIndex];
        [self setDestinationIndex:dIndex];
        [self setSourceLocation:locationForIndex(self.sourceIndex)];
        [self setDestinationLocation:locationForIndex(self.destinationIndex)];
        [self setDistance:distanceBetween(self.sourceLocation, self.destinationLocation)];
        
        NSInteger player = [game playerForLocation:self.sourceLocation];
        
        // Check to make sure that the player is/ is not compelled to move elsewhere.
        if ([game compulsion] == ON)
            if (![game moveFulfillsCompulsionFrom:self.sourceLocation
                                                    To:self.destinationLocation])
                [self setError:INVALID_COMPELLED_JUMP_ELSEWHERE];
        
        // It is not this player's turn.
        if (player != [game playerToMakeThisMove])
            [self setError:INVALID_WRONG_PLAYERS_PIECE];
        
        // If the indices are the same, no move was made.
        if (self.destinationIndex == self.sourceIndex)
            [self setError:INVALID_NO_MOVE_MADE];
        
        // A piece cannot jump more than two spaces at once.
        if (self.distance > 2)
            [self setError:INVALID_DISTANCE_TOO_FAR];
        
        // Make sure that the piece the user clicked
        // first is a game piece and not a free space.
        if ([game state].board[self.sourceLocation.row][self.sourceLocation.column]
            == FREE_SPACE)
            [self setError:INVALID_ORIGIN_NOT_PLAYER];
        
        // Make sure that the place the user clicked
        // secondly is a free space and not a piece.
        if ([game state].board[self.destinationLocation.row][self.destinationLocation.column]
            != FREE_SPACE)
            [self setError:INVALID_DESTINATION_NOT_FREE];
        
        // Check to make sure the player is moving along either an
        // allowed diagnol, or straight up/down/left/right.
        // See * for rules/ logic.
        if (self.destinationLocation.column != self.sourceLocation.column &&
            self.destinationLocation.row != self.sourceLocation.row)
            
            if ((self.sourceLocation.column % 2 == 1 &&
                 self.sourceLocation.row % 2 == 0) ||
                (self.sourceLocation.column % 2 == 0 &&
                 self.sourceLocation.row % 2 == 1))
                [self setError:INVALID_DIAGONAL_NOT_TRAVERSABLE];
        
        // Checking here for a jump...
        if (self.distance == 2)
        {
            // Set location of the piece that is in between jump.
            [self setJumpedLocation:locationForRowAndColumn(
                                                            self.sourceLocation.row +
                                                            sign(self.destinationLocation.row - self.sourceLocation.row),
                                                            self.sourceLocation.column +
                                                            sign(self.destinationLocation.column - self.sourceLocation.column))];
            
            // Set index for piece jumped.
            [self setJumpedIndex:indexForLocation(self.jumpedLocation)];
            
            // Determine if the piece in between is not an opponents piece, ie. a piece belonging
            // to either the this player, or a free space.
            if ([game state].board[self.jumpedLocation.row][self.jumpedLocation.column]
                != [game playerToMakeNextMove])
                [self setError:INVALID_JUMP_OWN_PIECE];
            
            [self setIsJump:true];
        }
        
        // If there is an error, move is illegal.
        if (self.error != 0)
            [self setIsLegal:NO];
    }
    
    return self;
}

@end

// *
// If column is even but row is odd, no diagonal moves are allowed.
// If column is odd but row is even, no diagonal moves are allowed.
// If column and row are even, all diagonal moves are allowed.
// If column and row are odd, all diagonal moves are allowed.
