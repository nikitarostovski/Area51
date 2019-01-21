//
//  GameViewController.m
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright (c) 2016 ROST. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"

static const CGFloat kHeroWidth = 48.0f;
static const CGFloat kHeroPositionY = 280.0f;
static const CGFloat kHeroMoveSpeed = 2.5f;

@interface GameViewController () <MenuSceneDelegate, GameSceneDelegate/*, GameCenterManagerDelegate*/>

@end

@implementation GameViewController {
    long long maxScore;
    bool gameCenterEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[GameCenterManager sharedManager] setDelegate:self];
    
    maxScore = [[[NSUserDefaults standardUserDefaults] valueForKey:@"score"] longLongValue];
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    skView.ignoresSiblingOrder = YES;
    [skView presentScene:[self createMenuScene]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate musicPlay];
}

- (CGSize)sceneSize {
    CGSize originalSize = CGSizeMake(320, 480);
    CGFloat widthCoeff = originalSize.width / self.view.frame.size.width;
    CGFloat heightCoeff = originalSize.height / self.view.frame.size.height;
    CGFloat maxCoeff = MAX(widthCoeff, heightCoeff);
    
    CGSize screenScaled = CGSizeMake(self.view.frame.size.width * maxCoeff, self.view.frame.size.height * maxCoeff);
    return screenScaled;
}

- (SKScene *)createMenuScene {
    MenuScene *scene = [[MenuScene alloc] initWithSize:[self sceneSize]];
    scene.maxScore = maxScore;
    scene.heroStartWidth = kHeroWidth;
    scene.heroStartPos = CGPointMake(scene.size.width / 2, scene.size.height - kHeroPositionY);
    scene.menuDelegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    return scene;
}

- (SKScene *)createGameScene {
    GameScene *scene = [[GameScene alloc] initWithSize:[self sceneSize]];
    scene.heroMoveSpeed = kHeroMoveSpeed;
    scene.heroWidth = kHeroWidth;
    scene.gameDelegate = self;
    scene.heroStartPoint = CGPointMake(scene.size.width / 2, scene.size.height - kHeroPositionY);
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    return scene;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Scene delegate methods

- (void)showScores {
    [[GameCenterManager sharedManager] showLeaderboard];
}

- (void)showGame {
    SKView * skView = (SKView *)self.view;
    [skView presentScene:[self createGameScene]];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).scene = (GameScene *)skView.scene;
}

- (void)gameIsOverWithScore:(NSNumber *)score {
    if ([score longLongValue] > maxScore) {
        maxScore = [score longLongValue];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:@(maxScore) forKey:@"score"];
        [defs synchronize];
        [[GameCenterManager sharedManager] reportScore:maxScore];
    }
    
    SKView * skView = (SKView *)self.view;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).scene = nil;
    [skView presentScene:[self createMenuScene]];
}

@end
