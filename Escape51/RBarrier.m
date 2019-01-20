//
//  RBarrier.m
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "RBarrier.h"
#import "SKEase.h"
#import "GameScene.h"

static const CGFloat kMovingBarrierDefaultSpeed = 70.0f;
static const CGFloat kGateMin = 90.0f;
static const long long kGateMinScore = 75;
static const CGFloat kGateMax = 110.0f;
static const CGFloat kBarrierHeight = 50.0f;

typedef struct BarrierGap {
    CGFloat startPos;
    CGFloat endPos;
} BarrierGap;

@implementation RBarrier {
    NSMutableArray *barrierNodes;
    NSMutableArray *barrierGaps;
    
    CGFloat gateWidth;
    CGFloat sceneWidth;
    
    CGFloat gapsStartPos;
    CGFloat gapsEndPos;
}

static RBarrierType lastType = RBarrierTypeMoving;

- (id)initWithPosition:(CGPoint)pos Scene:(GameScene *)scene {
    self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(MAXFLOAT, kBarrierHeight)];
    if (self) {
        long long score = scene.curScore;
        sceneWidth = scene.size.width;
        gateWidth = [self gateWidthForScore:score];
        
        do {
            _type = arc4random() % RBarrierTypeMax;
        } while (_type == lastType);
        lastType = _type;
        
        _movingSpeed = kMovingBarrierDefaultSpeed;
        _direction = arc4random() % 2;
        CGFloat minBarrierWidth = 30.0f;
        
        int gapCount;
        
        switch (_type) {
            case RBarrierTypeBasic:
                gapCount = 1;
                break;
            case RBarrierTypeMoving:
                gapCount = 1;
                break;
            case RBarrierTypeSingle:
                gateWidth = kGateMin;
                gapCount = 1;
                break;
            case RBarrierTypeDouble:
                gapCount = 2;
                break;
                
            default:
                gapCount = 1;
        }
        
        
        gapsStartPos = 0;
        gapsEndPos = 0;
        
        barrierGaps = [NSMutableArray array];
        for (int i = 0; i < gapCount; i++) {
            BarrierGap gap;
            gap.startPos = scene.size.width * i / gapCount + minBarrierWidth / 2 + arc4random() % (int)(scene.size.width / gapCount - gateWidth - minBarrierWidth);
            gap.endPos = gap.startPos + gateWidth;
            
            NSValue *gapValue = [NSValue valueWithBytes:&gap objCType:@encode(BarrierGap)];
            [barrierGaps addObject:gapValue];
            
            if (i == 0) {
                gapsStartPos = gap.startPos;
                gapsEndPos = gap.endPos;
                continue;
            }
            
            if (gap.startPos < gapsStartPos)
                gapsStartPos = gap.startPos;
            if (gap.endPos > gapsEndPos)
                gapsEndPos = gap.endPos;
        }
        
        int showBarrierIndex = 0;
        if (gapsStartPos < (sceneWidth - gapsEndPos)) {
            showBarrierIndex = 1;
        }
        
        barrierNodes = [NSMutableArray array];
        CGFloat startPos = 0;
        for (int i = 0; i < gapCount + 1; i++) {
            CGFloat endPos = scene.size.width;
            CGFloat width = endPos - startPos;
            if (i < gapCount) {
                BarrierGap gapValue;
                NSValue *value = [barrierGaps objectAtIndex:i];
                [value getValue:&gapValue];
                endPos = gapValue.endPos;
                width = gapValue.startPos - startPos;
            }
            
            
            if (!(_type == RBarrierTypeSingle && i != showBarrierIndex)) {
                if (i == 0 || i == gapCount) {
                    width += scene.size.width;
                }
                
                SKSpriteNode *node = [self createBarrierNodeWithSize:CGSizeMake(width, self.size.height)];
                if (i == 0) {
                    [node setPosition:CGPointMake(startPos + node.size.width / 2 - scene.size.width, 0)];
                } else {
                    [node setPosition:CGPointMake(startPos + node.size.width / 2, 0)];
                }
                [self addChild:node];
                [barrierNodes addObject:node];
            }
            
            startPos = endPos;
        }
        
        [self setPosition:pos];
    }
    return self;
}

- (CGFloat)gateWidthForScore:(long long)score {
    CGFloat result = MAX(kGateMax + (kGateMin - kGateMax) * ((float)score / (float)kGateMinScore), kGateMin);
    return result;
}

- (bool)checkForCollision:(SKSpriteNode *)node {
    for (SKSpriteNode *childNode in barrierNodes) {
        CGRect childNodeFrame = CGRectMake(self.position.x + childNode.frame.origin.x, self.position.y + childNode.frame.origin.y, childNode.frame.size.width, childNode.frame.size.height);
        if (CGRectIntersectsRect(childNodeFrame, node.frame)) {
            return YES;
        }
    }
    return NO;
}

