//
//  SKPSettingsButton.h
//  Escape51
//
//  Created by ROST on 09.04.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPButton.h"
#import "SKPixelSpriteNode.h"

@interface SKPSettingsButton : SKPixelSpriteNode

@property (nonatomic) SKPButton *button;
@property (nonatomic) SKPixelSpriteNode *icon;
@property (nonatomic) SKLabelNode *title;
@property (nonatomic) SKLabelNode *title2;
@property (nonatomic) NSString *titleText;

- (id)initWithImage:(NSString *)img Size:(CGSize)size Text:(NSString *)text Text2:(NSString *)text2;

@end
