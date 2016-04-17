//
//  ViewController.h
//  LevelHelper2-SpriteKit
//

//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <ReplayKit/RPScreenRecorder.h>

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate>

@property (strong, nonatomic) NSString *leaderboardIdentifier;

-(void)authenticateLocalPlayer;
-(void)startScreenRecording;
-(void)stopScreenRecording;

@property (nonatomic, retain) SKScene *viewScene;

@end
