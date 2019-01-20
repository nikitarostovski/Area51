//
//  RBarrier.h
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@class GameScene;

typedef enum {
    RBarrierTypeBasic,
    RBarrierTypeMoving,
    RBarrierTypeSingle,
    RBarrierTypeDouble,
    
    RBarrierTypeMax
} RBarrierType;

typedef enum {
    RMovingBarrierDirectionLeftToRight,
    RMovingBarrierDirectionRightToLeft
} RBarrierMoveDirection;

@interface RBarrier : SKPixelSpriteNode

@property (nonatomic) long long number;
@property (nonatomic) RBarrierType type;
@property (nonatomic) RBarrierMoveDirection direction;
@property (nonatomic) CGFloat distance;
@property (nonatomic) CGFloat movingSpeed;

- (id)initWithPosition:(CGPoint)pos Scene:(GameScene *)scene;
- (bool)checkForCollision:(SKSpriteNode *)node;
- (void)removeFromScreenAnimationTime:(CGFloat)time;
- (void)update:(CGFloat)deltaTime;

@end
