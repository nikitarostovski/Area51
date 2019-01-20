//
//  Hero.m
//  Escape51
//
//  Created by ROST on 10.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "RHero.h"

static const CGFloat kAnimationSecondsPerFrame = 0.1f;
static const CGFloat kFlashDuration = 1.0f;
static const CGFloat kFlashAlpha = 0.5f;
static const int kFlashCount = 16;

@interface HeroSkin : NSObject
@property NSString *skinName;
@property int skinChance;
@end
@implementation HeroSkin
@end


@implementation RHero {
    NSMutableArray *skinsAvailable;
    NSMutableArray *skinsAll;
    int skinCur;
    
    CGSize initSize;
    CGFloat flashTimeSpent;
    
    SKPixelSpriteNode *immortalSprite;
    
    CGFloat wdt;
}

- (id)initWithPosition:(CGPoint)pos Width:(CGFloat)width {
    self = [super init];
    if (self) {
        wdt = width;
        [self loadHeroSkins];
        
        [self setPosition:pos];
        [self setZPosition:4];
    }
    return self;
}

- (void)setHeroSprite:(NSString *)name {
    [self setTexture:[SKTexture textureWithImageNamed:name]];
    
    CGFloat aspect = self.texture.size.width / self.texture.size.height;
    [self setSize:CGSizeMake(wdt, wdt / aspect)];
    initSize = self.size;
    
    
    BOOL immortalHidden = immortalSprite ? immortalSprite.hidden : YES;
    [immortalSprite removeFromParent];
    immortalSprite = [[SKPixelSpriteNode alloc] initWithImageNamed:@"God"];
    [immortalSprite setHidden:immortalHidden];
    [self updateImmortalSpriteFrame];
    [self addChild:immortalSprite];
}

- (int)availableSkinsCount {
    return (int)[skinsAvailable count];
}

- (int)totalSkinsCount {
    return (int)[skinsAll count];
}

- (void)nextSkin {
    if (skinCur + 1 < [skinsAvailable count]) {
        skinCur++;
    } else {
        skinCur = 0;
    }
    HeroSkin *cur = [skinsAvailable objectAtIndex:skinCur];
    [self setHeroSprite:cur.skinName];
    [self saveSkins];
}

- (void)prevSkin {
    if (skinCur - 1 >= 0) {
        skinCur--;
    } else {
        skinCur = (int)[skinsAvailable count] - 1;
    }
    HeroSkin *cur = [skinsAvailable objectAtIndex:skinCur];
    [self setHeroSprite:cur.skinName];
    [self saveSkins];
}

- (void)loadHeroSkins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Prefs" ofType: @"plist"];
    NSArray *heroPrefs = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"Hero"];
    skinCur = [[defaults valueForKey:@"Hero"] intValue];
    
    skinsAll = [NSMutableArray array];
    for (NSDictionary *heroPref in heroPrefs) {
        HeroSkin *skin = [[HeroSkin alloc] init];
        skin.skinName = [heroPref valueForKey:@"name"];
        skin.skinChance = [[heroPref valueForKey:@"chance"] intValue];
        
        [skinsAll addObject:skin];
    }
    
    skinsAvailable = [NSMutableArray array];
    NSMutableArray *availableHeroes = [defaults valueForKey:@"availableHeroes"];
    for (NSString *name in availableHeroes) {
        for (HeroSkin *skin in skinsAll) {
            if ([name isEqualToString:skin.skinName]) {
                [skinsAvailable addObject:skin];
            }
        }
    }
    if (![skinsAvailable count]) {
        [self unlockRandomHero];
    }
    
    HeroSkin *cur = [skinsAvailable objectAtIndex:skinCur];
    [self setHeroSprite:cur.skinName];
}

