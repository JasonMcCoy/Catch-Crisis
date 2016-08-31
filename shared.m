//
//  shared.m
//  catch crisis
//
//  Created by Jason M McCoy on 06/05/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "shared.h"

@implementation LeaderboardData
@synthesize playerName;
@synthesize score;
@end

@implementation shared
@synthesize rewardVideoAlerted;
@synthesize previewController;
@synthesize screen_capturing;
@synthesize expiredOneHour;
@synthesize gamecenter;
@synthesize score;
@synthesize flag;
@synthesize isForAchivements;
@synthesize playername;
@synthesize backtexture,heart2life,heart1life,heart1tex,heart2tex,lifeboxtext,endtexture;
static shared* sharedInstance;

+ (shared*)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[shared alloc] init];
        
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        gamecenter = [[NSMutableArray alloc] init];
        expiredOneHour = NO;
        screen_capturing = NO;
        rewardVideoAlerted = NO;
        isForAchivements = NO;
    }
    return self;
}


@end
