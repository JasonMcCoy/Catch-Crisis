//
//  ViewController.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "ViewController.h"
#import "LHSceneSubclass.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "shared.h"
#import <Social/Social.h>
#import  "endsecreen.h"
#import "achievements.h"
@implementation ViewController
BOOL gameCenterEnabled;
int o=0;


NSMutableArray *gm;
-(void)viewDidLoad {
    [super viewDidLoad];
       [self authenticateLocalPlayer];
  
    [RPScreenRecorder sharedRecorder].delegate = self;
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _viewScene = [LHSceneSubclass scene];
    _viewScene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [skView presentScene:_viewScene];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseGameScene)
                                                 name:@"PauseGameScene"
                                               object:nil];
}


-(void)stopScreenRecordingRecordingWithHandler:(void (^)())handler {
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        if(error != nil) {
            [self showScreenRecordingAlert:error.description];
            return;
        } else {
            previewViewController.previewControllerDelegate = self;
            [shared sharedInstance].previewController = previewViewController;
            handler();
        }
    }];
}

-(void)startScreenRecording {
    NSLog(@"Screen Capturing");
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    recorder.delegate = self;
    
    [recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        if(error == nil) {
            [shared sharedInstance].screen_capturing = YES;
        } else {
            [self showScreenRecordingAlert:error.description];
        }
    }];
}

-(void)stopScreenRecording {
    NSLog(@"Stop Capturing");
    [shared sharedInstance].screen_capturing = NO;
    [self stopScreenRecordingRecordingWithHandler:^{
        [self replay_proc];
    }];
}

-(void)showScreenRecordingAlert:(NSString *)name {
    [shared sharedInstance].screen_capturing = NO;
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ReplayKit Error"
                                                      message:name
                                                     delegate:self
                                            cancelButtonTitle:@"Got it Thanks!"
                                            otherButtonTitles:nil];
    [message show];
}

-(void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController {
    // Display the error the user to alert them that the recording failed.
    [self showScreenRecordingAlert:error.localizedDescription];
    if(previewViewController != nil) {
        [shared sharedInstance].previewController = previewViewController;
    }
}

-(void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)replay_proc {
    NSLog(@"Replay");
    if([shared sharedInstance].previewController == nil) {
        [self showScreenRecordingAlert:@"Captured screen doesn't exist."];
        return;
    }
    
    [shared sharedInstance].previewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.view.window.rootViewController presentViewController:[shared sharedInstance].previewController animated:YES completion:nil];
}

-(void)pauseGameScene {
    //achievements *nextScene = [[achievements alloc] init];
       // [[NSNotificationCenter defaultCenter]addObserver:[shared sharedInstance].nextScene selector:@selector(makepause) name:@"makepause" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
 //   [self showLeaderboardAndAchievements:YES];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    gm = [[NSMutableArray alloc]init];
    NSLog(@"running");
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    leaderboardRequest.identifier=@"com.critis.highscore";
    leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                //Handle error
            } else {
                //[delegate onLocalPlayerScoreReceived:leaderboardRequest.localPlayerScore];

                for (GKScore *s in scores) {
                    NSMutableString *temp=[NSMutableString stringWithString:s.player.alias];
                    
                    NSString *temp2=s.formattedValue;
                    for(int i=(int)temp.length;i<14;i++){
                        [temp appendString:@" "];
                    }
                    
                    [temp appendString:temp2];
                    [gm insertObject:temp atIndex:o];
                   // NSLog(@"ab%@",my);
                    o++;
                }
                //NSLog(@"%@",gm);
                [[shared sharedInstance].gamecenter addObjectsFromArray:gm];
                //NSLog(@"%@gamecenter",[shared sharedInstance].gamecenter);
            }
        }];
    }
}

-(void)authenticateLocalPlayer{
    NSLog(@"game center");
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                gameCenterEnabled = YES;
            }
            
            else{
              
                gameCenterEnabled = NO;
               
            }
        }
    };
    
    if(gameCenterEnabled){
    
    [shared sharedInstance].playername=localPlayer.alias;
    }
    else{
       [shared sharedInstance].playername=@"Top Score #";
    }
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)showShareScreen {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"TestTweet from the Game !!"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

@end
