//
//  BonusManager.m
//  Escape51
//
//  Created by ROST on 03.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "BonusManager.h"
#import "BarrierManager.h"
#import "RBarrier.h"
#import "RHero.h"
#import "RBonus.h"
#import "RBonusData.h"
#import "GameScene.h"

static const CGFloat bonusDefaultSpeed = 300.0f;
static const CGFloat bonusHeight = 56.0f;
static const int kBonusAppearPeriod = 7;

@implementation BonusManager {
    NSMutableArray *bonuses;
    NSMutableArray *bonusesData;
    RBonus *lastBonus;
    CGFloat bonusSpeed;
    
    long long lastBonusScore;
}

- (id)initWithScene:(GameScene *)scene {
    self = [super init];
    if (self) {
        self.scene = scene;
        bonusSpeed = bonusDefaultSpeed;
        bonuses = [NSMutableArray array];
        bonusesData = [NSMutableArray array];
        for (int type = 0; type < (int) RBonusTypeMax; type++) {
            RBonusData *bonusData = [[RBonusData alloc] initWithType:type];
            [bonusesData addObject:bonusData];
        }
    }
    return self;
}

- (void)update:(CFTimeInterval)deltaTime {
    for (RBonus *b in bonuses) {
        [b.data update:deltaTime];
        [b setPosition:CGPointMake(b.position.x, b.position.y - bonusSpeed * deltaTime)];
    }
    
    for (RBonusData *d in bonusesData) {
        [d update:deltaTime];
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (RBonus *b in bonuses) {
        if (b.position.y < - self.scene.size.height / 2 - bonusHeight / 2) {
            [b removeAllActions];
            [b removeFromParent];
            [toRemove addObject:b];
        }
    }
    [bonuses removeObjectsInArray:toRemove];
    
    long long score = ((GameScene *)self.scene).curScore;
    if (score - lastBonusScore >= kBonusAppearPeriod) {
        lastBonusScore = score;
        [self addBonus];
    }
}

- (void)addBonus {
    RBarrier *lastBarrier = [_scene.barrierManager.barriers lastObject];
    
    RBonusData *data;
    data = [self randomBonus];
    if (!data) {
        return;
    }
    
    RBonus *b = [[RBonus alloc] initWithHeight:bonusHeight BonusData:data];
    CGFloat bonusPosX = arc4random() % 2 ? b.size.width : self.scene.size.width - b.size.width;
    [b setPosition:CGPointMake(bonusPosX, lastBarrier.position.y + lastBarrier.size.height / 2 + lastBarrier.distance / 2)];
    [_scene addChild:b];
    [bonuses addObject:b];
}

- (RBonusData *)randomBonus {
    RBonusData *bonus;
    int chanceTotal = 0;
    
    NSMutableArray *candidates = [NSMutableArray array];
    
    for (int i = 0; i < [bonusesData count]; i++) {
        RBonusData *bonusData = bonusesData[i];
        
        if (!(bonusData.type == RBonusTypeNewHero && [_scene.hero availableSkinsCount] == [_scene.hero totalSkinsCount]) && !(bonusData.type == RBonusTypeAddLife && _scene.livesCount == kBonusLivesMax)) {
            [candidates addObject:bonusData];
            chanceTotal += bonusData.chance;
        }
        
    }
    
    if (chanceTotal == 0) {
        return nil;
    }
    
    int chanceResult = arc4random() % chanceTotal;
    chanceTotal = 0;
    
    for (int i = 0; i < [candidates count]; i++) {
        RBonusData *bonusData = candidates[i];
        
        if (chanceTotal <= chanceResult && chanceResult < chanceTotal + bonusData.chance) {
            bonus = bonusData;
            break;
        }
        chanceTotal += bonusData.chance;
    }
    return bonus;
}

- (BOOL)bonusCheckForNode:(SKSpriteNode *)sprite {
    for (RBonus *b in bonuses) {
        if ([b checkForCollision:sprite] && ![b isEqual:lastBonus]) {
            lastBonus = b;
            [b removeFromParent];
            [bonuses removeObject:b];
            
            [b.data runBonusAtScene:_scene];
            
            return YES;
        }
    }
    return NO;
}

- (void)clearBonusesWithAnimtaionTime:(CGFloat)time {
    for (RBonus *b in bonuses) {
        [b removeFromParent];
    }
}

- (void)setBonusSpeedMultiplier:(CGFloat)bonusSpeedMultiplier {
    bonusSpeed = bonusDefaultSpeed * bonusSpeedMultiplier;
}

@end
