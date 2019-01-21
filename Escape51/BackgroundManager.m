//
//  Background.m
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "BackgroundManager.h"
#import "GameScene.h"
#import "SKPixelSpriteNode.h"
#import "FrontSpriteData.h"
#import "FrontSpriteManager.h"

@interface BackSpriteData : NSObject

@property NSString *fileName;
@property long long score;
@property bool canBeSkipped;
@property bool disposable;

@end
@implementation BackSpriteData
@end

@interface FrontSpriteNode : SKPixelSpriteNode

@property CGFloat windSpeed;

@end
@implementation FrontSpriteNode
@end


static const CGFloat kBackDefaultSpeed = 200.0f;
static const CGFloat kForeDefaultSpeed = 250.0f;
static const CGFloat kPlaneSpeed = 200.0f;

@implementation BackgroundManager {
    NSMutableArray *backSprites;
    NSMutableArray *frontSprites;
    
    NSArray *backSpritesData;
    NSArray *frontSpritesManagers;
    
    CGFloat backSpeed;
    CGFloat foreSpeed;
    int backImageCounter;
    
    CGFloat windMultiplier;
    
    SKPixelSpriteNode *plane;
}

- (id)initWithScene:(SKScene *)scene {
    self = [super init];
    if (self) {
        self.scene = scene;
        backSpeed = kBackDefaultSpeed;
        foreSpeed = kForeDefaultSpeed;
        backSpritesData = [self loadBackgroundData];
        frontSpritesManagers = [self loadForegroundData];
        [self initBackground];
        [self initForeground];
    }
    return self;
}

- (void)initBackground {
    backSprites = [NSMutableArray array];
    [self addBackSprite];
    [self addBackSprite];
    
    CGFloat planeWidthCoeff = 0.3f;
    
    plane = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Plane"];
    [plane setSize:CGSizeMake(_scene.size.width * planeWidthCoeff, _scene.size.width * planeWidthCoeff * plane.size.height / plane.size.width)];
    [plane setZPosition:2.5f];
    [plane setHidden:YES];
    [_scene addChild:plane];
}

- (void)initForeground {
    frontSprites = [NSMutableArray array];
    [self addFrontSprite];
}

- (void)addBackSprite {
    SKSpriteNode *lastSprite = [backSprites lastObject];
    CGFloat lastPositionY = [backSprites count] ? lastSprite.position.y : 0;
    
    SKPixelSpriteNode *back = [SKPixelSpriteNode spriteNodeWithImageNamed:[self nextBackSprite]];
    [back setZPosition:1];
    [self.scene addChild:back];
    [backSprites addObject:back];
    
    CGFloat aspect = back.size.width / back.size.height;
    CGFloat backHeight = self.scene.size.width / aspect;
    
    [back setSize:CGSizeMake(self.scene.size.width, backHeight)];
    [back setPosition:CGPointMake(back.size.width / 2, lastPositionY + backHeight / 2 + lastSprite.size.height / 2)];
}

- (void)addFrontSprite {
    FrontSpriteData *frontData = [self nextFrontSprite];
    if (!frontData)
        return;
    
    FrontSpriteNode *front = [FrontSpriteNode spriteNodeWithImageNamed:frontData.fileName];
    [front setZPosition:2];
    [front setWindSpeed:frontData.windSpeed];
    [self.scene addChild:front];
    [frontSprites addObject:front];
    
    CGFloat frontWidth = self.scene.size.width * 0.15;
    CGFloat aspect = front.size.height / front.size.width;
    CGFloat frontHeight = frontWidth * aspect;
    
    CGFloat posX = arc4random() % (int)(_scene.size.width - frontWidth) + frontWidth / 2;
    
    [front setSize:CGSizeMake(frontWidth, frontHeight)];
    [front setPosition:CGPointMake(posX, _scene.frame.size.height + front.size.height / 2)];
}

- (NSArray *)loadForegroundData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Prefs" ofType: @"plist"];
    NSArray *backPrefs = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"Foreground"];
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSArray *arr in backPrefs) {
        [result addObject:[[FrontSpriteManager alloc] initWithArray:arr]];
    }
    
    return [result copy];
}

- (NSArray *)loadBackgroundData {
    backImageCounter = 0;
    NSMutableArray *result = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Prefs" ofType: @"plist"];
    NSArray *backPrefs = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"Background"];
    
    for (NSDictionary *imgData in backPrefs) {
        BackSpriteData *img = [[BackSpriteData alloc] init];
        [img setFileName:[imgData valueForKey:@"image"]];
        [img setCanBeSkipped:NO];
        [img setScore:[imgData[@"score"] longLongValue]];
        [img setDisposable:[imgData[@"disposable"] boolValue]];
        [result addObject:img];
    }
    
    return [result copy];
}