- (void)unlockRandomHero {
    HeroSkin *newHero;
    int chanceTotal = 0;
    
    NSMutableArray *candidates = [NSMutableArray array];
    
    for (HeroSkin *skin in skinsAll) {
        if ([skinsAvailable indexOfObject:skin] != NSNotFound)
            continue;
        
        chanceTotal += skin.skinChance;
        [candidates addObject:skin];
    }
    if (![candidates count]) {
        NSLog(@"No skins available");
        return;
    }
    
    if (chanceTotal == 0) {
        return;
    }
    
    int chanceResult = arc4random() % chanceTotal;
    chanceTotal = 0;
    
    for (int i = 0; i < [candidates count]; i++) {
        HeroSkin *curHero = candidates[i];
        
        if (chanceTotal <= chanceResult && chanceResult < chanceTotal + curHero.skinChance) {
            newHero = curHero;
            [skinsAvailable addObject:curHero];
            break;
        }
        chanceTotal += curHero.skinChance;
    }
    NSLog(@"Setting skin: %@", newHero.skinName);
    skinCur = (int)[skinsAvailable indexOfObject:newHero];
    [self setHeroSprite:newHero.skinName];
    [self saveSkins];
}

- (void)saveSkins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *toWrite = [NSMutableArray array];
    for (HeroSkin *skin in skinsAvailable) {
        [toWrite addObject:skin.skinName];
    }
    [defaults setValue:toWrite forKey:@"availableHeroes"];
    [defaults setValue:@(skinCur) forKey:@"Hero"];
    [defaults synchronize];
}

- (bool)canCollide {
    return !_immortal && !_godMode;
}

- (void)setImmortal:(bool)immortal {
    if (immortal) {
        [immortalSprite removeAllActions];
        [immortalSprite setAlpha:1.0];
        _immortal = immortal;
        [immortalSprite setHidden:NO];
    } else {
        [immortalSprite runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.25 duration:0], [SKAction waitForDuration:1.0]]] completion:^{
            _immortal = immortal;
            [immortalSprite setHidden:YES];
        }];
    }
}

- (void)flash {
    flashTimeSpent = 0;
    _godMode = YES;
    NSTimer *flashTimer = [NSTimer timerWithTimeInterval:(kFlashDuration / kFlashCount) target:self selector:@selector(flashFire:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:flashTimer forMode:NSDefaultRunLoopMode];
}

- (void)flashFire:(NSTimer *)sender {
    flashTimeSpent += sender.timeInterval;
    if (self.alpha == kFlashAlpha) {
        self.alpha = 1.0;
    } else {
        self.alpha = kFlashAlpha;
    }
    if (flashTimeSpent >= kFlashDuration) {
        self.alpha = 1.0;
        _godMode = NO;
        [sender invalidate];
    }
}

- (void)explode {
    NSArray *keyFrames = @[[self textureFromString:@"Explosion_1"],
                           [self textureFromString:@"Explosion_2"],
                           [self textureFromString:@"Explosion_3"],
                           [self textureFromString:@"Explosion_4"]];
    
    [self setSize:CGSizeMake(self.size.width, self.size.width)];
    
    SKAction *explode = [SKAction animateWithTextures:keyFrames timePerFrame:kAnimationSecondsPerFrame];
    SKAction *wait = [SKAction waitForDuration:kAnimationSecondsPerFrame * 2];
    SKAction *hide = [SKAction fadeOutWithDuration:0];
    [self runAction:[SKAction sequence:@[explode, hide, wait]]];
}

- (SKTexture *)textureFromString:(NSString *)s {
    SKTexture *t = [SKTexture textureWithImageNamed:s];
    t.filteringMode = SKTextureFilteringNearest;
    return t;
}

- (void)setSizeMultiplier:(CGFloat)sizeMultiplier {
    [self setSize:CGSizeMake(initSize.width * sizeMultiplier, initSize.height * sizeMultiplier)];
    [self updateImmortalSpriteFrame];
}

- (void)updateImmortalSpriteFrame {
    CGFloat immortalSize = 1.5 * MAX(self.size.width, self.size.height);
    [immortalSprite setSize:CGSizeMake(immortalSize, immortalSize)];
}

@end
