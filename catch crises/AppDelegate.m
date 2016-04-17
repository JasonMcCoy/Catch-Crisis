//
//  AppDelegate.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//


#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

#import "Flurry.h"
#import "shared.h"
#import <SpriteKit/SpriteKit.h>
#import "achievements.h"
#import "ALSdk.h"
#import "ALIncentivizedInterstitialAd.h"
#import "LHSceneSubclass.h"
#import "ViewController.h"

//Test Id : 56628f92a8b63c186872b62c                          //Client Id : 54dc9c92c909a6578b3f35e4
//          44659877754cc6fb3d315b04c83ff8a606636d09                        c712e459cb1042a5e526a34eda5c055b1b02730e


#define kAppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Key of Fluury added in code:- GTMCH3R4KYZMXDVMFY88
    //Key of Flurry in account :- YBQVY5V3N7TBHGDR2QZT
    NSString *flurrySDKVersion = [Flurry getFlurryAgentVersion];
    NSLog(@"%@", flurrySDKVersion);
    
    [Flurry setAppVersion:kAppVersion];
    [Flurry startSession:@"BPHTGTBFF9DGZSWDRPBH"];
    
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"54dc9c92c909a6578b3f35e4"
                  appSignature:@"c712e459cb1042a5e526a34eda5c055b1b02730e"
                      delegate:self];
    
//    [Chartboost showRewardedVideo:CBLocationMainMenu];
    //[Chartboost showInterstitial:CBLocationMainMenu];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if (shortcutItem != nil) {
            if ([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.quickplay"]) {
                [shared sharedInstance].flag = 3;
            }
            else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.archivements"]) {
                [shared sharedInstance].flag = 4;
            }
            else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.shop"]) {
                [shared sharedInstance].flag = 5;
            }
            else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.storymode"]) {
                [shared sharedInstance].flag = 6;
            }
        }
       
        //    else {
        //        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        //        if([localNotif.alertBody isEqualToString:@"Get a free monkey"]) {
        //            [shared sharedInstance].flag=1;
        //        }
        //    }
        
        //    [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(expireOneHour) userInfo:nil repeats:YES];
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [ALSdk initializeSdk];
    [ALIncentivizedInterstitialAd preloadAndNotify: self];
    [ALIncentivizedInterstitialAd shared].adDisplayDelegate = self;
    [ALIncentivizedInterstitialAd shared].adVideoPlaybackDelegate = self;
    [ALInterstitialAd shared].adLoadDelegate = self;
    
    [self setupRootViewController];
    
    
    return YES;
}

- (void)setupRootViewController{
    ViewController *controller;
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    self.window.rootViewController = controller;
}


-(void)application:(UIApplication * _Nonnull)application performActionForShortcutItem:(UIApplicationShortcutItem * _Nonnull)shortcutItem
        completionHandler:(void (^ _Nonnull)(BOOL succeeded))completionHandler {
   if ([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.quickplay"]) {
        [shared sharedInstance].flag = 3;
    } else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.archivements"]) {
        [shared sharedInstance].flag = 4;
    } else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.shop"]) {
        [shared sharedInstance].flag = 5;
    } else if([shortcutItem.type isEqual:@"com.tennisvideostore.book0031.storymode"]) {
        [shared sharedInstance].flag = 6;
    }
    [self setupRootViewController];
}


-(void)expireOneHour {
    [shared sharedInstance].expiredOneHour = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   //// /Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this
//       [[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"appIsActive" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appIsActive" object:nil];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
    NSString* ifa = [[[NSClassFromString(@"ASIdentifierManager") sharedManager] advertisingIdentifier] UUIDString];
    
    if (ifa) {
        ifa = [[ifa stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSLog(@"IFA: %@",ifa);
    } else {
        NSLog(@"IFA: No IFA returned from device");
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appIsActive" object:nil];
    
//    [ALIncentivizedInterstitialAd preloadAndNotify: self];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [shared sharedInstance].flag=1;
}

-(void)applicationWillTerminate:(UIApplication *)application {
    NSDate *now = [NSDate date];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"localnotification" forKey:@"monkey"];
    int daysToAdd = 2;
    NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*daysToAdd];
    localNotification.userInfo = userInfo;
    localNotification.fireDate = newDate1;
    localNotification.alertBody = @"Get a free monkey";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                       settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|
                                                       UIUserNotificationTypeSound categories:nil]];
    }
}


