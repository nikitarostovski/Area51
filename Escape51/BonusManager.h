//
//  BonusManager.h
//  Escape51
//
//  Created by ROST on 03.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GameScene;

@interface BonusManager : NSObject

@property (nonatomic) CGFloat bonusSpeedMultiplier;
@property (weak, nonatomic) GameScene *scene;

- (id)initWithScene:(GameScene *)scene;
- (void)update:(CFTimeInterval)deltaTime;
- (BOOL)bonusCheckForNode:(SKSpriteNode *)sprite;
- (void)clearBonusesWithAnimtaionTime:(CGFloat)time;

@end
