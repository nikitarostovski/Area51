//
//  Background.h
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BackgroundManager : NSObject

@property (weak, nonatomic) SKScene *scene;

- (id)initWithScene:(SKScene *)scene;
- (void)update:(CFTimeInterval)deltaTime;
- (void)scrollToBottomWithAnimationTime:(CGFloat)time;
- (void)launchPlane;

@end
