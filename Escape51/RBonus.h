//
//  RBonus.h
//  Escape51
//
//  Created by ROST on 16.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@class GameScene;
@class RBarrier;
@class RBonusData;

@interface RBonus : SKPixelSpriteNode

@property (nonatomic, weak) GameScene *parentScene;
@property (nonatomic) RBonusData *data;

- (id)initWithHeight:(CGFloat)height BonusData:(RBonusData *)bData;
- (bool)checkForCollision:(SKSpriteNode *)node;

@end
