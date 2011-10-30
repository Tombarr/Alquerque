//
//  MainViewController.m
//  Alquerque
//
//  Created by Thomas Barrassi on 4/21/11.
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

#import "MainViewController.h"
#define DEFAULTS_FILE_NAME @"default-settings"
#define DEFAULTS_FILE_TYPE @"plist"

@implementation MainViewController

@synthesize game = _game,
            lastTag = _lastTag,
            images = _images,
            board = _board,
            session = _session,
            picker = _picker,
            peerID = _peerID,
            isConnected = _isConnected,
            pieceContainer = _pieceContainer;

#pragma mark - Alquerque Delegate

- (void)addPieceForPlayer:(NSInteger)player
                  atIndex:(NSInteger)index
{
    
}

- (void)removePieceFromPlayer:(NSInteger)player
                      atIndex:(NSInteger)index
{
    // Set piece to blank
    UIButton *removeLocation = (UIButton *) [self.pieceContainer viewWithTag:index];
    
    [removeLocation setImage:[UIImage imageNamed:[self.images objectForKey:@"blank"]]
                    forState:UIControlStateNormal];
}

- (void)movePlayers:(NSInteger)player
       pieceAtIndex:(NSInteger)originalIndex
            toIndex:(NSInteger)newIndex
{
    UIButton *originalLocation = (UIButton *) [self.pieceContainer viewWithTag:originalIndex];
    UIButton *newLocation = (UIButton *) [self.pieceContainer viewWithTag:newIndex];
    
    [newLocation setImage:[originalLocation
                           imageForState:UIControlStateNormal]
                                forState:UIControlStateNormal];
    [originalLocation setImage:[UIImage imageNamed:[self.images objectForKey:@"blank"]]
                      forState:UIControlStateNormal];
    
}

- (void)highlightAtIndex:(NSInteger)index
{
    // Set piece to blank
    UIButton *removeLocation = (UIButton *) [self.pieceContainer viewWithTag:index];
    
    [removeLocation setImage:[UIImage imageNamed:
                              [self.images objectForKey:@"highlight"]]
                    forState:UIControlStateNormal];
}

- (void)removeHighlightAtIndex:(NSInteger)index
{
    // Use removePieceFromPlayer method because all we need
    // to do is make the piece blank, same function.
    [self removePieceFromPlayer:-1 atIndex:index];
}

- (void)onInvalidMoveByPlayer:(NSInteger)player
                       OfType:(NSInteger)type
{
    // Check to see which message to display.
    NSString *message;
    if (type == INVALID_JUMP_OWN_PIECE)
        message = NSLocalizedString(@"INVALID_JUMP_OWN_PIECE",
                                    @"A player cannot jump their own piece.");
    else if (type == INVALID_DISTANCE_TOO_FAR)
        message = NSLocalizedString(@"INVALID_DISTANCE_TOO_FAR",
                                    @"A player can travel a maximum of two spaces, no more.");
    else if (type == INVALID_DIAGONAL_NOT_TRAVERSABLE)
        message = NSLocalizedString(@"INVALID_DIAGONAL_NOT_TRAVERSABLE",
                                    @"A player can only travel along certain diagonals.");
    else if (type == INVALID_DESTINATION_NOT_FREE)
        message = NSLocalizedString(@"INVALID_DESTINATION_NOT_FREE",
                                    @"A player cannot move onto another player.");
    else if (type == INVALID_ORIGIN_NOT_PLAYER)
        message = NSLocalizedString(@"INVALID_ORIGIN_NOT_PLAYER",
                                    @"A player can only move their pieces, not free spaces.");
    else if (type == INVALID_WRONG_PLAYERS_PIECE)
        message = NSLocalizedString(@"INVALID_WRONG_PLAYERS_PIECE",
                                    @"A player can only move their pieces, not their opponents.");
    else if (type == INVALID_NO_MOVE_MADE)
        message = NSLocalizedString(@"INVALID_NO_MOVE_MADE",
                                    @"A player cannot move to where they already are.");
    else if (type == INVALID_COMPELLED_JUMP_ELSEWHERE)
        message = NSLocalizedString(@"INVALID_COMPELLED_JUMP_ELSEWHERE", 
                                    @"A Player is compelled to move another piece because they can jump their opponents piece there.");
    
    // Show an alert that the move was illegal.
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INVALID_MOVE",
            @"Title informing the player that they have made an invalid move")
                                 message:message
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"CONFIRM_OK", @"OK")
                       otherButtonTitles:nil] autorelease] show];
    
    [self setLastTag:-1];
}

- (void)onWin:(NSInteger)player
{
    // Show an alert that the move was illegal.
    [[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"PLAYER_WON", @"This player is victorious"), (player == PLAYER_ONE) ? NSLocalizedString(@"PLAYER_ONE", @"The first player") : NSLocalizedString(@"PLAYER_TWO", @"The second player")]
                                 message:NSLocalizedString(@"CONGRATS", @"Congratulate the winning player")
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"CONFIRM_OK", @"OK")
                       otherButtonTitles:nil] autorelease] show];
}

