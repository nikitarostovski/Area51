//
//  FrontSpriteManager.m
//  Escape51
//
//  Created by ROST on 25.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "FrontSpriteManager.h"
#import "FrontSpriteData.h"

static const int kWindSpeedLow = 10.0f;
static const int kWindSpeedHigh = 50.0f;

@implementation FrontSpriteManager {
    NSMutableArray *spritesData;
}

- (id)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        spritesData = [NSMutableArray array];
        for (NSDictionary *d in array) {
            FrontSpriteData *newSpriteData = [[FrontSpriteData alloc] init];
            [newSpriteData setFileName:d[@"image"]];
            [newSpriteData setChance:[d[@"chance"] intValue]];
            CGFloat windSpeed = kWindSpeedLow + arc4random() % (kWindSpeedHigh - kWindSpeedLow);
            [newSpriteData setWindSpeed:windSpeed];
            
            [spritesData addObject:newSpriteData];
        }
    }
    return self;
}

- (FrontSpriteData *)randomSprite {
    FrontSpriteData *sprite;
    int chanceTotal = 0;
    
    NSMutableArray *candidates = [NSMutableArray array];
    
    for (int i = 0; i < [spritesData count]; i++) {
        FrontSpriteData *data = spritesData[i];
        
        [candidates addObject:data];
        chanceTotal += data.chance;
        
    }
    
    if (chanceTotal == 0) {
        return nil;
    }
    
    int chanceResult = arc4random() % chanceTotal;
    chanceTotal = 0;
    
    for (int i = 0; i < [candidates count]; i++) {
        FrontSpriteData *data = candidates[i];
        
        if (chanceTotal <= chanceResult && chanceResult < chanceTotal + data.chance) {
            sprite = data;
            break;
        }
        chanceTotal += data.chance;
    }
    return sprite;
}

@end
