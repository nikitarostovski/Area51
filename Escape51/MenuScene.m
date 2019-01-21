//
//  MenuScene.m
//  Escape51
//
//  Created by ROST on 14.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "MenuScene.h"
#import "SKPButton.h"
#import "RHero.h"
#import "SKLabelNodePlus.h"
#import "SKEase.h"
#import "PrefsNode.h"
#import "AppDelegate.h"

static const CGFloat kButtonSize = 0.2f;
static const CGFloat kButtonGap = 0.05f;
static const CGFloat kButtonCenterY = 0.6f;
static const CGFloat kLogoWidth = 0.85f;
static const CGFloat kScoreOffsetY = 50.0f;
static const CGFloat kTransitionTime = 0.7f;

@interface MenuScene ()  <PrefsNodeDelegate>
@end

@implementation MenuScene {
    PrefsNode *prefsNode;
    RHero *hero;
    CGPoint heroPosition;
    
    SKPButton *prevHeroBtn;
    SKPButton *nextHeroBtn;
    
    SKPButton *playBtn;
    SKPButton *prefsBtn;
    SKPButton *scoresBtn;
    SKPixelSpriteNode *logo;
    SKPixelSpriteNode *ground;
    SKPixelSpriteNode *buildings;
    
    SKLabelNodePlus *score;
    SKPButton *shareBtn;
    SKPButton *rateBtn;
}

- (void)didMoveToView:(SKView *)view {
    [self setupBackground];
    [self setupButtons];
    [self setupHero];
    [self setupLogo];
    [self setupScore];
    [self setupSocialButtons];
    [self showHud];
    
    prefsNode = [[PrefsNode alloc] initWithSize:self.size Delegate:self];
    [prefsNode setPosition:CGPointMake(self.size.width + prefsNode.size.width / 2, self.size.height / 2)];
    [self addChild:prefsNode];
    
    self.shouldEnableEffects = YES;
    SKShader* shader = [SKShader shaderWithFileNamed:@"MainShader.fsh"];
    shader.uniforms = @[
                        [SKUniform uniformWithName:@"size" floatVector2:GLKVector2Make(self.size.width, self.size.height)]
                        ];
    self.shader = shader;
}

- (void)playTap {
    if (self.menuDelegate) {
        id del = self.menuDelegate;
        if ([del respondsToSelector:@selector(showGame)]) {
            SKAction *heroAnimationAction = [SKEase MoveToWithNode:hero EaseFunction:CurveTypeQuadratic Mode:EaseInOut Time:kTransitionTime ToVector:CGVectorMake(self.heroStartPos.x, self.heroStartPos.y)];
            [hero runAction:heroAnimationAction completion:^{
                [del showGame];
            }];
            [self hideHud];
        }
    }
}

- (void)showHud {
    CGFloat hudTransitionTime = kTransitionTime * 0.2f;
    
    CGFloat playBtnX = playBtn.position.x;
    [playBtn setPosition:CGPointMake(self.size.width * 3 / 2 - (kButtonSize + kButtonGap) * self.size.width, scoresBtn.position.y)];
    [playBtn runAction:[SKEase MoveToWithNode:playBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(playBtnX, playBtn.position.y)]];
    
    CGFloat scoresBtnX = scoresBtn.position.x;
    [scoresBtn setPosition:CGPointMake(-self.size.width / 2, scoresBtn.position.y)];
    [scoresBtn runAction:[SKEase MoveToWithNode:scoresBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(scoresBtnX, scoresBtn.position.y)]];
    
    CGFloat prefsBtnX = prefsBtn.position.x;
    [prefsBtn setPosition:CGPointMake(self.size.width * 3 / 2, prefsBtn.position.y)];
    [prefsBtn runAction:[SKEase MoveToWithNode:prefsBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(prefsBtnX, prefsBtn.position.y)]];
    
    
    [buildings runAction:[SKEase MoveToWithNode:buildings EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(buildings.position.x, buildings.size.height / 2)]];
    [ground runAction:[SKEase MoveToWithNode:ground EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(ground.position.x, ground.size.height / 2)]];
    
    CGFloat logoPosX = logo.position.x;
    [logo setPosition:CGPointMake(-self.size.width / 2, logo.position.y)];
    [logo runAction:[SKEase MoveToWithNode:logo EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(logoPosX, logo.position.y)]];
    
    CGFloat scorePosX = score.position.x;
    [score setPosition:CGPointMake(self.size.width * 3 / 2, score.position.y)];
    [score runAction:[SKEase MoveToWithNode:score EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(scorePosX, score.position.y)]];
    
    CGFloat sharePosX = shareBtn.position.x;
    [shareBtn setPosition:CGPointMake(self.size.width * 3 / 2, shareBtn.position.y)];
    [shareBtn runAction:[SKEase MoveToWithNode:shareBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(sharePosX, shareBtn.position.y)]];
    
    CGFloat ratePosX = rateBtn.position.x;
    [rateBtn setPosition:CGPointMake(-self.size.width / 2, rateBtn.position.y)];
    [rateBtn runAction:[SKEase MoveToWithNode:rateBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(ratePosX, rateBtn.position.y)]];
}

