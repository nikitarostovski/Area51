//
//  PrefsNode.m
//  Escape51
//
//  Created by ROST on 16.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "PrefsNode.h"
#import "SKPButton.h"
#import "SKPSettingsButton.h"
#import "AppDelegate.h"

static const CGFloat kButtonSize = 0.15f;

@implementation PrefsNode {
    SKPSettingsButton *soundBtn;
    SKPSettingsButton *adsBtn;
    SKPSettingsButton *restoreBtn;
    SKPButton *backBtn;
    
    BOOL soundOn;
}

- (id)initWithSize:(CGSize)size Delegate:(id<PrefsNodeDelegate>)delegate {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        _delegate = delegate;
        self.zPosition = 100;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        soundOn = appDelegate.soundOn;
        
        
        CGFloat buttonHeight = self.size.width * kButtonSize;
        CGFloat verticalOffset = self.size.height * 0.04f;
        CGFloat totalButtonsHeight = 3 * buttonHeight + 2 * verticalOffset;
        CGFloat totalButtonsWidth = size.width * 0.6f;
        
        CGFloat startPosY = - totalButtonsHeight / 2;
        
        
        restoreBtn = [[SKPSettingsButton alloc] initWithImage:@"Btn_prefs_restore" Size:CGSizeMake(totalButtonsWidth, buttonHeight) Text:@"Restore" Text2:@"purchases"];
        [restoreBtn setPosition:CGPointMake(0, startPosY + restoreBtn.size.height / 2)];
        [restoreBtn.button addTarget:self action:@selector(restoreTap)];
        [self addChild:restoreBtn];
        
        adsBtn = [[SKPSettingsButton alloc] initWithImage:@"Btn_prefs_ads" Size:restoreBtn.size Text:@"Remove ADS" Text2:@""];
        [adsBtn setPosition:CGPointMake(0, restoreBtn.position.y + restoreBtn.size.height / 2 + verticalOffset + adsBtn.size.height / 2)];
        [adsBtn.button addTarget:self action:@selector(adsTap)];
        [self addChild:adsBtn];
        
        soundBtn = [[SKPSettingsButton alloc] initWithImage:@"Btn_prefs_sound_on" Size:restoreBtn.size Text:@"Sound On" Text2:@""];
        [soundBtn setPosition:CGPointMake(0, adsBtn.position.y + adsBtn.size.height / 2 + verticalOffset + soundBtn.size.height / 2)];
        [soundBtn.button addTarget:self action:@selector(soundTap)];
        [self addChild:soundBtn];
        
        restoreBtn.title.fontSize = adsBtn.title.fontSize = soundBtn.title.fontSize = MIN(restoreBtn.title.fontSize, MIN(adsBtn.title.fontSize, soundBtn.title.fontSize));
        
        
        backBtn = [[SKPButton alloc] initWithDefaultImage:@"Btn_prefs_back" SelectedImage:@"Btn_prefs_back" DisabledImage:@"Btn_prefs_back"];
        CGFloat buttonWidth = buttonHeight * backBtn.size.width / backBtn.size.height;
        [backBtn setSize:CGSizeMake(buttonWidth, buttonHeight)];
        [backBtn setPosition:CGPointMake(0, -size.height / 2 + backBtn.size.height / 2 + verticalOffset * 2)];
        [backBtn addTarget:self action:@selector(backTap)];
        [self addChild:backBtn];
        
        [self updateSoundButtonState];
    }
    return self;
}


- (void)soundTap {
    soundOn = !soundOn;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setSoundState:soundOn];
    [self updateSoundButtonState];
}

- (void)adsTap {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeAds];
}

- (void)restoreTap {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate restorePurchases];
}


- (void)backTap {
    [_delegate prefsClose];
}



- (void)updateSoundButtonState {
    if (soundOn) {
        [soundBtn.icon setTexture:[SKTexture textureWithImageNamed:@"Btn_prefs_sound_on"]];
        [soundBtn.title setText:@"Sound On"];
    } else {
        [soundBtn.icon setTexture:[SKTexture textureWithImageNamed:@"Btn_prefs_sound_off"]];
        [soundBtn.title setText:@"Sound Off"];
    }
}

@end
