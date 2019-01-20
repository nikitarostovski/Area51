//
//  SKPButton.h
//  Escape51
//
//  Created by ROST on 15.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "SKPixelSpriteNode.h"

@interface SKPButton : SKPixelSpriteNode

@property (nonatomic, nullable) NSString *defaultImageName;
@property (nonatomic, nullable) NSString *selectedImageName;
@property (nonatomic, nullable) NSString *disabledImageName;

- (nonnull id)initWithDefaultImage:(nonnull NSString *)def SelectedImage:(nullable NSString *)sel DisabledImage:(nullable NSString *)dis;
- (void)addTarget:(nonnull id)target action:(nonnull SEL)action;
- (void)setSelected:(BOOL)selected;
- (void)setDisabled:(BOOL)disabled;

- (void)updateState;

@end