- (void)hideHud {
    CGFloat hudTransitionTime = kTransitionTime * 0.2f;
    
    [playBtn runAction:[SKEase MoveToWithNode:playBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(self.size.width * 3 / 2 - (kButtonSize + kButtonGap) * self.size.width, playBtn.position.y)]];
    [scoresBtn runAction:[SKEase MoveToWithNode:scoresBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, scoresBtn.position.y)]];
    [prefsBtn runAction:[SKEase MoveToWithNode:prefsBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(self.size.width * 3 / 2, prefsBtn.position.y)]];
    [buildings runAction:[SKEase MoveToWithNode:buildings EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(buildings.position.x, -buildings.size.height / 2)]];
    [ground runAction:[SKEase MoveToWithNode:ground EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(ground.position.x, -ground.size.height / 2)]];
    [logo runAction:[SKEase MoveToWithNode:logo EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, logo.position.y)]];
    [score runAction:[SKEase MoveToWithNode:score EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(self.size.width * 3 / 2, score.position.y)]];
    [shareBtn runAction:[SKEase MoveToWithNode:shareBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(self.size.width * 3 / 2, shareBtn.position.y)]];
    [rateBtn runAction:[SKEase MoveToWithNode:rateBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, rateBtn.position.y)]];
    [prevHeroBtn runAction:[SKAction fadeAlphaTo:0.0 duration:hudTransitionTime]];
    [nextHeroBtn runAction:[SKAction fadeAlphaTo:0.0 duration:hudTransitionTime]];
}

- (void)prefsClose {
    CGFloat hudTransitionTime = kTransitionTime * 0.2f;
    [prefsNode runAction:[SKAction moveToX:self.size.width + prefsNode.size.width / 2 duration:hudTransitionTime]];
    
    [playBtn runAction:[SKEase MoveToWithNode:playBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(playBtn.initPos.x, playBtn.initPos.y)]];
    [scoresBtn runAction:[SKEase MoveToWithNode:scoresBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(scoresBtn.initPos.x, scoresBtn.initPos.y)]];
    [prefsBtn runAction:[SKEase MoveToWithNode:prefsBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(prefsBtn.initPos.x, prefsBtn.initPos.y)]];
    [buildings runAction:[SKEase MoveToWithNode:buildings EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(buildings.initPos.x, buildings.initPos.y)]];
    [score runAction:[SKEase MoveToWithNode:score EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(score.initPos.x, score.initPos.y)]];
    [shareBtn runAction:[SKEase MoveToWithNode:shareBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(shareBtn.initPos.x, shareBtn.initPos.y)]];
    [rateBtn runAction:[SKEase MoveToWithNode:rateBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(rateBtn.initPos.x, rateBtn.initPos.y)]];
    
    [hero runAction:[SKAction fadeAlphaTo:1.0 duration:hudTransitionTime]];
    [prevHeroBtn runAction:[SKAction fadeAlphaTo:1.0 duration:hudTransitionTime]];
    [nextHeroBtn runAction:[SKAction fadeAlphaTo:1.0 duration:hudTransitionTime]];
}

- (void)prefsTap {
    CGFloat hudTransitionTime = kTransitionTime * 0.2f;
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:hudTransitionTime], [SKAction runBlock:^{
        
    }]]]];
    [playBtn runAction:[SKEase MoveToWithNode:playBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, playBtn.position.y)]];
    [scoresBtn runAction:[SKEase MoveToWithNode:scoresBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, scoresBtn.position.y)]];
    [prefsBtn runAction:[SKEase MoveToWithNode:prefsBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, prefsBtn.position.y)]];
    [buildings runAction:[SKEase MoveToWithNode:buildings EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(buildings.position.x, -buildings.size.height / 2)]];
    [score runAction:[SKEase MoveToWithNode:score EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, score.position.y)]];
    [shareBtn runAction:[SKEase MoveToWithNode:shareBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, shareBtn.position.y)]];
    [rateBtn runAction:[SKEase MoveToWithNode:rateBtn EaseFunction:CurveTypeQuadratic Mode:EaseIn Time:hudTransitionTime ToVector:CGVectorMake(-self.size.width / 2, rateBtn.position.y)]];
    
    [hero runAction:[SKAction fadeAlphaTo:0.0 duration:hudTransitionTime]];
    [prefsNode runAction:[SKAction moveToX:self.size.width / 2 duration:hudTransitionTime]];
    [prevHeroBtn runAction:[SKAction fadeAlphaTo:0.0 duration:hudTransitionTime]];
    [nextHeroBtn runAction:[SKAction fadeAlphaTo:0.0 duration:hudTransitionTime]];
}


