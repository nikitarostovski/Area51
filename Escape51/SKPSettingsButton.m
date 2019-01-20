//
//  SKPSettingsButton.m
//  Escape51
//
//  Created by ROST on 09.04.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPSettingsButton.h"

@implementation SKPSettingsButton

- (id)initWithImage:(NSString *)img Size:(CGSize)size Text:(NSString *)text Text2:(NSString *)text2 {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        CGFloat iconOffset = size.height * 0.2f;
        
        _icon = [[SKPixelSpriteNode alloc] initWithImageNamed:img];
        [_icon setSize:CGSizeMake(size.height, size.height)];
        [_icon setPosition:CGPointMake(-size.width / 2 + _icon.size.width / 2, 0)];
        [self addChild:_icon];
        
        _title = [[SKLabelNode alloc] initWithFontNamed:@"Pixel Emulator"];
        _title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _title.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        if (![text2 length]) {
            [_title setPosition:CGPointMake(- size.width / 2 + _icon.size.width + iconOffset, 0)];
        } else {
            [_title setPosition:CGPointMake(- size.width / 2 + _icon.size.width + iconOffset, size.height / 4)];
        }
        [_title setFontColor:[UIColor blackColor]];
        [_title setFontSize:26.0];
        [_title setText:text];
        if (![text2 length]) {
            [self adjustLabelFontSizeToFitRect:_title Size:CGSizeMake(size.width - _icon.size.width - iconOffset, size.height)];
        } else {
            [self adjustLabelFontSizeToFitRect:_title Size:CGSizeMake(size.width - _icon.size.width - iconOffset, size.height / 4)];
        }
        [self addChild:_title];
        
        if ([text2 length]) {
            _title2 = [[SKLabelNode alloc] initWithFontNamed:_title.fontName];
            _title2.horizontalAlignmentMode = _title.horizontalAlignmentMode;
            _title2.verticalAlignmentMode = _title.verticalAlignmentMode;
            [_title2 setPosition:CGPointMake(_title.position.x, -size.height / 4)];
            [_title2 setFontColor:_title.fontColor];
            [_title2 setFontSize:_title.fontSize];
            [_title2 setText:text2];
            
            [self addChild:_title2];
        }
        
        _button = [[SKPButton alloc] initWithDefaultImage:@"" SelectedImage:@"" DisabledImage:@""];
        [_button setSize:size];
        [self addChild:_button];
    }
    return self;
}

- (void)adjustLabelFontSizeToFitRect:(SKLabelNode *)labelNode Size:(CGSize)size {
    double scalingFactor = MIN(size.width / labelNode.frame.size.width, size.height / labelNode.frame.size.height);
    labelNode.fontSize *= scalingFactor;
}

@end