//
//  SKSpriteNode+PixelArt.m
//  Escape51
//
//  Created by ROST on 14.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@implementation SKPixelSpriteNode

- (id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if (self) {
        [self setFiltering];
    }
    return self;
}

- (id)initWithTexture:(SKTexture *)texture color:(nonnull UIColor *)color size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        [self setFiltering];
    }
    return self;
}

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        [self setFiltering];
    }
    return self;
}

- (void)setTexture:(SKTexture *)texture {
    [super setTexture:texture];
    [self setFiltering];
}

- (void)setFiltering {
    self.texture.filteringMode = SKTextureFilteringNearest;
}

@end
