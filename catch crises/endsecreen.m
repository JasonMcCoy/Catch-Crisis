//
//  endsecreen.m
//  catch crisis
//
//  Created by Jason M McCoy on 18/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "endsecreen.h"
#import "achievements.h"
#import "LHSceneSubclass.h"
#import "shared.h"
#import "AVFoundation/AVFoundation.h"
#import <Social/Social.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import <Chartboost/Chartboost.h>
#import "ViewController.h"
@implementation endsecreen
 NSString *list,*num;
NSMutableDictionary  *dit;
SKLabelNode *score_onend,*highscorelabel;
AVAudioPlayer *endmusic,*buttonp;
long hscore,highscore;

NSTimer* _adstimer;
bool _ads_occur = NO;

int loseCount1=0;

+(id)scene {
    if([shared sharedInstance].monkey==0){
        return [[self alloc] initWithContentOfFile:@"endp/newscene.lhplist"];
   
    }
    else{
        return [[self alloc] initWithContentOfFile:@"monkey/monkend.lhplist"];
    }
    
    loseCount1++;
    
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile {
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        
        
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/Le-Parie" ofType:@"mp3"]];
    endmusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [endmusic setNumberOfLoops:-1];
    [endmusic play];
    hscore=[shared sharedInstance].score;
    list = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    list = [list stringByAppendingPathComponent:@"highscore.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:list]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:list error:nil];
    }
    
     dit = [[NSMutableDictionary alloc] initWithContentsOfFile:list];
 
    SKNode *a=[self childNodeWithName:@"scorenode"];
    NSLog(@"%@",dit);

            score_onend=[[SKLabelNode alloc]init];
            score_onend.name=@"scoreonend";
            score_onend.zPosition=8;
        //  score_onend.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-30);
        //  [score_onend setFontName:[UIFont fon]];
            
           [score_onend setFontName:@"PoetsenOne-Regular"];
            NSString *num = [NSString stringWithFormat:@"%li",hscore];
            [score_onend setText:num];
            [score_onend setFontSize:80.0];
            [score_onend setFontColor:[UIColor brownColor]];
            [a addChild:score_onend];
            [self backactive];
            [self fivehighscore];
            [self gethighscore];
}

-(NSString*)textureAtlasNamed:(NSString *)fileName {
    
    
    if(self.frame.size.height==1334){//iphone6
        fileName = [NSString stringWithFormat:@"%@-667", fileName];
        
    }
    else if(self.frame.size.height==1104){ //iphone6+
        
        fileName = [NSString stringWithFormat:@"%@-736@2x", fileName];
        
    }
    else if (self.frame.size.height==1136){ //iphone5
        fileName = [NSString stringWithFormat:@"%@-568", fileName];
        
    }
    else if (self.frame.size.height==960){ //iphone4
        fileName =fileName;
        
    }
    else{//iphone6
        fileName = [NSString stringWithFormat:@"%@-667", fileName];
        
    }
    
    return fileName;
}

-(void)showadd {
  NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:list];
    NSNumber *my=[dit objectForKey:@"second"];
    if([my intValue]<2){
        int temp=0;
        if([my intValue]==0){
            temp=1;
        }
        else{
            temp=2;
            [self showadvertisement];
            
        }
        [dit setObject:[NSNumber numberWithLong:temp] forKey:@"second"];
        [dit writeToFile: list atomically:YES];
    }
    
     if(hscore>highscore){
        [self showadvertisement];
        
    }
    else{
        NSNumber *num=[dit objectForKey:@"couter"];
        int t;
        if([num intValue]==3){
            
            [self showadvertisement];
            t=0;
        }
        else{
          t=[num intValue];
            t++;
            
        }
        
        [dit setObject:[NSNumber numberWithLong:t] forKey:@"couter"];
        [dit writeToFile: list atomically:YES];
    }
    
    
}

-(void)showadvertisement {
    if (loseCount1<3) return;
    
    [Chartboost showInterstitial:CBLocationHomeScreen];

    _ads_occur = YES;
    _adstimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(inputValue) userInfo:nil repeats:NO];
}

-(void)inputValue {

    _ads_occur = NO;
}

-(void)backactive {
    SKSpriteNode *endback=(SKSpriteNode *)[self childNodeWithName:@"quick_backgroundOriginal"];
    [endback setTexture:[SKTexture textureWithImageNamed:[shared sharedInstance].backtexture]];
}

-(void)gethighscore {
    SKNode *b=[self childNodeWithName:@"hscore"];
    NSNumber *a =[dit objectForKey:@"0"];
    highscore=[a longValue];
    if(hscore>highscore){
        highscore=hscore;
    }
    
    
    highscorelabel=[[SKLabelNode alloc]init];
    highscorelabel.name=@"highscore";
    highscorelabel.zPosition=8;
    //score_onend.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-30);
    // [score_onend setFontName:[UIFont fon]];
    
    
    
    [highscorelabel setFontName:@"PoetsenOne-Regular"];
    NSMutableString  *highScore=[[NSMutableString alloc]initWithString:@"High Score"];
     num= [highScore stringByAppendingFormat:@"%li", highscore];
    [highscorelabel setText:num];
    [highscorelabel setFontSize:50.0];
    [highscorelabel setFontColor:[UIColor brownColor]];
    [b addChild:highscorelabel];

}

