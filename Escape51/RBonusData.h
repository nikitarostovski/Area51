//
//  RBonusData.h
//  Escape51
//
//  Created by ROST on 08.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GameScene;

typedef NS_ENUM(int, RBonusType) {
    RBonusTypeEnlarge,
    RBonusTypeLowVisibility,
    RBonusTypeShortBarrierDistance,
    RBonusTypeAddLife,
    RBonusTypeBoost,
    RBonusTypeGod,
    RBonusTypeNewHero,
    
    RBonusTypeMax
};

@interface RBonusData : NSObject

@property (nonatomic) RBonusType type;
@property (nonatomic) CGFloat duration;

@property (nonatomic) int chance;
@property (nonatomic) bool enabled;
@property (nonatomic) CGFloat timePassed;

- (id)initWithType:(RBonusType)t;
- (void)update:(CGFloat)delta;
- (void)runBonusAtScene:(GameScene *)scene;

@end