- (void)scoresTap {
    if (self.menuDelegate) {
        id del = self.menuDelegate;
        if ([del respondsToSelector:@selector(showScores)]) {
            [del showScores];
        }
    }
}

- (SKPButton *)createButtonWithFile:(NSString *)file Size:(CGSize)size Pos:(CGPoint)pos {
    SKPButton *btn = [[SKPButton alloc] initWithDefaultImage:file SelectedImage:file DisabledImage:file];
    [btn setSize:size];
    [btn setPosition:pos];
    [btn setInitPos:btn.position];
    [btn setZPosition:100];
    return btn;
}

- (void)setupButtons {
    CGFloat buttonSize = self.size.width * kButtonSize;
    CGFloat buttonGap = self.size.width * kButtonGap;
    CGPoint centerPos = CGPointMake(self.size.width / 2, self.size.height * kButtonCenterY);
    
    playBtn = [self createButtonWithFile:@"Btn_play" Size:CGSizeMake(buttonSize, buttonSize) Pos:centerPos];
    [playBtn addTarget:self action:@selector(playTap)];
    [self addChild:playBtn];
    
    prefsBtn = [self createButtonWithFile:@"Btn_prefs" Size:CGSizeMake(buttonSize, buttonSize) Pos:CGPointMake(centerPos.x + buttonSize + buttonGap, centerPos.y)];
    [prefsBtn addTarget:self action:@selector(prefsTap)];
    [self addChild:prefsBtn];
    
    scoresBtn = [self createButtonWithFile:@"Btn_scores" Size:CGSizeMake(buttonSize, buttonSize) Pos:CGPointMake(centerPos.x - buttonSize - buttonGap, centerPos.y)];
    [scoresBtn addTarget:self action:@selector(scoresTap)];
    [self addChild:scoresBtn];
}

- (void)setupBackground {
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Prefs" ofType: @"plist"];
    NSArray *backPrefs = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"Background"];
    SKPixelSpriteNode *back = [[SKPixelSpriteNode alloc] initWithImageNamed:backPrefs[0][@"image"]];
    [back setZPosition:0];
    [back setSize:self.size];
    [back setPosition:CGPointMake(self.size.width / 2, back.size.height / 2)];
    [self addChild:back];
    
    buildings = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Foreground_menu"];
    [buildings setZPosition:10];
    CGFloat bScale = buildings.size.width / self.size.width;
    [buildings setSize:CGSizeMake(self.size.width, buildings.size.height / bScale)];
    [buildings setPosition:CGPointMake(self.size.width / 2, -buildings.size.height / 2)];
    [self addChild:buildings];
    
    ground = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Ground"];
    [ground setZPosition:99];
    CGFloat gScale = ground.size.width / self.size.width;
    [ground setSize:CGSizeMake(self.size.width, ground.size.height / gScale)];
    [ground setPosition:CGPointMake(self.size.width / 2, -buildings.size.height / 2)];
    [self addChild:ground];
    
    [buildings setInitPos:CGPointMake(buildings.position.x, buildings.size.height / 2)];
    [ground setInitPos:CGPointMake(ground.position.x, ground.size.height / 2)];
    
    heroPosition = CGPointMake(self.size.width / 2, ground.size.height);
}