//AppLovin reward video delegates

-(void) videoPlaybackBeganInAd: (ALAd*) ad{

    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent:(NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched{

    [[shared sharedInstance].mainScene resumeMusic];
    
    if (wasFullyWatched && amountGiven.length>0) {
        
        NSString* highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:highscorelist]) {
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
            [fileManager copyItemAtPath:sourcePath toPath:highscorelist error:nil];
        }
        
        NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
        NSNumber *temp= [dit objectForKey:@"coins"];
        long t=(long)[temp longLongValue];
        t=t+[amountGiven intValue];
        //     [dit setObject:[NSNumber numberWithInt:1] forKey:@"review"];
        [dit setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
        [dit writeToFile: highscorelist atomically:YES];
        [[shared sharedInstance].mainScene showcoins];
    }
    NSLog(@"%@,%@,%d",NSStringFromSelector(_cmd),percentPlayed,wasFullyWatched);
}

-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view{

    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    if (amountGiven.length>0) {
        
    }
}

-(void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response{

    NSLog(@"SUCCESS %@",response);
//    NSString* currencyName = [response objectForKey: @"currency"];
    amountGiven = [response objectForKey: @"amount"];
    
//    NSString* highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    if (![fileManager fileExistsAtPath:highscorelist]) {
//        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
//        [fileManager copyItemAtPath:sourcePath toPath:highscorelist error:nil];
//    }
//    
//     NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
//     NSNumber *temp= [dit objectForKey:@"coins"];
//     long t=(long)[temp longLongValue];
//     t=t+[amountGiven intValue];
////     [dit setObject:[NSNumber numberWithInt:1] forKey:@"review"];
//     [dit setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
//     [dit writeToFile: highscorelist atomically:YES];
}


-(void) rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
    amountGiven=@"";
    // The user's reward was marked as fraudulent, they are most likely trying to modify their balance illicitly.
}

-(void) rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    NSLog(@"FAILURE %ld",(long)responseCode);
    amountGiven=@"";
    if(responseCode == kALErrorCodeIncentivizedValidationNetworkTimeout)
    {
        // The SDK was unable to reach AppLovin over the network.  The user's device is likely experiencing poor connectivity.
    }
    else if(responseCode == kALErrorCodeIncentivizedUserClosedVideo)
    {
        /* Indicates the user has exited a video prior to completion.  You may have already received didSucceedWithResponse.
         If you choose, to handle this case, you may optionally cancel the previously granted reward (if any). */
    }
    else
    {
        /* Something else went wrong. Wait a bit before showing another rewarded video. */
    }
}

-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad{

    NSLog(@"ad Loaded successfully");
    [[shared sharedInstance].mainScene alertRewardVideo];
    
}

-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code{

    NSLog(@"ad failed to load with code %d",code);
}

//Applovin delegates above

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);
    
    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}


- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward {
    NSString* highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:highscorelist]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:highscorelist error:nil];
    }
    
/*  NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
    NSNumber *temp= [dit objectForKey:@"coins"];
    long t=(long)[temp longLongValue];
    t=738;
    [dit setObject:[NSNumber numberWithInt:1] forKey:@"review"];
    [dit setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
    [dit writeToFile: highscorelist atomically:YES];*/
}

-(void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    NSLog(@"Fail to load rewarded video");
    if([shared sharedInstance].rewardVideoAlerted == YES) {
     /*   UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry!"
                                  message:@"Something went wrong. We're working on getting this fixed as soon as we can!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:@"Cancel", nil];
        [alertView show]; */
    }
}

