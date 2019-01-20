//
//  RBonus.m
//  Escape51
//
//  Created by ROST on 16.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "RBonus.h"
#import "RBonusData.h"

@implementation RBonus

- (id)initWithHeight:(CGFloat)height BonusData:(RBonusData *)bData {
    NSString *fName = @"";
    switch (bData.type) {
        case RBonusTypeAddLife:                 { fName = @"b_life"; break; }
        case RBonusTypeNewHero:                 { fName = @"b_newhero"; break; }
        case RBonusTypeBoost:                   { fName = @"b_boost"; break; }
        case RBonusTypeEnlarge:                 { fName = @"b_enlarge"; break; }
        case RBonusTypeLowVisibility:           { fName = @"b_zeppelin"; break; }
        case RBonusTypeShortBarrierDistance:    { fName = @"b_complexity"; break; }
        case RBonusTypeGod:                     { fName = @"b_god"; break; }
        default:
            break;
    }
    self = [super initWithImageNamed:fName];
    if (self) {
        CGFloat coeff = height / self.size.height;
        [self setSize:CGSizeMake(self.size.width * coeff, height)];
        [self setZPosition:3];
        
        _data = bData;
    }
    return self;
}

- (bool)checkForCollision:(SKSpriteNode *)node {
    return CGRectIntersectsRect(self.frame, node.frame);
}

@end