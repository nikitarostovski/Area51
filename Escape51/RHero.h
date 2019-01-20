//
//  Hero.h
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@interface RHero : SKPixelSpriteNode

@property (nonatomic) CGFloat sizeMultiplier;
@property (nonatomic) bool godMode;
@property (nonatomic) bool immortal;
@property (nonatomic) bool canCollide;

- (id)initWithPosition:(CGPoint)pos Width:(CGFloat)width;
- (void)explode;
- (void)flash;
- (void)unlockRandomHero;
- (void)nextSkin;
- (void)prevSkin;

- (int)availableSkinsCount;
- (int)totalSkinsCount;

@end
