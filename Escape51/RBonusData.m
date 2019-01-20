//
//  RBonusData.m
//  Escape51
//
//  Created by ROST on 08.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "RBonusData.h"
#import "GameScene.h"
#import "BarrierManager.h"
#import "BonusManager.h"
#import "BackgroundManager.h"
#import "RHero.h"
#import "SKPixelSpriteNode.h"
#import "SKEase.h"

static const CGFloat kBonusDuration = 5.0f;

static const CGFloat kSpeedMult = 1.35f;
static const CGFloat kSizeMult = 1.35f;
static const CGFloat kBarrierMult = 0.75f;

@implementation RBonusData {
    __weak GameScene *_scene;
    SKPixelSpriteNode *lowVisibilitySprite;
}

- (id)initWithType:(RBonusType)t {
    self = [super init];
    if (self) {
        _duration = kBonusDuration;
        _type = t;
        
        switch (_type) {
            case RBonusTypeAddLife:                 { _chance = 5; break; }
            case RBonusTypeBoost:                   { _chance = 7; break; }
            case RBonusTypeEnlarge:                 { _chance = 10; break; }
            case RBonusTypeLowVisibility:           { _chance = 3; break; }
            case RBonusTypeShortBarrierDistance:    { _chance = 10; break; }
            case RBonusTypeGod:                     { _chance = 10; break; }
            case RBonusTypeNewHero:                 { _chance = 3; break; }
            default:
                break;
        }

        
        _timePassed = 0;
        _enabled = NO;
    }
    return self;
}

- (void)update:(CGFloat)delta {
    if (_enabled) {
        _timePassed += delta;
        if (_timePassed >= kBonusDuration) {
            [self bonusDisable];
        }
    }
}

- (void)runBonusAtScene:(GameScene *)scene {
    if (_enabled) {
        _timePassed = 0;
    }
    _scene = scene;
    
    
    switch (_type) {
        case RBonusTypeAddLife: {
            if (_scene.livesCount < kBonusLivesMax) {
                _scene.livesCount++;
            }
            break;
        }
        case RBonusTypeBoost: {
            [_scene setAdditionalSpeedMult:kSpeedMult];
            break;
        }
        case RBonusTypeEnlarge: {
            [_scene.hero setSizeMultiplier:kSizeMult];
            break;
        }
        case RBonusTypeLowVisibility: {
            [lowVisibilitySprite removeFromParent];
            lowVisibilitySprite = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Zeppelin"];
            [lowVisibilitySprite setSize:CGSizeMake(_scene.size.width, lowVisibilitySprite.size.height * _scene.size.width / lowVisibilitySprite.size.width)];
            [lowVisibilitySprite setPosition:CGPointMake(_scene.size.width * 3 / 2, _scene.size.height - lowVisibilitySprite.size.height / 2)];
            [lowVisibilitySprite setZPosition:98];
            [_scene addChild:lowVisibilitySprite];
            [lowVisibilitySprite runAction:[SKEase MoveToWithNode:lowVisibilitySprite EaseFunction:CurveTypeQuadratic Mode:EaseInOut Time:1.0f ToVector:CGVectorMake(_scene.size.width / 2, lowVisibilitySprite.position.y)]];
            break;
        }
        case RBonusTypeShortBarrierDistance: {
            [_scene.barrierManager setBarrierDistanceMultiplier:kBarrierMult];
            break;
        }
        case RBonusTypeGod: {
            [_scene.hero setImmortal:YES];
            break;
        }
        case RBonusTypeNewHero: {
            [_scene.hero unlockRandomHero];
            break;
        }
        default:
            break;
    }
    _enabled = YES;
}

- (void)bonusDisable {
    _enabled = NO;
    _timePassed = 0;
    
    switch (_type) {
        case RBonusTypeAddLife: {
            break;
        }
        case RBonusTypeBoost: {
            [_scene setAdditionalSpeedMult:1.0];
            break;
        }
        case RBonusTypeEnlarge: {
            [_scene.hero setSizeMultiplier:1.0];
            break;
        }
        case RBonusTypeLowVisibility: {
            [lowVisibilitySprite runAction:[SKEase MoveToWithNode:lowVisibilitySprite EaseFunction:CurveTypeQuadratic Mode:EaseInOut Time:1.0f ToVector:CGVectorMake(-_scene.size.width / 2, lowVisibilitySprite.position.y)]];
            break;
        }
        case RBonusTypeShortBarrierDistance: {
            [_scene.barrierManager setBarrierDistanceMultiplier:1.0];
            break;
        }
        case RBonusTypeGod: {
            [_scene.hero setImmortal:NO];
            break;
        }
        default:
            break;
    }
}

@end
