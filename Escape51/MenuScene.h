//
//  MenuScene.h
//  Escape51
//
//  Created by ROST on 14.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol MenuSceneDelegate
@required

- (void)showGame;
- (void)showScores;

@end

@interface MenuScene : SKScene

@property (weak, nonatomic) id<MenuSceneDelegate> menuDelegate;
@property (nonatomic) CGPoint heroStartPos;
@property (nonatomic) CGFloat heroStartWidth;
@property (nonatomic) long long int maxScore;

@end
