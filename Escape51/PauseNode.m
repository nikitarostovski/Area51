//
//  PauseNode.m
//  Escape51
//
//  Created by ROST on 14.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "PauseNode.h"

static const CGFloat kAnimationSpeed = 0.15f;

@implementation PauseNode

- (id)initWithSize:(CGSize)size {
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"Pause_hint"] color:[UIColor clearColor] size:size];
    if (self) {
        self.zPosition = 100;
        self.alpha = 0.0f;
    }
    return self;
}

- (void)show {
    [self runAction:[SKAction fadeInWithDuration:kAnimationSpeed]];
}

- (void)hide {
    [self runAction:[SKAction fadeOutWithDuration:kAnimationSpeed]];
}

@end