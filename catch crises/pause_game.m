//
//  pause_game.m
//  catch crisis

//
//  Created by Jason M McCoy on 18/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "pause_game.h"
#import "LHSceneSubclass.h"
@implementation pause_game
UISwipeGestureRecognizer* swipeupgesture;
#define kMinDistance    15
#define kMinDuration    0.01
#define kMinSpeed       50
#define kMaxSpeed       500
CGPoint  scurrentlc,scurrentLocation;

int solock=0,sfmove=0;
NSTimeInterval startTime;
+(id)scene
{
    return [[pause_game alloc] initWithContentOfFile:@"publishresource/shop.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
                
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view{
    
    
    
    
}

-(void)willMoveFromView:(SKView *)view{
    [self removeFromParent];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
     scurrentlc = [[touches anyObject] locationInNode:self];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Determine distance from the starting point
    CGFloat dx = location.x - scurrentlc.x;
    CGFloat dy = location.y - scurrentlc.y;
    CGFloat magnitude = sqrt(dx*dx+dy*dy);
    
    // Determine time difference from start of the gesture
    CGFloat dt = touch.timestamp - startTime;
    
    // Determine gesture speed in points/sec
    NSLog(@"1");
    CGFloat speed = magnitude / dt;
    if (speed <1000 || speed>1000) {
        // Calculate normalized direction of the swipe
        dx = dx / magnitude;
        dy = dy / magnitude;
        
        NSLog(@"Swipe detected with speed = %g and direction (%g, %g)",speed, dx, dy);
        if(dy<0 && sfmove==0){
            NSLog(@"2");
            
            
        }
        else if(dy>0 && sfmove==1){
            NSLog(@"3");
            SKView *spriteView = (SKView*)self.view;
            
            SKScene * scene;
            
            scene = [LHSceneSubclass scene] ;
            
            // Present the scene.
            [spriteView presentScene:scene transition:nil];
            
        }
        
        
    }
    
    solock=0;
    sfmove=0;
    
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    scurrentLocation =[[touches anyObject] locationInNode:self];
    
    
    if(solock==0){
        
        if((scurrentlc.y>scurrentLocation.y) ){
            
            sfmove=0;
            
        }
        if((scurrentLocation.y>scurrentlc.y)){
            
            
            sfmove=1;
        }
        solock=1;
        
    }
    
}

@end
