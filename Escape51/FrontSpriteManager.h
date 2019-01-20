//
//  FrontSpriteManager.h
//  Escape51
//
//  Created by ROST on 25.03.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FrontSpriteData;

@interface FrontSpriteManager : NSObject

- (id)initWithArray:(NSArray *)array;
- (FrontSpriteData *)randomSprite;

@end