-(void)fivehighscore {
    NSLog(@"%liscore",hscore);
    long t;
    int i=0;
    while(i<5){
        NSString *n = [NSString stringWithFormat:@"%d",i];
        NSNumber *a =[dit objectForKey:n];
        t=[a longValue];
  
        if(hscore>t || t==hscore){
            NSLog(@"enter list");
            NSString *num = [NSString stringWithFormat:@"%d",i];
            [dit setObject:[NSNumber numberWithLong:hscore] forKey:num];
            [dit writeToFile: list atomically:YES];
           
          
            int u=i+1;
                while(u<5){
                
                NSString *key = [NSString stringWithFormat:@"%d",u];
                NSString *key1 = [NSString stringWithFormat:@"%d",u];
                NSNumber *number =[dit objectForKey:key1];
                [dit setObject:[NSNumber numberWithLong:t] forKey:key];
                [dit writeToFile: list atomically:YES];
                //u=u+1;
               
                t=[number longValue];
                    u=u+1;
           }
            
            break;
           
        }
        i++;
        
    }
 }

-(UIImage *)captureScreen {
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(_ads_occur) return;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/SFX-4Match" ofType:@"mp3"]];
    buttonp = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    
    CGPoint location = [[touches anyObject] locationInNode:self];
    UIViewController *vc=self.view.window.rootViewController;
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:location];
    if([[touchedNode name] isEqualToString:@"score_home"]){
        
            [buttonp play];
            SKView * skView = (SKView *)self.view;
        
            SKScene * scene;
        
            scene = [LHSceneSubclass scene] ;
        
            // Present the scene.
            [skView presentScene:scene];
        
            for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
                [self.view removeGestureRecognizer:recognizer];
            }
    }
    else if ([[touchedNode name] isEqualToString:@"score_retry"]){
        
        [buttonp play];
        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
        //SKTransition *doors = [SKTransition fadeWithDuration:0.03];
        [self.view presentScene:nextScene transition:nil];
    }
    else if([[touchedNode name] isEqualToString:@"score_facebook"]){
        UIImage* img = [self captureScreen];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:@"Check out my score on Catch Crisis!"];
        [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/catch-crisis/id1059354759?ls=1&mt=8"]];
        [controller addImage:img];
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
        {
            [controller dismissViewControllerAnimated:YES completion:nil];
            switch(result)
            {
                case SLComposeViewControllerResultDone:
                {
                    NSString *title = @"Share";
                    NSString *message = @"Thank you for sharing!";
                    UIAlertView *messageView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [messageView show];
                    
                    break;
                }
                case SLComposeViewControllerResultCancelled:
                {
                }
                default:
                    break;
            }
        };
        [controller setCompletionHandler:completionHandler];
        [self.view.window.rootViewController presentViewController:controller animated:YES completion:^(){}];
    }
    else if([[touchedNode name] isEqualToString:@"score_twitter"]){
        UIImage* img = [self captureScreen];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:@"You'll never beat me! #CatchCrisis"];
        [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/catch-crisis/id1059354759?ls=1&mt=8"]];
        [controller addImage:img];
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
        {
            [controller dismissViewControllerAnimated:YES completion:nil];
            switch(result)
            {
                case SLComposeViewControllerResultDone:
                {
                    NSString *title = @"Share";
                    NSString *message = @"Thank you for sharing!";
                    UIAlertView *messageView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [messageView show];
                    
                    break;
                }
                case SLComposeViewControllerResultCancelled:
                {
                }
                default:
                    break;
            }
        };
        [controller setCompletionHandler:completionHandler];
        [self.view.window.rootViewController presentViewController:controller animated:YES completion:^(){}];
    }
    
    if([[touchedNode name] isEqualToString:@"score_leaderBoard"])
    {
        [shared sharedInstance].flag=4;
        [shared sharedInstance].isForAchivements = YES;
        SKView *skView = (SKView *)self.view;
        ViewController *viewCotroller = (ViewController *) self.view.window.rootViewController;
        
        // Present the scene.
        dispatch_async(dispatch_get_main_queue(), ^{
            [skView presentScene:viewCotroller.viewScene];
        });
//
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//            
//            //Your code goes in here
//            NSLog(@"Main Thread Code");
//            [self CallMainClass];
//            
//        }];
    }
    NSLog(@"%@",[touchedNode name]);
}

-(void)CallMainClass
{
    
    SKView *skView = (SKView *)self.view;
    
    SKScene *scene;
    scene = [LHSceneSubclass scene];
    
    
    
    // Present the scene.
    [skView presentScene:scene];

}

-(void)willMoveFromView:(SKView *)view {
    [endmusic stop];
}

@end
