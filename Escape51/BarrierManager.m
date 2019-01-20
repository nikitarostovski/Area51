//
//  BarrierManager.m
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "BarrierManager.h"
#import "RBarrier.h"
#import "GameScene.h"

static const CGFloat barrierDefaultSpeed = 300.0f;
static const CGFloat barrierDefaultDistance = 150.0f;

@implementation BarrierManager {
    CGFloat barrierSpawnPointY;
    CGFloat movingBarrierSpeed;
    CGFloat barrierSpeed;
    
    RBarrier *lastBarrier;
}

- (id)initWithScene:(GameScene *)scene {
    self = [super init];
    if (self) {
        self.scene = scene;
        _barriers= [NSMutableArray array];
        _barrierDistance = barrierDefaultDistance;
        barrierSpeed = barrierDefaultSpeed;
        barrierSpawnPointY = self.scene.size.height * 1.25f;
        
        [self addBarrier];
    }
    return self;
}

- (void)addBarrier {
    RBarrier *topBarrier = [_barriers lastObject];
    CGFloat lastPositionY = [_barriers count] ? topBarrier.position.y : barrierSpawnPointY;
    
    long long score = [_barriers count] ? [topBarrier number] + 1 : 1;
    
    RBarrier *b = [[RBarrier alloc] initWithPosition:CGPointMake(0, lastPositionY - _barrierDistance + topBarrier.size.height) Scene:_scene];
    b.number = score;
    [b setDistance:_barrierDistance];
    
    [_barriers addObject:b];
    [self.scene addChild:b];
}

- (void)update:(CFTimeInterval)deltaTime {
    RBarrier *topBarrier = [_barriers lastObject];
    if (topBarrier.position.y < barrierSpawnPointY - topBarrier.distance - topBarrier.size.height) {
        [self addBarrier];
    }
    
    for (int i = 0; i < [_barriers count]; i++) {
        RBarrier *curBarrier = _barriers[i];
        if (i == 0) {
            CGFloat moveDelta = barrierSpeed * deltaTime;
            [curBarrier setPosition:CGPointMake(curBarrier.position.x, curBarrier.position.y - moveDelta)];
            continue;
        }
        
        RBarrier *nextBarrier = _barriers[i - 1];
        [curBarrier update:deltaTime];
        [curBarrier setPosition:CGPointMake(curBarrier.position.x, nextBarrier.position.y + nextBarrier.size.height / 2 + curBarrier.size.height / 2 + nextBarrier.distance)];
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (RBarrier *b in _barriers) {
        if (b.position.y < - self.scene.size.height / 2 - topBarrier.size.height / 2) {
            [b removeAllActions];
            [b removeFromParent];
            [toRemove addObject:b];
        }
    }
    [_barriers removeObjectsInArray:toRemove];
}

- (BOOL)collisionCheckForNode:(SKSpriteNode *)sprite {
    for (RBarrier *barrier in _barriers) {
        if ([barrier checkForCollision:sprite] && ![barrier isEqual:lastBarrier]) {
            lastBarrier = barrier;
            return YES;
        }
    }
    return NO;
}

- (long long)barriersPassed:(CGFloat)position {
    RBarrier *closest;
    for (RBarrier *barrier in _barriers) {
        if (barrier.position.y >= position)
            continue;
        
        if (!closest) {
            closest = barrier;
            continue;
        }
        if (position - barrier.position.y < position - closest.position.y) {
            closest = barrier;
        }
    }
    if (!closest) {
        for (RBarrier *barrier in _barriers) {
            if (!closest) {
                closest = barrier;
                continue;
            }
            if (barrier.position.y < closest.position.y) {
                closest = barrier;
            }
        }
        return [closest number] - 1;
    }
    return [closest number];
}

- (void)clearBarriersWithAnimtaionTime:(CGFloat)time {
    for (RBarrier *b in _barriers) {
        [b removeFromScreenAnimationTime:time];
    }
}

- (void)setBarrierSpeedMultiplier:(CGFloat)barrierSpeedMultiplier {
    barrierSpeed = barrierDefaultSpeed * barrierSpeedMultiplier;
}

- (void)setBarrierDistanceMultiplier:(CGFloat)barrierDistanceMultiplier {
    _barrierDistance = barrierDefaultDistance * barrierDistanceMultiplier;
}

@end

