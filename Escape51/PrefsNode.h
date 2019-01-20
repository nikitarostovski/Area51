//
//  PrefsNode.h
//  Escape51
//
//  Created by ROST on 16.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@protocol PrefsNodeDelegate

- (void)prefsClose;

@end

@interface PrefsNode : SKPixelSpriteNode

@property id<PrefsNodeDelegate>delegate;

- (id)initWithSize:(CGSize)size Delegate:(id<PrefsNodeDelegate>)delegate;

@end
