//
//  GameScene.h
//  Escape51
//

//  Copyright (c) 2016 ROST. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"

@class BarrierManager;
@class BackgroundManager;
@class BonusManager;
@class RHero;

@protocol GameSceneDelegate
@required

- (void)gameIsOverWithScore:(NSNumber *)score;

@end

static const int kBonusLivesMax = 3;

@interface GameScene : SKScene

@property (nonatomic) long long curScore;
@property (nonatomic) CGFloat heroWidth;
@property (nonatomic) CGPoint heroStartPoint;
@property (nonatomic) CGFloat heroMoveSpeed;
@property (weak, nonatomic) id<GameSceneDelegate> gameDelegate;

@property (nonatomic) BarrierManager *barrierManager;
@property (nonatomic) BonusManager *bonusManager;
@property (nonatomic) BackgroundManager *backManager;
@property (nonatomic) RHero *hero;
@property (nonatomic) int livesCount;
@property (nonatomic) CGFloat additionalSpeedMult;

- (void)play;
- (void)pause;

@end
