//
//  AppDelegate.h
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@class GameScene;

static const NSString *kAppstoreLink = @"itms-apps://itunes.apple.com/app/id1084498854";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) GameScene *scene;
@property (nonatomic) BOOL soundOn;
@property (nonatomic) BOOL canShowAds;
@property (nonatomic) int launchCount;
@property (nonatomic) BOOL canAskRate;

- (void)removeAds;
- (void)restorePurchases;
- (void)musicPlay;
- (void)musicStop;
- (void)crashPlay;
- (void)bonusPlay;
- (void)setSoundState:(BOOL)on;
- (void)share;
- (void)makeScreenshot;
- (void)askRate;

@end

