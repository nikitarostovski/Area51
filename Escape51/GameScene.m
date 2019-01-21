//
//  GameScene.m
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright (c) 2016 ROST. All rights reserved.
//

#import "GameScene.h"
#import "BarrierManager.h"
#import "BonusManager.h"
#import "BackgroundManager.h"
#import "RHero.h"
#import "SKLabelNodePlus.h"
#import "PauseNode.h"
#import "SKEase.h"

static const int kHeroStep = 1;
static const CGFloat kScoreLabelPosition = 50.0f;
static const CGFloat kTransitionTime = 0.5f;
static const CGFloat kSpeedMin = 1.0;
static const CGFloat kSpeedMax = 1.35;
static const CGFloat kSpeedMaxScore = 175;

@interface GameScene ()

@property (nonatomic) SKLabelNodePlus *scoreLabel;
@property (nonatomic) NSMutableArray *livesSprites;

@end

@implementation GameScene {
    PauseNode *pauseNode;
    SKSpriteNode *fadeNode;
    
    NSTimeInterval lastUpdateTimeInterval;
    CGPoint touchStartPos;
    CGPoint heroStartPos;
    
    long long maxScore;
    long long lastPlaneShowScore;
    
    bool touchEnabled;
    bool isPause;
}
@synthesize curScore;

- (void)didMoveToView:(SKView *)view {
    self.shouldEnableEffects = YES;
    _backManager = [[BackgroundManager alloc] initWithScene:self];
    _barrierManager = [[BarrierManager alloc] initWithScene:self];
    _bonusManager = [[BonusManager alloc] initWithScene:self];
    
    _additionalSpeedMult = 1.0f;
    curScore = 0;
    _livesCount = 0;
    
    _hero = [[RHero alloc] initWithPosition:self.heroStartPoint Width:self.heroWidth];
    [self addChild:_hero];
    
    pauseNode = [[PauseNode alloc] initWithSize:self.size];
    [pauseNode setPosition:CGPointMake(self.size.width / 2, self.size.height / 2)];
    [self addChild:pauseNode];
    
    
    
    fadeNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.size];
    [fadeNode setPosition:CGPointMake(self.size.width / 2, self.size.height / 2)];
    [fadeNode setAlpha:0];
    [fadeNode setZPosition:2.1];
    [self addChild:fadeNode];
    [fadeNode runAction:[SKAction fadeAlphaTo:0.1f duration:kTransitionTime]];
    
    
    [self createScoreLabel];
    [self createLivesSprites];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    maxScore = [[defs valueForKey:@"score"] longLongValue];
    
    SKShader *shader = [SKShader shaderWithFileNamed:@"MainShader.fsh"];
    shader.uniforms = @[
                        [SKUniform uniformWithName:@"size" floatVector2:GLKVector2Make(self.size.width, self.size.height)]
                        ];
    self.shader = shader;
    touchEnabled = YES;
    [self pause];
}

- (void)createLivesSprites {
    CGFloat height = 35.0f;
    self.livesSprites = [NSMutableArray array];
    for (int i = 0; i < kBonusLivesMax; i++) {
        SKPixelSpriteNode *life = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Life"];
        [life setHidden:YES];
        [life setZPosition:99];
        [life setSize:CGSizeMake(height, height)];
        [life setPosition:CGPointMake(self.size.width - kScoreLabelPosition - height * i, self.size.height - kScoreLabelPosition)];
        [self addChild:life];
        [self.livesSprites addObject:life];
    }
}

- (void)createScoreLabel {
    NSShadow *myShadow = [NSShadow new];
    [myShadow setShadowColor:[UIColor blackColor]];
    [myShadow setShadowBlurRadius:0];
    [myShadow setShadowOffset:CGSizeMake(2, 2)];
    
    self.scoreLabel = [SKLabelNodePlus labelNodeWithText:@"0"];
    [self.scoreLabel setFontColor:[SKColor whiteColor]];
    self.scoreLabel.position = CGPointMake(kScoreLabelPosition, self.size.height - kScoreLabelPosition);
    self.scoreLabel.fontName = @"Pixel Emulator";
    self.scoreLabel.fontSize = 35;
    [self.scoreLabel setZPosition:99];
    self.scoreLabel.shadow = myShadow;
    [self.scoreLabel drawLabel];
    [self addChild:self.scoreLabel];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!touchEnabled)
        return;
    [self play];
    
    CGPoint touchPos = [[touches anyObject] locationInNode:self];
    touchStartPos = touchPos;
    heroStartPos = _hero.position;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!touchEnabled)
        return;
    if (isPause)
        return;
    
    CGPoint touchPos = [[touches anyObject] locationInNode:self];
    [self updateHeroPosition:touchPos];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!touchEnabled)
        return;
    [self pause];
}