// Resets the game board to its initial state.
- (void)onGameReady
{
    alquerque_location loc;
    int index;
    NSString *image;
    
    // Go through every piece and set it to its default image.
    for (UIButton *piece in self.pieceContainer.subviews)
    {
        index = [piece tag];
        loc = locationForIndex(index);
            
        if ([self.game state].board[loc.row][loc.column] == PLAYER_ONE)
            image = [self.images objectForKey:@"black"];
        else if ([self.game state].board[loc.row][loc.column] == PLAYER_TWO)
            image = [self.images objectForKey:@"white"];
        else if ([self.game state].board[loc.row][loc.column] == FREE_SPACE)
            image = [self.images objectForKey:@"blank"];
            
        [piece setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
}

#pragma mark - App Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Establish a few GameKit iVars
    [self setPicker:[[GKPeerPickerController alloc] init]];
	[self.picker setDelegate:self];
	[self.picker setConnectionTypesMask:GKPeerPickerConnectionTypeNearby];
	[self setPeerID:[[NSString alloc] init]];
        
    // Loads the images array if necessary.
    if (self.images == nil)
        [self loadImageArray];    
}

#pragma mark - Restore from saved state

// Restores a game from a supplied state.
- (void)restoreGameFromBoard:(NSMutableArray *)state
                   AndPlayer:(NSInteger)player
{
    [self loadImageArray];
    
    // Fetch defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Register defaults found in default-settings.plist
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:DEFAULTS_FILE_NAME ofType:DEFAULTS_FILE_TYPE]]];
    
    // Set last tag to a default < 0
    [self setLastTag:-1];
    
    // Initialize a game.
    self.game = [[NSAlquerqueGame alloc] initWithArray:state
                                      AndCurrentPlayer:player];
    [self.game setCompulsion:[defaults boolForKey:@"Compelled"]];
    
    // Use self as game delegate.
    [self.game setDelegate:self];
    
    // The game is now ready
    [[self.game delegate] onGameReady];
}

// Loads image array from icons.plist.
- (void)loadImageArray
{
    // Set image dictionary based on whether or not the device is an iPad.
    // I like this method because it gives me full control over which device gets what.
    NSString* iconsPlist = [[NSBundle mainBundle] pathForResource:@"icons" ofType:@"plist"];
    bool isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    self.images = [[NSDictionary alloc] initWithContentsOfFile:iconsPlist];
    if (isiPad)
        self.images = [self.images objectForKey:@"iPad"];
    else
        self.images = [self.images objectForKey:@"iPhone"];
}

#pragma mark - Create a new game

// Creates a game, starts from new.
- (void)createGame
{
    // Set last tag to a default < 0
    [self setLastTag:-1];
    
    // Fetch defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:DEFAULTS_FILE_NAME ofType:DEFAULTS_FILE_TYPE]]];
    
    // Initialize a game.
    self.game = [[NSAlquerqueGame alloc] init];
    [self.game setCompulsion:[defaults boolForKey:@"Compelled"]];
    
    // Use self as game delegate.
    [self.game setDelegate:self];
    
    // The game is now ready
    [[self.game delegate] onGameReady];
}

// Creates a new game.
- (IBAction)newGame:(id)sender
{
    [self createGame];
}

#pragma mark - Actions Info & Piece Clicked

// Bring up the back of the flipside.
- (IBAction)showInfo:(id)sender
{
    FlipsideViewController *controller;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        controller = [[FlipsideViewController alloc]
                      initWithNibName:@"FlipsideView-iPad" bundle:nil];
    }
    else
    {
        controller = [[FlipsideViewController alloc]
                      initWithNibName:@"FlipsideView" bundle:nil];
    }
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

// Called when a game piece is clicked
- (IBAction)pieceClicked:(id)sender
{
    int tag = [sender tag];
    
    // This is the first location clicked.
    if (self.lastTag == -1)
    {
        self.lastTag = tag;
        return;
    }
    else
    {
        // Move pieces.
        [self.game movePieceAtIndex:self.lastTag toIndex:tag];
        
        if (self.isConnected)
        {
            NSString *str = [NSString stringWithFormat:@"%i,%i", self.lastTag, tag];
            [self.session sendData:[str dataUsingEncoding:NSASCIIStringEncoding]
                           toPeers:[[NSMutableArray alloc] initWithObjects:self.peerID, nil]
                      withDataMode:GKSendDataReliable
                             error:nil];
        }
        
        // Reset lastTag to default.
        self.lastTag = -1;
    }
}

#pragma mark - Flipside & Orientation.

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

// Support all orientations.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Memory, Unload, & Dealloc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

// Custom view did unlod
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setBoard:nil];
    [self setPieceContainer:nil];
}

/*
 * The peer was connected to a GKSession.
 */

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    [self setPeerID:peerID];
    [self setIsConnected:YES];
    
	// Use a retaining property to take ownership of the session.
    [self setSession:session];
    
	// Assumes our object will also become the session's delegate.
    [session setDelegate:self];
    
    [session setDataReceiveHandler:self withContext:nil];
    
	// Remove the picker.
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
    
	// Start your game.
}

/*
 * The peer has send us data.
 */
- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    // Read the bytes in data and perform an application-specific action.
    
	NSString *str;
	str = [[NSString alloc] initWithData:data
                                 encoding:NSASCIIStringEncoding];
    NSArray *positions = [str componentsSeparatedByString:@","];
    int from = [[positions objectAtIndex:0] intValue],
        to = [[positions objectAtIndex:1] intValue];
    [self.game movePieceAtIndex:from toIndex:to];
}

#pragma mark GameSessionDelegate stuff

/*
 * Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state
{
	if (state == GKPeerStateConnected)
    {
        [self setPeerID:peerID];
        [self setIsConnected:YES];
    }
    else if (state == GKPeerStateDisconnected)
    {
        [self setPeerID:[[NSString alloc] init]];
        [self setIsConnected:NO];
    }
}

// Custom dealloc
- (void)dealloc
{
    [_peerID release];
    [_picker release];
    [_session release];
    [_pieceContainer release];
    [_board release];
    [_images release];
    [_game release];
    [super dealloc];
}

@end
