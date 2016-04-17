//
//  achievements.h
//  catch crisis//
//  Created by Jason M McCoy on 07/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "LHScene.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <ReplayKit/RPScreenRecorder.h>

@interface achievements :SKScene <UIGestureRecognizerDelegate, SKPhysicsContactDelegate>
//+(id)scene;
@property (strong, nonatomic) NSMutableArray *challege_name;
@property (strong, nonatomic) NSMutableArray *challege;
@property (strong, nonatomic) NSMutableArray *bools;
@property (strong, nonatomic) NSString *leaderboardIdentifier;
@property (strong,nonatomic) NSTimer *speedOfcoins;
@property (strong,nonatomic) NSTimer *timercount;

-(void)makepause;

@end