- (void)removeFromScreenAnimationTime:(CGFloat)time {
    for (SKSpriteNode *node in barrierNodes) {
        if (node.position.x <= sceneWidth / 2) {
            [node runAction:[SKEase MoveToWithNode:node EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:time ToVector:CGVectorMake(node.position.x - node.size.width * 3 / 2 - sceneWidth, node.position.y)]];
        } else {
            [node runAction:[SKEase MoveToWithNode:node EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:time ToVector:CGVectorMake(node.position.x + node.size.width * 3 / 2 + sceneWidth, node.position.y)]];
        }
    }
}

- (SKSpriteNode *)createBarrierNodeWithSize:(CGSize)size {
    int initHeight = 30;
    int initWidth = size.width / size.height * initHeight;
    
    int borderSize = 4;
    
    UIImage *topLeft = [self imageWithImage:[UIImage imageNamed:@"Barrier_topleft"] scaledToSize:CGSizeMake(borderSize, borderSize)];
    UIImage *bottomLeft = [self imageWithImage:[UIImage imageNamed:@"Barrier_bottomleft"] scaledToSize:CGSizeMake(borderSize, borderSize)];
    UIImage *topRight = [self imageWithImage:[UIImage imageNamed:@"Barrier_topright"] scaledToSize:CGSizeMake(borderSize, borderSize)];
    UIImage *bottomRight = [self imageWithImage:[UIImage imageNamed:@"Barrier_bottomright"] scaledToSize:CGSizeMake(borderSize, borderSize)];
    
    UIImage *top = [self imageWithImage:[UIImage imageNamed:@"Barrier_top"] scaledToSize:CGSizeMake(initWidth, borderSize)];
    UIImage *bottom = [self imageWithImage:[UIImage imageNamed:@"Barrier_bottom"] scaledToSize:CGSizeMake(initWidth, borderSize)];
    UIImage *left = [self imageWithImage:[UIImage imageNamed:@"Barrier_left"] scaledToSize:CGSizeMake(borderSize, initHeight)];
    UIImage *right = [self imageWithImage:[UIImage imageNamed:@"Barrier_right"] scaledToSize:CGSizeMake(borderSize, initHeight)];
    
    UIImage *pattern = [UIImage imageNamed:@"Barrier_pattern"];
    CGFloat patternAspect = pattern.size.width / pattern.size.height;
    pattern = [self imageWithImage:pattern scaledToSize:CGSizeMake(patternAspect * initHeight - 2 * borderSize, initHeight - 2 * borderSize)];
    
    UIGraphicsBeginImageContext(CGSizeMake(initWidth, initHeight));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetPatternPhase(context, CGSizeMake(borderSize, borderSize));
    [pattern drawAsPatternInRect:CGRectMake(borderSize, borderSize, initWidth - 2 * borderSize, initHeight - 2 * borderSize)];
    
    [top drawAtPoint:CGPointMake(borderSize, 0)];
    [bottom drawAtPoint:CGPointMake(borderSize, initHeight - borderSize)];
    [left drawAtPoint:CGPointMake(0, borderSize)];
    [right drawAtPoint:CGPointMake(initWidth - borderSize, borderSize)];
    
    [topLeft drawAtPoint:CGPointMake(0, 0)];
    [bottomLeft drawAtPoint:CGPointMake(0, initHeight - borderSize)];
    [topRight drawAtPoint:CGPointMake(initWidth - borderSize, 0)];
    [bottomRight drawAtPoint:CGPointMake(initWidth - borderSize, initHeight - borderSize)];
    
    
    UIImage *retImage = [self imageWithImage:UIGraphicsGetImageFromCurrentImageContext() scaledToSize:size];
    UIGraphicsEndImageContext();
    
    
    SKSpriteNode *barrier = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:retImage]];
    barrier.texture.filteringMode = SKTextureFilteringNearest;
    [barrier setZPosition:3];
    
    return barrier;
}

- (void)update:(CGFloat)deltaTime {
    if (self.type == RBarrierTypeMoving) {
        CGFloat moveStep = deltaTime * self.movingSpeed;
        
        if (self.direction == RMovingBarrierDirectionRightToLeft && gapsStartPos + self.position.x - moveStep < 0) {
            [self setDirection:RMovingBarrierDirectionLeftToRight];
        } else if (self.direction == RMovingBarrierDirectionLeftToRight && gapsEndPos + self.position.x + moveStep > sceneWidth) {
            [self setDirection:RMovingBarrierDirectionRightToLeft];
        }
        
        [self setPosition:CGPointMake(self.position.x + moveStep * (self.direction == RMovingBarrierDirectionLeftToRight ? 1 : -1), self.position.y)];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage* aImage = UIGraphicsGetImageFromCurrentImageContext(  );
    return aImage;
}
@end
