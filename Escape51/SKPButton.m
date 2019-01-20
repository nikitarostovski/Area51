//
//  SKPButton.m
//  Escape51
//
//  Created by ROST on 15.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPButton.h"

@implementation SKPButton {
    id _target;
    SEL _action;
    
    BOOL _selected;
    BOOL _disabled;
}

- (id)initWithDefaultImage:(NSString *)def SelectedImage:(NSString *)sel DisabledImage:(NSString *)dis {
    self = [super initWithImageNamed:def];
    if (self) {
        [self setDefaultImageName:def];
        [self setSelectedImageName:sel];
        [self setDisabledImageName:dis];
        [self setDisabled:NO];
        [self setSelected:NO];
        [self setUserInteractionEnabled:YES];
        [self updateState];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSelected:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSelected:NO];
    if (!CGRectContainsPoint(self.frame, [[touches anyObject] locationInNode:self.parent]))
        return;
    if (!_target) {
        return;
    }
    IMP imp = [_target methodForSelector:_action];
    void (*func)(id, SEL) = (void *)imp;
    func(_target, _action);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSelected:NO];
}

- (void)addTarget:(nonnull id)target action:(nonnull SEL)action {
    _target = target;
    _action = action;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateState];
}

- (void)setDisabled:(BOOL)disabled {
    _disabled = disabled;
    [self updateState];
}

- (SKTexture *)textureForFileName:(NSString *)fName {
    UIImage *image = [UIImage imageNamed:fName];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    SKTexture *result = [SKTexture textureWithImage:image];
    return result;
}

- (void)updateState {
    if (_disabled) {
        if (!self.disabledImageName) {
            [self setTexture:[self textureForFileName:self.defaultImageName]];
        } else {
            [self setTexture:[self textureForFileName:self.disabledImageName]];
        }
    } else if (_selected) {
        if (!self.selectedImageName) {
            [self setTexture:[self textureForFileName:self.defaultImageName]];
        } else {
            [self setTexture:[self textureForFileName:self.selectedImageName]];
        }
    } else {
        [self setTexture:[self textureForFileName:self.selectedImageName]];
    }
}

@end