- (FrontSpriteData *)nextFrontSprite {
    FrontSpriteData *result;
    
    NSMutableArray *available = [NSMutableArray array];
    for (FrontSpriteManager *man in frontSpritesManagers) {
        FrontSpriteData *dat = [man randomSprite];
        if (dat) {
            [available addObject: dat];
        }
    }
    
    if ([available count]) {
        FrontSpriteData *sd = available[arc4random() % [available count]];
        result = sd;
    }
    
    return result;
}

- (NSString *)nextBackSprite {
    long long score = ((GameScene *)_scene).curScore;
    NSString *result;
    
    BackSpriteData *curSpriteData = [backSpritesData objectAtIndex:backImageCounter];
    if (!curSpriteData.disposable) {
        if (score >= curSpriteData.score) {
            if (backImageCounter + 2 < [backSpritesData count]) {
                BackSpriteData *nextSpriteData = [backSpritesData objectAtIndex:backImageCounter + 1];
                BackSpriteData *nextNextSpriteData = [backSpritesData objectAtIndex:backImageCounter + 2];
                if (!nextSpriteData.disposable || (nextSpriteData.disposable && score >= nextNextSpriteData.score)) {
                    curSpriteData.canBeSkipped = YES;
                }
            }
        }
    } else {
        [curSpriteData setCanBeSkipped:YES];
    }
    result = ((BackSpriteData *)[backSpritesData objectAtIndex:backImageCounter]).fileName;
    
    if (curSpriteData.canBeSkipped && backImageCounter + 1 < [backSpritesData count]) {
        backImageCounter++;
    }
    
    return result;
}

- (void)update:(CFTimeInterval)deltaTime {
    SKSpriteNode *topSprite = [backSprites lastObject];
    if (topSprite.position.y < topSprite.size.height / 2 + self.scene.size.height / 2) {
        [self addBackSprite];
    }
    
    //if ([frontSprites count] == 0) {
    SKSpriteNode *topFront = [frontSprites lastObject];
    if (topFront.position.y < _scene.size.height - topFront.size.height) {
        CGFloat windDelta = 0.1f * (float)(arc4random() % 2 ? 1 : -1);
        if (ABS(windMultiplier + windDelta) <= 1) {
            windMultiplier += windDelta;
        } else {
            windMultiplier -= windDelta;
        }
        [self addFrontSprite];
    }
    
    if (!plane.hidden) {
        [plane setPosition:CGPointMake(plane.position.x - kPlaneSpeed * deltaTime, plane.position.y - kBackDefaultSpeed * deltaTime)];
    }
    if (plane.position.x < 0 - plane.size.width / 2) {
        [plane setHidden:YES];
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (int i = 0; i < [backSprites count]; i++) {
        SKSpriteNode *curSprite = backSprites[i];
        if (i == 0) {
            CGFloat moveDelta = backSpeed * deltaTime;
            [curSprite setPosition:CGPointMake(curSprite.position.x, curSprite.position.y - moveDelta)];
            continue;
        }
        
        SKSpriteNode *nextSprite = backSprites[i - 1];
        [curSprite setPosition:CGPointMake(curSprite.position.x, nextSprite.position.y + nextSprite.size.height / 2 + curSprite.size.height / 2)];
        
        if (curSprite.position.y < 0 - curSprite.size.height / 2) {
            [toRemove addObject:curSprite];
            [curSprite removeFromParent];
        }
    }
    //[backSprites removeObjectsInArray:toRemove];
    
    toRemove = [NSMutableArray array];
    for (int i = 0; i < [frontSprites count]; i++) {
        FrontSpriteNode *curSprite = frontSprites[i];
        CGFloat moveDelta = foreSpeed * deltaTime;
        CGFloat windDelta = windMultiplier * curSprite.windSpeed * deltaTime;
        [curSprite setPosition:CGPointMake(curSprite.position.x - windDelta, curSprite.position.y - moveDelta)];
        if (curSprite.position.y < 0 - curSprite.size.height / 2) {
            [toRemove addObject:curSprite];
            [curSprite removeFromParent];
        }
    }
    [frontSprites removeObjectsInArray:toRemove];
}

- (void)scrollToBottomWithAnimationTime:(CGFloat)time {
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Prefs" ofType: @"plist"];
    NSArray *backPrefs = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"Background"];
    
    SKSpriteNode *back = [SKSpriteNode spriteNodeWithImageNamed:backPrefs[0][@"image"]];
    back.texture.filteringMode = SKTextureFilteringNearest;
    [back setZPosition:0];
    [self.scene addChild:back];
    
    CGFloat aspect = back.size.width / back.size.height;
    CGFloat backHeight = self.scene.size.width / aspect;
    
    [back setSize:CGSizeMake(self.scene.size.width, backHeight)];
    [back setPosition:CGPointMake(back.size.width / 2, self.scene.size.height / 2)];
    
    for (SKNode *n in backSprites) {
        [n runAction:[SKAction fadeOutWithDuration:time]];
    }
}

- (void)launchPlane {
    [plane setPosition:CGPointMake(_scene.size.width + plane.size.width / 2, _scene.size.height)];
    [plane setHidden:NO];
}

@end
