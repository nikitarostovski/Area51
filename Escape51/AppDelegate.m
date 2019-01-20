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
#import <Chartboost/Chartboost.h>
#import <StoreKit/StoreKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "RHero.h"

@interface AppDelegate () <ChartboostDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate>

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
        [self setCanShowAds:YES];
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
    
    
    // set up chartboost
    [Chartboost startWithAppId:@"570a7f19f6cd4561de20d2a2"
                  appSignature:@"70614dcd967d22915665a564f660510232c9ea17"
                      delegate:self];
    
    // set up in-app
    [SKPaymentQueue.defaultQueue addTransactionObserver:self];
    transactionInProgress = NO;
    products = [NSMutableArray array];
    productId = @"com.ozz.escape51.removeads";
    [self requestProductInfo];
    
    // Game center
    [[GameCenterManager sharedManager] authenticatePlayer];
    
    // create loading alert
    [self createLoadingAlert];
    
    return YES;
}

- (void)requestProductInfo {
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
        
        productRequest.delegate = self;
        [productRequest start];
    }
    else {
        NSLog(@"Cannot perform In App Purchases.");
    }
}

- (void)createLoadingAlert {
    
    pending = [UIAlertController alertControllerWithTitle:@"" message:@""
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor blackColor];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [pending.view addSubview:indicator];
    NSDictionary * views = @{@"pending" : pending.view, @"indicator" : indicator};
    
    NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [pending.view addConstraints:constraints];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];
}

- (void)showLoading {
    
    NSArray *titles = @[@"You shouldn't have done that.",
                        @"Your time is important to us. Please hold.",
                        @"Loading new loading alert.",
                        @"Shovelling coal into the server.",
                        @"640K ought to be enough for anybody."];
    NSString *title = titles[arc4random() % [titles count]];
    [pending setMessage:[NSString stringWithFormat:@"%@\n\n", title]];
    
    UIViewController *vc = self.window.rootViewController;
    [vc presentViewController:pending animated:YES completion:nil];
}

- (void)hideLoadingWithCompletion:(void (^ __nullable)(void))completion {
    [pending dismissViewControllerAnimated:YES completion:completion];
}

- (void)showMessageWithTitle:(NSString *)title Text:(NSString *)text {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [actionSheetController addAction:cancelAction];
    
    UIViewController *vc = self.window.rootViewController;
    [vc presentViewController:actionSheetController animated:YES completion:nil];
}


#pragma mark - Sharing

- (void)askRate {
    if (!_canAskRate)
        return;
    
    if (_launchCount % 10 != 0 || _launchCount < 5)
        return;
    
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Like my game?" message:@"Let others know what you think about this game!" preferredStyle: UIAlertControllerStyleAlert];
    
    
    UIAlertAction *rateAction = [UIAlertAction actionWithTitle:@"Rate now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[kAppstoreLink copy]]];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:@(NO) forKey:@"askRate"];
        _canAskRate = NO;
        [defs synchronize];
    }];
    [actionSheetController addAction:rateAction];
    
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"Maybe later 😅" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [actionSheetController addAction:laterAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Leave me alone!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setValue:@(NO) forKey:@"askRate"];
        _canAskRate = NO;
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


#pragma mark - Payment

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (response.products.count != 0) {
        for (SKProduct *product in response.products) {
            [products addObject:product];
        }
    } else {
        NSLog(@"There are no products.");
    }
    if (response.invalidProductIdentifiers.count != 0) {
        NSLog(@"%@", response.invalidProductIdentifiers.description);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    transactionInProgress = NO;
    [self hideLoadingWithCompletion:^{
        NSLog(@"Received restored transactions: %lu", (unsigned long)queue.transactions.count);
        BOOL restored = NO;
        
        for (SKPaymentTransaction *transaction in queue.transactions) {
            NSString *pId = transaction.payment.productIdentifier;
            if ([pId isEqualToString:productId]) {
                [self setCanShowAds:NO];
                [self showMessageWithTitle:@"Success 😎" Text:@"Purchases successfully restored"];
                restored = YES;
            }
        }
        if (!restored) {
            UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Nothing to restore" message:@"I couldn't find any missing purchases associated with this account." preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *rateAction = [UIAlertAction actionWithTitle:@"Contact Nick 😇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                    [composeViewController setMailComposeDelegate:self];
                    [composeViewController setToRecipients:@[@"nikitarostovski@ya.ru"]];
                    [composeViewController setSubject:@"wassup"];
                    [self.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
                }
            }];
            [actionSheetController addAction:rateAction];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:nil];
            [actionSheetController addAction:cancelAction];
            
            
            UIViewController *vc = self.window.rootViewController;
            [vc presentViewController:actionSheetController animated:YES completion:nil];
        }
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    transactionInProgress = NO;
    [self hideLoadingWithCompletion:^{
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchased: {
                    NSLog(@"Transaction completed successfully.");
                    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
                    [self showMessageWithTitle:@"Success 😎" Text:@"Ads successfully removed"];
                    [self setCanShowAds:NO];
                    break;
                }
                case SKPaymentTransactionStateFailed: {
                    NSLog(@"Transaction Failed");
                    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
                    
                    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Can not remove ads!" message:@"I couldn't remove ads and I have no idea why!" preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *rateAction = [UIAlertAction actionWithTitle:@"Contact Nick 😇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if ([MFMailComposeViewController canSendMail]) {
                            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                            [composeViewController setMailComposeDelegate:self];
                            [composeViewController setToRecipients:@[@"nikitarostovski@ya.ru"]];
                            [composeViewController setSubject:@"wassup"];
                            [self.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
                        }
                    }];
                    [actionSheetController addAction:rateAction];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:nil];
                    [actionSheetController addAction:cancelAction];
                    
                    
                    UIViewController *vc = self.window.rootViewController;
                    [vc presentViewController:actionSheetController animated:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    transactionInProgress = NO;
    [self hideLoadingWithCompletion:^{
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Can not restore!" message:@"I couldn't restore anything because of some technical reasons. Or dinosaurs. Or zombeavers." preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *rateAction = [UIAlertAction actionWithTitle:@"Contact Nick 😇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"nikitarostovski@ya.ru"]];
                [composeViewController setSubject:@"wassup"];
                [self.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
            }
        }];
        [actionSheetController addAction:rateAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleCancel handler:nil];
        [actionSheetController addAction:cancelAction];
        
        
        UIViewController *vc = self.window.rootViewController;
        [vc presentViewController:actionSheetController animated:YES completion:nil];
    }];
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

- (void)removeAds {
    if (transactionInProgress || ![products count]) {
        //[self showError:@"Can not perform a transaction. Try again later"];
        return;
    }
    /*if (![self canShowAds]) {
        [self showMessageWithTitle:@"Hey!" Text:@"You've already removed ads"];
        return;
    }*/
    
    [self showLoading];
    SKPayment *payment = [SKPayment paymentWithProduct: products[0]];
    [SKPaymentQueue.defaultQueue addPayment:payment];
    transactionInProgress = YES;
}

- (void)restorePurchases {
    if (transactionInProgress) {
        //[self showError:@"Can not restore purchases"];
        return;
    }
    /*if (![self canShowAds]) {
        [self showMessageWithTitle:@"Hey!" Text:@"You've already removed ads"];
        return;
    }*/
    
    [self showLoading];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    transactionInProgress = YES;
}


- (void)setCanShowAds:(BOOL)canShowAds {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:canShowAds forKey:@"canShowAds"];
    [userDefaults synchronize];
}

- (BOOL)canShowAds {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults valueForKey:@"canShowAds"] boolValue];
    
}

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
