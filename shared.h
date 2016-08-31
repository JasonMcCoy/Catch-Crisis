//
//  shared.h
//  catch crisis
//
//  Created by Jason M McCoy on 06/05/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import <Foundation/Foundation.h>
#import "achievements.h"
#import "LHSceneSubclass.h"
#import <ReplayKit/RPScreenRecorder.h>

@interface LeaderboardData: NSObject {
    NSString* playerName;
    NSString* score;
}

@property (nonatomic, retain) NSString* playerName;
@property (nonatomic, retain) NSString* score;

@end

@interface shared : NSObject
{
    NSMutableArray *gamecenter;
    long score;
}

@property (nonatomic, retain) RPPreviewViewController* previewController;
@property (nonatomic, retain) NSMutableArray *gamecenter;
@property BOOL expiredOneHour, rewardVideoAlerted;
@property BOOL screen_capturing;
@property long score;
@property int flag,heart1life,heart2life,monkey;
@property NSString *playername;
@property LHSceneSubclass *mainScene;
@property float shopbutton;
@property NSString *backtexture,*heart1tex,*heart2tex,*lifeboxtext,*playertexture;
@property NSString *endtexture;
@property BOOL isForAchivements;
+(shared*)sharedInstance;

@end
