//
//  GameCenterManager.h
//  Escape51
//
//  Created by ROST on 12.04.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface GameCenterManager : NSObject <GKGameCenterControllerDelegate>

+ (instancetype)sharedManager;

- (void)authenticatePlayer;
- (void)showLeaderboard;
- (void)reportScore:(long long)score;

@end
