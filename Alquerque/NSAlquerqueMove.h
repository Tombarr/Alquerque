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

#import <Foundation/Foundation.h>
#import "NSAlquerqueGame.h"
#import "NSAlquerqueUtils.h"

/*
 * NSAlquerqueMove is designed to determine a move's
 * legality/ complications. Logic here decides whether
 * the correct player is making a valid move, and then
 * categorizes that move based on its distance.
 */

// Necessary for circular references.
@class NSAlquerqueGame;

@interface NSAlquerqueMove : NSObject {
    bool _isJump;
    bool _isLegal;
    int _sourceIndex;
    int _destinationIndex;
    int _jumpedIndex;
    int _distance;
    alquerque_location _sourceLocation;
    alquerque_location _destinationLocation;
    alquerque_location _jumpedLocation;
    NSInteger _error;
}

// iVars

// Primitives
@property (nonatomic, assign) bool isJump;
@property (nonatomic, assign) bool isLegal;
@property (nonatomic, assign) int sourceIndex;
@property (nonatomic, assign) int destinationIndex;
@property (nonatomic, assign) int jumpedIndex;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) alquerque_location sourceLocation;
@property (nonatomic, assign) alquerque_location destinationLocation;
@property (nonatomic, assign) alquerque_location jumpedLocation;
@property (nonatomic, assign) NSInteger error;

// Methods
- (NSAlquerqueMove *)initWithMoveFrom:(int)sIndex
                                   to:(int)dIndex
                              forGame:(NSAlquerqueGame *)game;

@end
