//
//  changescene.m
//  catch crisis
//
//  Created by Jason M McCoy on 07/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "changescene.h"
#import "LHSceneSubclass.h"
@implementation changescene
UISwipeGestureRecognizer* swipeupgesture;
+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"publishresource/shop.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
#if LH_USE_BOX2D
        NSLog(@"USES BOX2D");
#else
        NSLog(@"USES CHIPMUNK");
#endif
        
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    swipeupgesture.delegate=self;
    
    
    //[self setDelegate:(id)[NSNumber numberWithInt:UISwipeGestureRecognizerDirectionUp]];
    
    
    swipeupgesture= [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector( handleSwipeUp:)];
    [swipeupgesture setDirection: UISwipeGestureRecognizerDirectionUp];
    
    [self.view addGestureRecognizer:swipeupgesture];

    
}

-(void) handleSwipeUp:( UISwipeGestureRecognizer *) recognizer {
    SKView * skView = (SKView *)self.view;
    
    SKScene *scene;
    scene = [LHSceneSubclass scene];
    
    [skView presentScene:scene];
    NSLog(@"man");
    
   
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
   /*
     SKView * skView = (SKView *)self.view;
    SKScene * scene;
    
    scene = [LHSceneSubclass scene] ;
    [skView presentScene:scene];
            */
    
}

@end