/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Interstitial, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Interstitial, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Interstitial, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Interstitial, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Interstitial, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Interstitial, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Interstitial, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Interstitial, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Interstitial, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Interstitial, unknown error !");
        }
    }
}

/*
 * didCacheInterstitial
 *
 * Passes in the location name that has successfully been cached.
 *
 * Is fired on:
 * - All assets loaded
 * - Triggered by cacheInterstitial
 *
 * Notes:
 * - Similar to this is: (BOOL)hasCachedInterstitial:(NSString *)location;
 * Which will return true if a cached interstitial exists for that location
 */

- (void)didCacheInterstitial:(NSString *)location {
    NSLog(@"interstitial cached at location %@", location);
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */

- (void)didFailToLoadMoreApps:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load More Apps, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load More Apps, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load More Apps, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load More Apps, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load More Apps, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load More Apps, first session !");
        } break;
        case CBLoadErrorNoAdFound: {
            NSLog(@"Failed to load More Apps, Apps not found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load More Apps, session not started !");
        } break;
        default: {
            NSLog(@"Failed to load More Apps, unknown error !");
        }
    }
}

/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 */

- (void)didDismissInterstitial:(NSString *)location {
    NSLog(@"dismissed interstitial at location %@", location);
}

/*
 * didDismissMoreApps
 *
 * This is called when the more apps page is dismissed
 *
 * Is fired on:
 * - More Apps click
 * - More Apps close
 *
 */

- (void)didDismissMoreApps:(NSString *)location {
    NSLog(@"dismissed more apps page at location %@", location);
}

/*
 * didDisplayInterstitial
 *
 * Called after an interstitial has been displayed on the screen.
 */

- (void)didDisplayInterstitial:(CBLocation)location {
    NSLog(@"Did display interstitial");
    // We might want to pause our in-game audio, lets double check that an ad is visible
    if ([Chartboost isAnyViewVisible]) {
        // Use this function anywhere in your logic where you need to know if an ad is visible or not.
        NSLog(@"Pause audio");
    }
}


/*!
 @abstract
 Called after an InPlay object has been loaded from the Chartboost API
 servers and cached locally.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an InPlay object has been loaded from the Chartboost API
 servers and cached locally for a given CBLocation.
 */
- (void)didCacheInPlay:(CBLocation)location {
    NSLog(@"Successfully cached inPlay");
}

/*!
 @abstract
 Called after a InPlay has attempted to load from the Chartboost API
 servers but failed.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when an InPlay has attempted to load from the Chartboost API
 servers but failed for a given CBLocation.
 */
- (void)didFailToLoadInPlay:(CBLocation)location
                  withError:(CBLoadError)error {
    
    NSString *errorString = @"";
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            errorString = @"Failed to load In Play, no Internet connection !";
        } break;
        case CBLoadErrorInternal: {
            errorString = @"Failed to load In Play, internal error !";
        } break;
        case CBLoadErrorNetworkFailure: {
            errorString = @"Failed to load In Play, network errorString !";
        } break;
        case CBLoadErrorWrongOrientation: {
            errorString = @"Failed to load In Play, wrong orientation !";
        } break;
        case CBLoadErrorTooManyConnections: {
            errorString = @"Failed to load In Play, too many connections !";
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            errorString = @"Failed to load In Play, first session !";
        } break;
        case CBLoadErrorNoAdFound : {
            errorString = @"Failed to load In Play, no ad found !";
        } break;
        case CBLoadErrorSessionNotStarted : {
            errorString = @"Failed to load In Play, session not started !";
        } break;
        case CBLoadErrorNoLocationFound : {
            errorString = @"Failed to load In Play, missing location parameter !";
        } break;
        default: {
            errorString = @"Failed to load In Play, unknown error !";
        }
    }
    NSLog(errorString);
}

@end
