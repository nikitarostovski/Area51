//
//  AppDelegate.m
//  Escape51
//
//  Created by ROST on 09.02.16.
//  Copyright © 2016 ROST. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"
#import "GameCenterManager.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "RHero.h"

@interface AppDelegate () <MFMailComposeViewControllerDelegate>

@end

@implementation AppDelegate {
    NSString *productId;
    NSMutableArray *products;
    
    AVAudioPlayer *musicPlayer;
    AVAudioPlayer *soundBonusPlayer;
    AVAudioPlayer *soundCrashPlayer;
    
    bool transactionInProgress;
    UIAlertController *pending;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [_window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // set up settings
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    _launchCount = [[defs valueForKey:@"launchCount"] intValue];
    _soundOn = [[defs valueForKey:@"soundOn"] boolValue];
    if (!_launchCount) {
        _soundOn = YES;
        [defs setValue:@(0) forKey:@"score"];
        [defs setValue:nil forKey:@"Hero"];
        [defs setValue:@(YES) forKey:@"askRate"];
    }
    _launchCount++;
    _canAskRate = [[defs valueForKey:@"askRate"] boolValue];
    
    [defs setValue:@(_launchCount) forKey:@"launchCount"];
    [defs synchronize];
    
    NSLog(@"Launch count: %d", _launchCount);
    NSLog(@"Can ask: %d", _canAskRate);
    
    // set up sound players
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background" withExtension:@"mp3"];
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    musicPlayer.numberOfLoops = -1;
    [musicPlayer prepareToPlay];
    
    NSURL *soundBonusURL = [[NSBundle mainBundle] URLForResource:@"bonus" withExtension:@"mp3"];
    soundBonusPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundBonusURL error:&error];
    soundBonusPlayer.numberOfLoops = 0;
    [soundBonusPlayer prepareToPlay];
    
    NSURL *soundCrashURL = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"mp3"];
    soundCrashPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundCrashURL error:&error];
    soundCrashPlayer.numberOfLoops = 0;
    [soundCrashPlayer prepareToPlay];
    
    // Game center
    [[GameCenterManager sharedManager] authenticatePlayer];
    
    return YES;
}


#pragma mark - Sharing

- (void)askRate {
    if (!_canAskRate)
        return;
    
    if (_launchCount % 10 != 0 || _launchCount < 5)
        return;
    
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Like my game?" message:@"Let others know what you think about this game!" preferredStyle: UIAlertControllerStyleAlert];
    
    __weak AppDelegate *weakSelf = self;
    
    UIAlertAction *rateAction = [UIAlertAction actionWithTitle:@"Rate now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[kAppstoreLink copy]]];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:@(NO) forKey:@"askRate"];
        weakSelf.canAskRate = NO;
        [defs synchronize];
    }];
    [actionSheetController addAction:rateAction];
    
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"Maybe later 😅" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [actionSheetController addAction:laterAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Leave me alone!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:@(NO) forKey:@"askRate"];
        weakSelf.canAskRate = NO;
        [defs synchronize];
    }];
    [actionSheetController addAction:cancelAction];
    
    
    UIViewController *vc = self.window.rootViewController;
    [vc presentViewController:actionSheetController animated:YES completion:nil];
}

- (void)makeScreenshot {
    UIGraphicsBeginImageContextWithOptions(_window.rootViewController.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [_window.rootViewController.view drawViewHierarchyInRect:_window.rootViewController.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(viewImage) {
        NSData *imgData = UIImagePNGRepresentation([self resizeAndRoundScreenshot:[self cropScreenshot: viewImage]]);
        
        NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *imageName = [imagePath stringByAppendingPathComponent:@"screenshot.png"];
        [imgData writeToFile:imageName atomically:YES];
    } else
        NSLog(@"error while taking screenshot");
}

- (UIImage *)cropScreenshot:(UIImage *)image {
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    
    CGFloat size = imageSize.width * 0.75;
    CGPoint center = CGPointMake(_scene.hero.position.x / _scene.size.width * imageSize.width, imageSize.height / 2);
    CGRect rect = CGRectMake(center.x - size / 2, center.y - size / 2, size, size);
    if (rect.origin.x < 0) {
        rect.origin.x = 0;
    } else if (rect.origin.x > imageSize.width - size) {
        rect.origin.x = imageSize.width - size;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

- (UIImage *)resizeAndRoundScreenshot:(UIImage *)image {
    CGFloat size = 256.0;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size, size) cornerRadius:size / 2] addClip];
    [image drawInRect:CGRectMake(0, 0, size, size)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)share {
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [imagePath stringByAppendingPathComponent:@"screenshot.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"ShareImage"];
    }
    
    NSString *message = [NSString stringWithFormat:@"I've got %lld pts in Escape51", [[[NSUserDefaults standardUserDefaults] valueForKey:@"score"] longLongValue]];
    NSURL *link = [NSURL URLWithString:[kAppstoreLink copy]];
    
    NSArray *postItems = @[message, image, link];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityVC animated:YES completion:nil];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    if (_scene) {
        [_scene pause];
    }
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - public


- (void)musicPlay {
    if (_soundOn) {
        [musicPlayer play];
    }
}

- (void)musicStop {
    [musicPlayer stop];
}


- (void)crashPlay {
    if (!_soundOn)
        return;
    [soundCrashPlayer play];
}

- (void)bonusPlay {
    if (!_soundOn)
        return;
    [soundBonusPlayer play];
}

- (void)setSoundState:(BOOL)on {
    _soundOn = on;
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setValue:@(on) forKey:@"soundOn"];
    [defs synchronize];
    
    if (on) {
        [self musicPlay];
    } else {
        [self musicStop];
    }
}

@end
