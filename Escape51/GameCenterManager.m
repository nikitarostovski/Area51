//
//  GameCenterManager.m
//  Escape51
//
//  Created by ROST on 12.04.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "GameCenterManager.h"
#import "AppDelegate.h"

#define LEADERBOARD_ID @"comozzesc51scores"

@interface GameCenterManager()

@property (nonatomic, strong) UIViewController *presentationController;

@end

@implementation GameCenterManager

#pragma mark Singelton

+ (instancetype)sharedManager {
    static GameCenterManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GameCenterManager alloc] init];
    });
    return sharedManager;
}

#pragma mark Initialization

- (id)init {
    self = [super init];
    if (self) {
        [self authenticatePlayer];
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.presentationController = del.window.rootViewController;
    }
    return self;
}

#pragma mark Player Authentication

- (void)authenticatePlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer setAuthenticateHandler:
     ^(UIViewController *viewController, NSError *error) {
         if (viewController != nil) {
             [self.presentationController presentViewController:viewController animated:YES completion:nil];
         } else if ([GKLocalPlayer localPlayer].authenticated) {
             NSLog(@"Player successfully authenticated");
         } else if (error) {
             NSLog(@"Game Center authentication error: %@", error);
         }
     }];
}

#pragma mark Leaderboard handling

- (void)showLeaderboard {
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = LEADERBOARD_ID;
    
    [self.presentationController presentViewController:gcViewController animated:YES completion:nil];
}

- (void)reportScore:(long long)score {
    GKScore *gScore = [[GKScore alloc] initWithLeaderboardIdentifier:LEADERBOARD_ID];
    gScore.value = score;
    gScore.context = 0;
    
    [GKScore reportScores:@[gScore] withCompletionHandler:nil];
}

#pragma mark GameKit Delegate Methods

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end