- (void)updateHeroPosition:(CGPoint)touchPos {
    CGFloat newHeroPosX = heroStartPos.x + (touchPos.x - touchStartPos.x) * self.heroMoveSpeed;
    
    if (newHeroPosX < _hero.size.width / 2) {
        newHeroPosX = _hero.size.width / 2;
    } else if (newHeroPosX > self.size.width - _hero.size.width / 2) {
        newHeroPosX = self.size.width - _hero.size.width / 2;
    }
    newHeroPosX = (int)(newHeroPosX / kHeroStep) * kHeroStep;
    
    [_hero setPosition:CGPointMake(newHeroPosX, _hero.position.y)];
}

#pragma mark - Time events

- (void)update:(CFTimeInterval)currentTime {
    if (isPause) {
        lastUpdateTimeInterval = currentTime;
        return;
    }
    
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        lastUpdateTimeInterval = currentTime;
    }
    
    curScore = [_barrierManager barriersPassed:_hero.position.y];
    CGFloat speedMult = [self speedMultForScore:curScore];
    
    [_barrierManager setBarrierSpeedMultiplier:speedMult];
    [_bonusManager setBonusSpeedMultiplier:speedMult];
    
    [_backManager update:timeSinceLast];
    [_barrierManager update:timeSinceLast];
    [_bonusManager update:timeSinceLast];
    
    
    [self.scoreLabel setText:[NSString stringWithFormat:@"%llu", curScore]];
    [self.scoreLabel drawLabel];
    
    [self updateLivesIndicator];
    if (curScore > 0 && curScore % 25 == 0 && curScore != lastPlaneShowScore) {
        lastPlaneShowScore = curScore;
        [_backManager launchPlane];
    }
    
        
    if ([_hero canCollide] && [_barrierManager collisionCheckForNode:_hero]) {
        [self collisionOccured];
    } else {
        if ([_bonusManager bonusCheckForNode:_hero]) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate bonusPlay];
        }
    }
}

- (void)updateLivesIndicator {
    for (int i = 0; i < [self.livesSprites count]; i++) {
        SKPixelSpriteNode *life = [self.livesSprites objectAtIndex:i];
        if (i < _livesCount) {
            [life setHidden:NO];
        } else {
            [life setHidden:YES];
        }
    }
}

#pragma mark - Game handling

- (void)pause {
    isPause = YES;
    [pauseNode show];
}

- (void)play {
    [pauseNode hide];
    isPause = NO;
}

- (CGFloat)speedMultForScore:(long long)score {
    return _additionalSpeedMult * MIN(kSpeedMin + (kSpeedMax - kSpeedMin) * ((float)score / (float)kSpeedMaxScore), kSpeedMax);
}

- (void)collisionOccured {
    if (_livesCount > 0) {
        _livesCount--;
        [_hero flash];
        return;
    }
    
    if (curScore >= maxScore) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeScreenshot];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate crashPlay];
    
    isPause = YES;
    touchEnabled = NO;
    [pauseNode hide];
    [_hero explode];
    [fadeNode runAction:[SKAction fadeOutWithDuration:kTransitionTime]];
    [_backManager scrollToBottomWithAnimationTime:kTransitionTime];
    [_barrierManager clearBarriersWithAnimtaionTime:kTransitionTime];
    [self runAction:[SKAction waitForDuration:kTransitionTime] completion:^{
        [self loadMenu];
    }];
}

- (void)loadMenu {
    if (self.gameDelegate) {
        id del = self.gameDelegate;
        if ([del respondsToSelector:@selector(gameIsOverWithScore:)]) {
            [del performSelector:@selector(gameIsOverWithScore:) withObject:@(curScore)];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate askRate];

        }
    }
}

@end