- (void)setupHero {
    hero = [[RHero alloc] initWithPosition:CGPointZero Width:self.heroStartWidth];
    [hero setZPosition:100];
    [hero setPosition:CGPointMake(heroPosition.x, heroPosition.y + hero.size.height / 2)];
    [hero setAlpha:0];
    [self addChild:hero];
    
    [hero runAction:[SKAction fadeAlphaTo:1.0 duration:kTransitionTime]];
    
    CGFloat arrowHeight = hero.size.height * 1.5;
    
    prevHeroBtn = [[SKPButton alloc] initWithDefaultImage:@"Arrow_left" SelectedImage:@"Arrow_left" DisabledImage:@"Arrow_left"];
    [prevHeroBtn setSize:CGSizeMake(arrowHeight * prevHeroBtn.size.width / prevHeroBtn.size.height, arrowHeight)];
    [prevHeroBtn setZPosition:100];
    [prevHeroBtn setPosition:CGPointMake(hero.position.x - prevHeroBtn.size.width / 2 - hero.size.width / 2, hero.position.y)];
    [prevHeroBtn addTarget:self action:@selector(prevHeroTap)];
    [prevHeroBtn setAlpha:0];
    [self addChild:prevHeroBtn];
    [prevHeroBtn runAction:[SKAction fadeAlphaTo:1.0 duration:kTransitionTime]];
    
    nextHeroBtn = [[SKPButton alloc] initWithDefaultImage:@"Arrow_right" SelectedImage:@"Arrow_right" DisabledImage:@"Arrow_right"];
    [nextHeroBtn setSize:prevHeroBtn.size];
    [nextHeroBtn setZPosition:100];
    [nextHeroBtn setPosition:CGPointMake(hero.position.x + nextHeroBtn.size.width / 2 + hero.size.width / 2, hero.position.y)];
    [nextHeroBtn addTarget:self action:@selector(nextHeroTap)];
    [nextHeroBtn setAlpha:0];
    [self addChild:nextHeroBtn];
    [nextHeroBtn runAction:[SKAction fadeAlphaTo:1.0 duration:kTransitionTime]];
    
    if ([hero availableSkinsCount] < 2) {
        [nextHeroBtn setHidden:YES];
        [prevHeroBtn setHidden:YES];
    }
}

- (void)setupLogo {
    logo = [[SKPixelSpriteNode alloc] initWithImageNamed:@"Logo"];
    [logo setZPosition:99];
    CGFloat lWidth = self.size.width * kLogoWidth;
    CGFloat lScale = logo.size.width / lWidth;
    [logo setSize:CGSizeMake(lWidth, logo.size.height / lScale)];
    [logo setPosition:CGPointMake(self.size.width / 2, self.size.height * kButtonCenterY + (self.size.height * (1 - kButtonCenterY)) / 2)];
    [self addChild:logo];
}

- (void)setupScore {
    NSShadow *myShadow = [NSShadow new];
    [myShadow setShadowColor:[UIColor blackColor]];
    [myShadow setShadowBlurRadius:0];
    [myShadow setShadowOffset:CGSizeMake(2, 2)];
    
    score = [SKLabelNodePlus labelNodeWithText:[NSString stringWithFormat:@"BEST: %llu", self.maxScore]];
    [score setFontColor:[SKColor whiteColor]];
    score.fontName = @"Pixel Emulator";
    score.fontSize = 32;
    [score setZPosition:99];
    score.position = CGPointMake(self.size.width / 2, self.size.height * kButtonCenterY - kScoreOffsetY - (kButtonSize / 2 * self.size.width) - score.frame.size.height / 2);
    [score setInitPos:score.position];
    score.shadow = myShadow;
    [score drawLabel];
    [self addChild:score];
}

- (void)setupSocialButtons {
    shareBtn = [[SKPButton alloc] initWithDefaultImage:@"Btn_share" SelectedImage:@"Btn_share" DisabledImage:@"Btn_share"];
    [shareBtn setSize:CGSizeMake(shareBtn.size.width / shareBtn.size.height * score.frame.size.height, score.frame.size.height)];
    
    CGSize btnSize = shareBtn.size;
    CGFloat gapX = btnSize.width * 0.15f;
    
    [shareBtn setPosition:CGPointMake(self.size.width / 2 + btnSize.width / 2 + gapX, score.position.y - score.frame.size.height / 2 - shareBtn.size.height * 0.7)];
    [shareBtn setInitPos:shareBtn.position];
    [shareBtn addTarget:self action:@selector(shareTap)];
    [shareBtn setZPosition:100];
    [self addChild:shareBtn];
    
    
    rateBtn = [[SKPButton alloc] initWithDefaultImage:@"Btn_rate" SelectedImage:@"Btn_rate" DisabledImage:@"Btn_rate"];
    [rateBtn setSize:btnSize];
    [rateBtn setPosition:CGPointMake(self.size.width / 2 - btnSize.width / 2 - gapX, score.position.y - score.frame.size.height / 2 - shareBtn.size.height * 0.7)];
    [rateBtn setInitPos:rateBtn.position];
    [rateBtn addTarget:self action:@selector(rateTap)];
    [rateBtn setZPosition:100];
    [self addChild:rateBtn];
}

- (void)shareTap {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate share];
}

- (void)rateTap {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[kAppstoreLink copy]]];
}

- (void)prevHeroTap {
    [hero prevSkin];
}

- (void)nextHeroTap {
    [hero nextSkin];
}

@end
