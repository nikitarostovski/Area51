//
//  BarrierManager.h
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RBonus.h"

@class GameScene;

@interface BarrierManager : NSObject

@property (nonatomic) CGFloat barrierDistanceMultiplier;
@property (nonatomic) CGFloat barrierSpeedMultiplier;
@property (nonatomic, readonly) CGFloat barrierDistance;
@property (nonatomic, readonly) NSMutableArray *barriers;
@property (weak, nonatomic) GameScene *scene;

- (id)initWithScene:(GameScene *)scene;
- (void)update:(CFTimeInterval)deltaTime;
- (BOOL)collisionCheckForNode:(SKSpriteNode *)sprite;
- (long long)barriersPassed:(CGFloat)position;
- (void)clearBarriersWithAnimtaionTime:(CGFloat)time;

@end
