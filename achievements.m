//
//  achievements.m
//  catch crisis
//
//  Created by Jason M McCoy on 07/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
/*this program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.*/

#import "achievements.h"
#import "pause_game.h"
#import "LHSceneSubclass.h"
#import "AVFoundation/AVFoundation.h"
#import "endsecreen.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "shared.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import <Chartboost/Chartboost.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import <sys/utsname.h>

@implementation achievements
@synthesize speedOfcoins,timercount;
NSArray *items;
SKSpriteNode *ring,*ring1,*ring2,*bring1,*bring2;
SKAction *walk,*warriorhit;

NSTimer* lotteryTimer=nil;

static  NSInteger flag=0;
static const uint32_t blockCategory = 0x1 <<0;
static const uint32_t  playerCategory = 0x1 <<1;
static const uint32_t  bottombody = 0x2 <<2;
static const uint32_t  lottery__bitmask = 0x3 <<3;

// 1 grcenotes pattern 2 trill 3 jackhammers 4 minijacks 5 stream  6 triplets  7 gallops 8 runnning men 9 crossovers 10 roles 11 staircases notes pattern in plist
#define SPRITES_ANIM_CAPGUY_WALK @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin1"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin2"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin3"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin4"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin5"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin6"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin7"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_goodCoin8"] \
]

#define bad_coin @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin1"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin2"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin3"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin4"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin5"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin6"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin7"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_badCoin8"] \
]

#define warrior_hit @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior2"] \
]
#define warrior_hit_right @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior3"] \
]
#define warrior_hit_left @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior1"] \
]
#define monkey_hit_left @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey1"] \
]
#define monkey_hit_right @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey3"] \
]
#define monkey_hit_middle @[ \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_01"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_02"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_03"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_04"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey_hit_05"], \
[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_monkey2"] \
]



//#define lotterywalk @[ \
//[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_lottery"], \
////[SKTexture textureWithImageNamed:@"quick_lottery1"] \
//]
UISwipeGestureRecognizer* swipeRightGesture,*swipeleftgesture;
SKSpriteNode *player,*pause_gam,*left,*lifebox,*capture;
SKLabelNode *livescore,*score_onend,*highest_score,*highest_combo;
NSURL *urlcoinm,*url_coin_miss;
NSString *destPath,*skinlist,*hlist,*goodtexture,*badtexture,*playertexture,*rtexture,*ltexture,*mtexture;
SKAction *g_coin_anim,*b_coin_anim,*waiting,*squence;
AVAudioPlayer *backmusic,*coinm,*coin_miss,*buttonpressed;;
static int i=0,indexl=0, lottery_catched=0,player_pos=0,lottery_count=0,imidiate_bad_coin=0,imidiate_good_coin_miss=0,two_x_points=1;
static int patterncategory=1,swipe_locked=1;
int bad_coin_occur=0;
static long score=0;
long  count_good_coin=0;
NSArray *arrayValues;
static id loop;
//int  GraceNotesPattern[8]= {3,1,2,1,1,3,2,3};
SKSpriteNode *scorebox,*lottery,*hearts,*sprite,*heart1,*heart2;
NSMutableDictionary  *dict;
LHNode *p_replay,*p_home,*p_resume,*node,*pausenode,*endscreen,*e_home,*e_retry,*e_leaderboard,*e_facebook,*e_twitter;
static int lottery_time=0,lifes=3,paused_pressed=0,lottery_goodcoins_count=0,timecount=1;
static long high_score=0;
static float gravity=-2.0,timec;
SKTexture *right,*leftplayer;
int gamemode=0,count_bad_coin=0,two_bad_coins=0,number_of_game=0,good_coin_100=0,bad_coin_hit=0,lottery_check=0,good_coin_miss=0,swipe=0,p_combo=0,g_combo=0,a_combo=0,catch_7_coins=0,catch_black=0,miss=-3.75,negative=-7.331,miss_count=0,negative_count=0,banana=-1,heart1_unlock=0,heart2_unlock=0,heart1_life=0,heart2_life=0,monkey=0,counter=0,streak=0,pauseflag=0;
NSTimer *timercount,*gravitytimer,*adstimer;
NSTimeInterval lmusict;
NSDate *pauseStart, *previousFireDate;
AppDelegate *appDelegate;

////////   Added in 2015.9.19  /////////////////////

    bool ads_occur = NO;
    int loseCount = 0;
    float drop_speed = 0.5f;
    SKAction* drop_action;


////////////////////////////////////////////////////


-(void)initiatevalues{
    
    lottery_time=0,
    lifes=3;
    patterncategory=1;
    arrayValues=nil;
    bad_coin_occur=0;
    i=0,indexl=0, score=0,lottery_catched=0,player_pos=0,lottery_count=0,imidiate_bad_coin=0,imidiate_good_coin_miss=0,two_x_points=1;
    swipe_locked=1,paused_pressed=0;
    gravity=-2.0f;
    
    count_good_coin=0;
    gamemode=0;
    two_bad_coins=0,number_of_game=0;
    good_coin_100=0,bad_coin_hit=0;
    lottery_check=0;
    good_coin_miss=0;
    high_score=0;
    lottery_goodcoins_count=0;
    p_combo=0,g_combo=0,a_combo=0,catch_7_coins=0;
    miss=-3.75,negative=-7.331;
    miss_count=0,negative_count=0;
    banana=-1;
    monkey=0;
    
}

-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {
        
        adstimer=[[NSTimer alloc]init];
        SKPhysicsBody* borderBody= [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0,0) toPoint:CGPointMake(self.frame.size.width,0)];
        
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody =borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        self.physicsBody.contactTestBitMask = bottombody;
        self.physicsBody.categoryBitMask = blockCategory;
        self.physicsBody.collisionBitMask =bottombody;
        self.name=@"bottom";
        self.physicsBody.usesPreciseCollisionDetection=YES;
        self.physicsBody.dynamic=NO;

      
       [self skinOfplayer_coins];
        
        NSString *scorelive;
        if(banana==1){
            scorelive=[NSString stringWithString:[self textureAtlasNamed:@"quick_scoreBoxmonkey"]];
        }
        else{
            scorelive=[NSString stringWithString:[self textureAtlasNamed:@"imageresource/quickGame/quick_scoreBox"]];
        }
             scorebox=[SKSpriteNode spriteNodeWithImageNamed:scorelive];
        
        
        NSString *lifeboxtext;
        if(monkey==1){
            lifeboxtext=[NSString stringWithString:[self textureAtlasNamed:@"imageresource/quickGame/quick_lifeBoxMonkey"]];
        }
        else{
            lifeboxtext=[NSString stringWithString:[self textureAtlasNamed:@"imageresource/quickGame/quick_lifeBox"]];
        }
        
        
        lifebox=[SKSpriteNode spriteNodeWithImageNamed:lifeboxtext];
      
        
        player=[SKSpriteNode spriteNodeWithImageNamed:playertexture];
        //player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        
        player.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(player.frame.size.width/2, player.frame.size.height/2) center:CGPointMake(CGRectGetMidX(player.frame), CGRectGetMidY(player.frame))];
        
        // player.physicsBody=[SKPhysicsBody bodyWithTexture:playerTexture size:playerTexture.size];
        pause_gam=[SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_pause"]];
        pause_gam.name=@"pause";
        if ([shared sharedInstance].screen_capturing) {
            capture = [SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_replay"]];
        } else{
            capture = [SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_record"]];
        }
        
        capture.name = @"capture";
        hearts=[SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_heart"]];
        heart1=[SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_heartLock"]];
        heart2=[SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_heartLock"]];
        livescore = [[SKLabelNode alloc] init];
        [livescore setFontSize:35.0];
        
        if(self.frame.size.height==1334){//iphone6
            player.position = CGPointMake(CGRectGetMidX(self.frame), player.size.height-7);
            
            scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+50, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            lifebox.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            capture.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            hearts.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-43, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            heart1.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width-36, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5-1);
            heart2.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width*2-29, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5-3);
            
            livescore.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+15, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.3+10);
        }
        else if(self.frame.size.height==1104){ //iphone6+
            
            
            player.position = CGPointMake(CGRectGetMidX(self.frame), player.size.height+10);
            scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+50, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7);
            lifebox.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7);
            pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-pause_gam.size.width-20, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7);
            capture.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-capture.size.width-pause_gam.size.width-20, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7);
            hearts.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-40, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7);
            heart1.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width-33, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7-2);
            heart2.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width*2-28, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.7-2);
            
            livescore.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
        
        
        }
        else if (self.frame.size.height==1136){ //iphone5
            
            player.position = CGPointMake(CGRectGetMidX(self.frame), player.size.height-10);
            
            scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
              lifebox.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+3);
               pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
            capture.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
             hearts.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-10, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+5);
            heart1.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width-4, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+1);
            heart2.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart2.size.width*2+2, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+1);
            livescore.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width, CGRectGetMaxY(self.frame)-scorebox.frame.size.width);
        }
        else if (self.frame.size.height==960){ //iphone4
            
            player.position = CGPointMake(CGRectGetMidX(self.frame), player.size.height/1.42-6);
            scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
            lifebox.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+3);
            pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
            capture.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+10);
            hearts.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-10, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+5);
            heart1.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width-4, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+1);
            heart2.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width*2+3, CGRectGetMaxY(self.frame)-scorebox.frame.size.width+1);
            livescore.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width, CGRectGetMaxY(self.frame)-scorebox.frame.size.width-2.5);
        }
        else{//iphone6
            
            player.position = CGPointMake(CGRectGetMidX(self.frame), player.size.height-7);
            scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+50, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            lifebox.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            capture.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            hearts.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width-45, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            heart1.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width-35, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            heart2.position=CGPointMake(CGRectGetMinX(self.frame)+scorebox.size.width+heart1.size.width*2-30, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.5);
            
            livescore.position=CGPointMake(CGRectGetMaxX(self.frame)-scorebox.size.width+15, CGRectGetMaxY(self.frame)-scorebox.frame.size.width/1.3+10);
        }
        player.physicsBody.dynamic=NO;
        player.physicsBody.usesPreciseCollisionDetection=YES;
        //player.physicsBody.categoryBitMask=ballCategory;
        player.physicsBody.contactTestBitMask = blockCategory;
        player.physicsBody.categoryBitMask = playerCategory|lottery__bitmask;
        player.physicsBody.collisionBitMask = blockCategory;
        player.name=@"player";
        
        player.zPosition = 3;
        [self addChild:player];
        scorebox.zPosition=4;
        [self addChild:scorebox];
        pause_gam.zPosition=4;
        [self addChild:pause_gam];
        capture.zPosition = 4;
        [self addChild:capture];
        hearts.name=@"hearts";
        hearts.zPosition=5;
        [self addChild:hearts];
        heart1.name=@"hearts";
        heart1.zPosition=5;
        [self addChild:heart1];
        heart2.name=@"hearts";
        heart2.zPosition=5;
        [self addChild:heart2];
        
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        NSString* model = [self deviceName];

        capture.hidden = YES;
        if(version < 9.0f){
            capture.hidden = YES;
        }else if([model isEqualToString:@"iPhone6,1"]){
            capture.hidden = NO;
        }else if([model isEqualToString:@"iPhone6,2"]){
            capture.hidden = NO;
        }else if([model isEqualToString:@"iPhone7,1"]){
            capture.hidden = NO;
        }else if([model isEqualToString:@"iPhone7,2"]){
            capture.hidden = NO;
        }else if([model isEqualToString:@"iPhone8,1"]){
            capture.hidden = NO;
        }else if([model isEqualToString:@"iPhone8,2"]){
            capture.hidden = NO;
        }

        livescore.zPosition=4;
        [livescore setFontName:@"PoetsenOne-Regular"];
        //livescore.blendMode=SKBlendModeAdd;
        
        [livescore setFontColor:[UIColor whiteColor]];
        livescore.text=@"0";
        [self addChild:livescore];
        
        lifebox.zPosition=4;
        lifebox.name=@"life";
        [self addChild:lifebox];
        
        //
        /* Setup your scene here */
    
         sprite =[[SKSpriteNode alloc]init];
        NSString *temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_backgroundOriginal"];
        //[sprite setTexture:temp];
        
        sprite=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:temp]];
        sprite.size=self.frame.size;
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sprite.name = @"background";//how the node is identified later
        sprite.zPosition = 0;
        [self addChild:sprite];
        //  SKTexture *playerTexture= [SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_warrior2"];
        //player=[SKSpriteNode spriteNodeWithImageNamed:@"imageresource/quickGame/quick_warrior2"];
       
        //[loop addObject:[NSNumber numberWithInt:flag]];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.0f,-2.0f);
   
        
        //timercount=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(caltime) userInfo:nil repeats:YES];
        //[timercount fire];
        
        
        //speedOfcoins=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(coins) userInfo:nil repeats:YES];
        //[speedOfcoins fire];
        //self.physicsWorld.gravity = CGVectorMake(0.0f,-2.0f);
        
        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(mlottery) userInfo:nil repeats:YES];
        
        
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(update) userInfo:nil repeats:YES];
        //[self coins]
        // [self endscreen];
        
        //[shared sharedInstance].nextScene=self.scene.view;
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      
    }
    return self;
}

-(NSString*)deviceName{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(void)coinAction:(float)time{

    waiting =[SKAction waitForDuration:time];
    
    //[waiting setValue:@"waitng" forKey:@"wait"];
    NSLog(@"waiting");
    SKAction *function=[SKAction runBlock:^{
        [self coins];
    }];
    squence=[SKAction sequence:@[waiting,function]];
    [self runAction:[SKAction repeatActionForever:squence] withKey:@"coinsfalling"];
}

-(void)removeCoinAction{
    [self removeActionForKey:@"coinsfalling"];
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

-(void)caltime{
    timecount++;
}

-(void)mlottery{
    lottery=[SKSpriteNode spriteNodeWithImageNamed:@"imageresource/quickGame/quick_lottery"];
    
    //lottery.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(lottery.frame.size.width, lottery.frame.size.height)];
    lottery.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:lottery.size];
    int pos=arc4random_uniform(3);
    if(pos==1){
        lottery.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/2), (CGRectGetMaxY(self.frame)+lottery.size.width));
    }
    else if(pos==2){
        
        
        lottery.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+lottery.size.width);
    }
    else{
        
        lottery.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/2), (CGRectGetMaxY(self.frame)+lottery.size.width));
        
    }
    
    SKShapeNode *glow=[[SKShapeNode alloc]init];
    glow=[SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(lottery.frame.size.width+3, lottery.frame.size.height+5)];
    glow.strokeColor = [SKColor yellowColor];
    // glow.fillColor=[SKColor yellowColor];
    glow.glowWidth=2;
    glow.blendMode=SKBlendModeAlpha;
    
    //SKAction *lottery_action=[SKAction animateWithTextures:lotterywalk timePerFrame:0.5];
    //SKAction *new=[SKAction fadeInWithDuration:0.1];
    //SKAction *ou=[SKAction fadeOutWithDuration:0.5];
    // SKAction *th=[SKAction sequence:@[new,ou]];
    [lottery addChild:glow];
    //[lottery setAlpha:0.5f];
    
    SKAction *fade=[SKAction fadeAlphaTo:0.5 duration:0.5];
    SKAction *fadout=[SKAction fadeAlphaTo:1 duration:0.5];
    SKAction *mys=[SKAction sequence:@[fade,fadout]];
    [lottery runAction:[SKAction repeatActionForever:mys]];
    lottery.physicsBody.dynamic=YES;
    lottery.name=@"lottery";
    lottery.zPosition=0;
    lottery.physicsBody.contactTestBitMask = lottery__bitmask;
    lottery.physicsBody.categoryBitMask = blockCategory|bottombody;
    lottery.physicsBody.collisionBitMask = lottery__bitmask;
    lottery.physicsBody.friction=0.0f;
    //lottery.physicsBody.velocity=CGVectorMake(0,-4);
    lottery.physicsBody.usesPreciseCollisionDetection=YES;
    
    
    [self addChild:lottery];
}

-(void)reportscore{
    [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            _leaderboardIdentifier = leaderboardIdentifier;
        }
    }];
    
    NSLog(@"leader%@",_leaderboardIdentifier);
    GKScore *sco = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.critis.highscore"];
    sco.value =score;
    NSLog(@"%llu scoreeee",sco.value);
        [GKScore reportScores:@[sco] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    
//    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
//    leaderboardRequest.identifier=@"catchCrisis";
//    leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
//    leaderboardRequest.timeScope=GKLeaderboardTimeScopeAllTime;
//    if (leaderboardRequest != nil) {
//        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
//            if (error != nil) {
//                //Handle error
//            }
//            else{
//                //[delegate onLocalPlayerScoreReceived:leaderboardRequest.localPlayerScore];
//                GKScore *localPlayerScore = leaderboardRequest.localPlayerScore;
//                
//                NSLog(@"Local player's score: %llu", localPlayerScore.value);
//                NSLog(@"My Score: %@", [scores objectAtIndex:0]);
//                
//                
//                
//            }
//        }];
//    }

}

#pragma mark didMovetoview
-(void)didMoveToView:(SKView *)view {
    
    urlcoinm= [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/coin" ofType:@"mp3"]];
    coinm=[[AVAudioPlayer alloc]initWithContentsOfURL:urlcoinm error:nil];
    
    url_coin_miss= [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/miss" ofType:@"mp3"]];
    coin_miss=[[AVAudioPlayer alloc]initWithContentsOfURL:url_coin_miss error:nil];
    
    //play and repeat forever
    //[self runAction:[SKAction repeatActionForever:soundAction]];
    
    swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector( handleSwipeRight:)];
    [swipeRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    swipeleftgesture=[[UISwipeGestureRecognizer alloc ]initWithTarget:self action:@selector(handleSwipeLeft:)];
    
    [swipeleftgesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view.self addGestureRecognizer:swipeleftgesture];
    [self.view.self addGestureRecognizer: swipeRightGesture ];
    self.physicsWorld.contactDelegate = self;
     self.physicsWorld.gravity = CGVectorMake(0.0f,-2.0f);
    
    //NSLog(@"%@",arrayValues);
     [self initiatevalues];
    
  //  [self changepattern:0 change:1];
    [self skinOfplayer_coins];
    i=0;
    
   
    [self checkAchievement];
    paused_pressed=0;
    
    [self extraheartvalue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makepause)
                                                 name:@"pause" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(theAppIsActive:)
                                                 name:@"appIsActive" object:nil];
    [self catchaction];
}

-(void)catchaction{
    SKSpriteNode *node=[SKSpriteNode spriteNodeWithImageNamed:@"imageresource/quickGame/quick_catch"];
    node.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+node.frame.size.height);
    [self addChild:node];
    SKAction *down;
    
    down=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+node.frame.size.width/2) duration:2];
    [node runAction:down completion:^{
        SKAction *fadeout=[SKAction fadeOutWithDuration:0.3];
        [node runAction:fadeout];
        [node removeFromParent];
        
        [self coinAction:1];
        timercount=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(caltime) userInfo:nil repeats:YES];
        [self changepattern:0 change:1];
        
    }];
    
    
}

-(void)theAppIsActive:(NSNotification *)note {
    
    SKAction *pauseTimer= [SKAction sequence:@[
                                               [SKAction waitForDuration:0],
                                               [SKAction performSelector:@selector(pauseTimerfun)
                                                                onTarget:self]
                                               
                                               ]];
    [self runAction:pauseTimer withKey:@"pauseTimer"];
}

-(void) pauseTimerfun {
     [self makepause];
    [self pauseTimer:timercount];
    [backmusic stop];
    swipe_locked=0;
    self.paused = YES;
   
    
}

-(void)lottery:(int)pos{
    lottery=[SKSpriteNode spriteNodeWithImageNamed:@"imageresource/quickGame/quick_lottery"];
    
    //lottery.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(lottery.frame.size.width, lottery.frame.size.height)];
    lottery.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:lottery.size];
    if(pos==1){
        lottery.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+lottery.size.width));
    }
    else if(pos==2){
        lottery.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+lottery.size.width);
    }
    else{
        lottery.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+lottery.size.width));
    }
    
    SKShapeNode *glow=[[SKShapeNode alloc]init];
    glow=[SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(lottery.frame.size.width+3, lottery.frame.size.height+5)];
    glow.strokeColor = [SKColor yellowColor];
    // glow.fillColor=[SKColor yellowColor];
    glow.glowWidth=2;
    glow.blendMode=SKBlendModeAlpha;
    [lottery addChild:glow];
    
    
    SKAction *fade=[SKAction fadeAlphaTo:0.5 duration:0.5];
    SKAction *fadout=[SKAction fadeAlphaTo:1 duration:0.5];
    SKAction *mys=[SKAction sequence:@[fade,fadout]];
    [lottery runAction:[SKAction repeatActionForever:mys]];
    lottery.physicsBody.dynamic=YES;
    lottery.name=@"lottery";
    lottery.zPosition=0;
    lottery.physicsBody.contactTestBitMask = lottery__bitmask;
    lottery.physicsBody.categoryBitMask = blockCategory|bottombody;
    lottery.physicsBody.collisionBitMask = lottery__bitmask;
    lottery.physicsBody.friction=0.0f;
    // lottery.physicsBody.velocity=CGVectorMake(-2, -2);
    lottery.physicsBody.usesPreciseCollisionDetection=YES;
    
    [lottery runAction:drop_action];

    
    [self addChild:lottery];
}

-(void)skinOfplayer_coins {
    NSLog(@"skinOFplayer");
    skinlist=[[NSString alloc]init];
    skinlist = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    skinlist = [skinlist stringByAppendingPathComponent:@"highscore.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:skinlist]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:skinlist error:nil];
    }
    
    NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:skinlist];
    /*if([shared sharedInstance].flag == 2 && [shared sharedInstance].expiredOneHour) {
        [dit setObject:[NSNumber numberWithInt:0]forKey:@"costumeSelect"];
        [dit writeToFile:hlist atomically:YES];
    }*/

    //costumeSelect
    //backactive
    //fallingobject
    
    NSNumber *co_select=[dit objectForKey:@"costumeSelect"];
    
    if([co_select intValue]==0){
        [self changeskin:@"imageresource/quickGame/quick_warrior2" flag:0];
    }
    else{
        [self changeskin:@"imageresource/quickGame/quick_monkey2" flag:5];
    }
    co_select=[dit objectForKey:@"falingobject"];
   
    if([co_select intValue]==0){
        [self changeskin:@"imageresource/quickGame/quick_goodCoin1" flag:1];
        
    }
    else{
        [self changeskin:@"imageresource/quickGame/quick_goodBanana" flag:3];
    }
    
    co_select=[dit objectForKey:@"backactive"];
    [self backmusic:[co_select intValue]];
    
    if([co_select intValue]==0){
        [self changeskin:@"imageresource/quickGame/quick_backgroundOriginal" flag:2];
    }
    else if ([co_select intValue]==1){
          [self changeskin:@"imageresource/quickGame/quick_background" flag:2];
        
    }
    else if ([co_select intValue]==2){
         [self changeskin:@"imageresource/quickGame/quick_backgroundDessert" flag:2];
    }
    else if ([co_select intValue]==3){
        [self changeskin:@"imageresource/quickGame/quick_backgroundIce" flag:2];
        
    }
    else{
         [self changeskin:@"imageresource/quickGame/quick_backgroundOriginal" flag:2];
    }
    
    
    
    
}

-(void)changeskin:(NSString *)texture flag:(int)flag{
    
     NSString *temp;
    if(flag==0){
        temp=[self textureAtlasNamed:texture];
        playertexture=[NSString stringWithString:temp];
        mtexture=[NSString stringWithString:temp];
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_warrior3"];
        rtexture=[NSString stringWithString:temp];
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_warrior1"];
        ltexture=[NSString stringWithString:temp];
        monkey=0;
        
    }
    else if (flag==5){
        
        temp=[self textureAtlasNamed:texture];
        playertexture=[NSString stringWithString:temp];
        mtexture=[NSString stringWithString:temp];
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_monkey3"];
        rtexture=[NSString stringWithString:temp];
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_monkey1"];
        ltexture=[NSString stringWithString:temp];
        monkey=1;
    }
    
    else if(flag==2){
        temp=[self textureAtlasNamed:texture];
        [sprite setTexture:[SKTexture textureWithImageNamed:temp]];
        [self coinrotationspeed:0.055];
        
        
    }
    else if (flag==1){
        temp=[self textureAtlasNamed:texture];
        goodtexture=[NSString stringWithString:temp];
        
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_badCoin1"];
        badtexture=[NSString stringWithString:temp];
    }
    else if (flag==3){
        NSLog(@"banana skin");
       temp=[self textureAtlasNamed:texture];
        goodtexture=[NSString stringWithString:temp];
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_badBanana"];
        badtexture=[NSString stringWithString:temp];
        banana=1;
        NSLog(@"adasda%d",banana);
    }
    
   
    else{
        //no change
    }
    
    
    NSString *scorelive;
    if(banana==1){
        scorelive=[NSString stringWithString:[self textureAtlasNamed:@"quick_scoreBoxmonkey"]];
    }
    else{
        scorelive=[NSString stringWithString:[self textureAtlasNamed:@"imageresource/quickGame/quick_scoreBox"]];
    }
    
}

-(void)backmusic:(int)backactive{
    NSArray *music;
    if(monkey==0){
        music=[[NSArray alloc]initWithObjects:@"The_Chase_Original",@"The-Rose",@"BombsAwayStream",@"SandyCove_", nil];}
    else{
        music=[[NSArray alloc]initWithObjects:@"Field-Music",@"The-Rose",@"BombsAwayStream",@"Dr.-Panda-Trailer-score-2", nil];
    }
    NSString *tempmusic=[NSString stringWithFormat:@"gameMusic/"];
    if (backactive<0 || backactive>3) {
        backactive = 0;
    }
    
    tempmusic=[tempmusic stringByAppendingString:[music objectAtIndex:backactive]];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:tempmusic ofType:@"mp3"]];
    backmusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [backmusic setNumberOfLoops:-1];
    [backmusic play];
}

-(void)calmaxcombo{
    /*if(catch_7_coins>7){
        catch_7_coins=catch_7_coins*1.337;
        score=score+catch_7_coins;
    }
    
    catch_7_coins=0;*/
}

-(void)calcombopoints:(int)v{
    if(v==1){
        if(a_combo>7){
            a_combo=a_combo*1.275;
            if(miss_count>negative_count){
                int temp=miss*miss_count;
                a_combo=a_combo-temp;
                score=score+a_combo;
            }
            else{
                int temp=negative*negative_count;
                a_combo=a_combo-temp;
                score=score+a_combo;
            }
        }
        a_combo=0;
        [self calmaxcombo];
        
    }
    else if (v==2){
        if(p_combo>7){
            p_combo=p_combo*1.45;
            if(miss_count>negative_count){
                int temp=miss*miss_count;
                p_combo=p_combo-temp;
                score=score+p_combo;
            }
            else{
                int temp=negative*negative_count;
             p_combo=p_combo-temp;
                score=score+p_combo;
            }
        
        }
        p_combo=0;
        [self calmaxcombo];
        
        
    }
    else{
        
        if(g_combo>7){
            g_combo=g_combo*1.00;
            if(miss_count>negative_count){
                int temp=miss*miss_count;
                g_combo=g_combo-temp;
                score=score+a_combo;
            }
            else{
                int temp=negative*negative_count;
                g_combo=g_combo-temp;
                score=score+g_combo;
            }
        }
        
            g_combo=0;
        [self calmaxcombo];
        

        
    }
    
}

-(void)combo:(int)p_pos second:(int)r_pos{
    if(r_pos>0){
        if (r_pos==1) {
            [self calcombopoints:1];
        }
        else if(r_pos==2){
            [self calcombopoints:2];
        }
        else{
            [self calcombopoints:3];
        }
        
    }
    else{
        if(p_pos==1){
            [self calcombopoints:3];
        }
        else if (p_pos==2){
         [self calcombopoints:1];
        }
        else{
            [self calcombopoints:2];
        }
        
    }
    
    
}

-(void)changepattern:(int)blackhit change:(int)change{
    NSArray *arrayList;
    int temp;
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"patterns2" ofType:@"plist"]];
    NSLog(@"%dtime count",timecount);
  
    if (count_good_coin==0) {
        self.physicsWorld.gravity=CGVectorMake(0.0f,-0.0f);
        [self changetime:0.6 gravity:-6.0f dropspeed:0.5f];
        [self coinrotationspeed:0.055];
    }
    
    if(change==1 || indexl==0 ){
        NSString *num = [NSString stringWithFormat:@"%d", patterncategory];
        arrayList = [NSArray arrayWithArray:[dictRoot objectForKey:num]];
        temp=(int)[arrayList count];
        int patternnumber=arc4random_uniform(temp);
        
        NSString *pattern=[arrayList objectAtIndex:patternnumber];
        items = [pattern componentsSeparatedByString:@","];
        NSLog(@"%d pattern category",patterncategory);
        NSLog(@"%d pattern number",patternnumber);
    }
}

-(void)changetime:(float)timecc gravity:(float)g dropspeed:(float)speed{
  
    gravity=g;
    timec=timecc;
    [self removeCoinAction];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(make) userInfo:nil repeats:NO];
    NSLog(@"time%f",timecc);
    
    if (speed>1.0f) speed = 1.0f;
    drop_speed = speed;
    [self coinAction:0.35/drop_speed];
    self.physicsWorld.gravity = CGVectorMake(0.0f,0.0f);
    drop_action = [SKAction moveToY:-200.0f duration:1/drop_speed];
    
}

-(void)make{
    
}

-(void)coinrotationspeed:(float)speed{
    
    g_coin_anim = [SKAction animateWithTextures:SPRITES_ANIM_CAPGUY_WALK timePerFrame:speed];
    b_coin_anim=[SKAction animateWithTextures:bad_coin timePerFrame:speed];
}

-(void)gradually{
    gravity=gravity-1.0f;
    NSLog(@"%fgravity",gravity);
    self.physicsWorld.gravity=CGVectorMake(0.0f, 0.0f);
    
}

-(void)handleSwipeLeft:( UISwipeGestureRecognizer *) recognizer {
    

    if(swipe_locked==1){
        
            // SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
            
            if(i==0){
                
                SKTexture *playerTexture= [SKTexture textureWithImageNamed:ltexture];
                [player setTexture: playerTexture];
                player.position=CGPointMake(player.position.x-player.size.width/1.6,player.position.y);
                i=1;
                player_pos=2;
                swipe++;
            }
            
            else if(i==2){
                
                SKTexture *playerTexture= [SKTexture textureWithImageNamed:mtexture];
                [player setTexture: playerTexture];
                player.position=CGPointMake(player.position.x-player.size.width/1.6,player.position.y);
                i=0;
                player_pos=0;
                swipe++;
                
            }
        
    }
    
    
    
}

-(void)handleSwipeRight:( UISwipeGestureRecognizer *) recognizer {
    
    if (swipe_locked==1) {
        
            if (i==0) {
                
                SKTexture *playerTexture= [SKTexture textureWithImageNamed:rtexture];
                [player setTexture: playerTexture];
                player.position=CGPointMake(player.position.x+player.size.width/1.6,player.position.y);
                i=2;
                player_pos=1;
                swipe++;
                
            }
            else if(i==1){
                
                SKTexture *playerTexture= [SKTexture textureWithImageNamed:mtexture];
                [player setTexture: playerTexture];
                player.position=CGPointMake(player.position.x+player.size.width/1.6,player.position.y);
                i=0;
                player_pos=0;
                swipe++;
            }
            
            
        
    }
    
}

-(void)makepause{
    NSLog(@"pausepress%d",paused_pressed);
    if(paused_pressed==0){
        paused_pressed=1;
        NSLog(@"123make psuse");
       
    pausenode=[LHNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/pause/pause_blackBackground"]];
    pausenode.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    pausenode.zPosition=1;
    pausenode.name=@"pause";
        
    node=[LHNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/pause/pause_pauseText" ]];
    node.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    node.zPosition=3;
   
    p_home=[LHNode spriteNodeWithImageNamed:@"imageresource/pause/pause_home"];
    p_home.zPosition=1;
    p_home.position=CGPointMake(CGRectGetMinX(self.frame)-self.frame.size.width/3-30, CGRectGetMinY(self.frame)-p_home.size.height*2+22);
    p_home.zPosition=5;
    p_home.name=@"phome";
    
    p_replay=[LHNode spriteNodeWithImageNamed:@"imageresource/pause/pause_retry"];
    p_replay.position=p_resume.position=CGPointMake(CGRectGetMinX(self.frame)-self.frame.size.width/3+p_replay.size.width-30, CGRectGetMinY(self.frame)-p_replay.size.height-p_replay.size.height/2-6);
    p_replay.zPosition=5;
    p_replay.name=@"preplay";
    p_resume=[LHNode spriteNodeWithImageNamed:@"imageresource/pause/pause_play"];
    p_resume.position=CGPointMake(CGRectGetMinX(self.frame)-self.frame.size.width/3+p_replay.size.width+p_replay.size.width-30, CGRectGetMinY(self.frame)-p_home.size.height-p_resume.size.height/2+16);
    p_resume.zPosition=5;
    p_resume.name=@"presume";
    [node addChild:p_resume];
    [node addChild:p_replay];
    [node addChild:p_home];
    [self addChild:node];
    [self addChild:pausenode];
        
        
    /////////////////////////////   Added in 2015.9.17   ///////////////////////////////////////////////
        
        CGPoint firstPosition = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
        CGPoint targetPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        SKAction *action1 = [SKAction moveTo:firstPosition duration:0.01];
        SKAction *action2 = [SKAction moveTo:targetPosition duration:0.2];
        SKAction *action  = [SKAction sequence:@[action1, action2]];
        self.paused= NO;
        
        [node runAction:action completion:^{
            
            self.paused= YES;
            [buttonpressed play];
            [backmusic stop];
            swipe_locked=0;
            [self pauseTimer:timercount];
            adstimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(adds) userInfo:nil repeats:NO];
            
        }];
        
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    }

    
    
}

-(void)coins{
    
    
    flag=[(NSNumber *)[items objectAtIndex:indexl] intValue];
    int a=(int)flag;
    
    if(lottery_time==60){
    
        [self lottery:a];
        a = 0;
        lottery_time = 0;
        
    }else{
    
        lottery_time++;
    }

    
    //ring2
    if(a==0){
    }
    else if(a==2){
        //ring=[ring init];
        [self badcoin:a];
        ring=[SKSpriteNode spriteNodeWithImageNamed:goodtexture];
        ring.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ring.size.height / 2];
        ring.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+ring.size.width);
        ring.physicsBody.dynamic=YES;
        ring.name=@"ring";
        ring.physicsBody.categoryBitMask = blockCategory|bottombody;
        ring.physicsBody.collisionBitMask = playerCategory;
        ring.physicsBody.contactTestBitMask = playerCategory;
        ring.physicsBody.friction=0.0f;
       
        ring.zPosition=0;
        if(banana!=1){
        [ring runAction:[SKAction repeatActionForever:g_coin_anim]];
        }
        
        [ring runAction:drop_action];
        [self addChild:ring];
    }
    //ring3
    else if(a==3){
        [self badcoin:a];
        ring1=[SKSpriteNode spriteNodeWithImageNamed:goodtexture];
        ring1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ring1.size.height / 2];
        ring1.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+ring1.size.width));
        ring1.physicsBody.dynamic=YES;
        ring1.name=@"ring1";
        ring1.physicsBody.categoryBitMask = blockCategory|bottombody;
        ring1.physicsBody.collisionBitMask = playerCategory;
        ring1.physicsBody.contactTestBitMask = playerCategory;
        ring1.physicsBody.friction=0.0f;
        
        ring1.zPosition=1;
        
        if(banana!=1){
        [ring1 runAction:[SKAction repeatActionForever:g_coin_anim]];
        }
        
        [ring1 runAction:drop_action];
        [self addChild:ring1];
    }
    //ring1
    else if(a==1){
        [self badcoin:a];
        ring2=[SKSpriteNode spriteNodeWithImageNamed:goodtexture];
        ring2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ring2.size.height / 2];
        ring2.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+ring2.size.width));
        ring2.physicsBody.dynamic=YES;
        ring2.name=@"ring2";
        ring2.physicsBody.categoryBitMask = blockCategory|bottombody;
        ring2.physicsBody.collisionBitMask = playerCategory;
        ring2.physicsBody.contactTestBitMask = playerCategory;
        ring2.physicsBody.friction=0.0f;
        ring2.zPosition=1;
        if(banana!=1){
        [ring2 runAction:[SKAction repeatActionForever:g_coin_anim]];
        }
        [ring2 runAction:drop_action];
        [self addChild:ring2];
    }
    else{
        [self badcoin:a];
        ring2=[SKSpriteNode spriteNodeWithImageNamed:goodtexture];
        ring2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ring2.size.height / 2];
        ring2.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+ring2.size.width));
        ring2.physicsBody.dynamic=YES;
        ring2.name=@"ring2";
        ring2.physicsBody.categoryBitMask = blockCategory|bottombody;
        ring2.physicsBody.collisionBitMask = playerCategory;
        ring2.physicsBody.contactTestBitMask = playerCategory;
        ring2.physicsBody.friction=0.0f;
        ring2.zPosition=1;
        if(banana!=1){
            [ring2 runAction:[SKAction repeatActionForever:g_coin_anim]];
        }
        [ring2 runAction:drop_action];
        [self addChild:ring2];

    }
    
    if(indexl<[items count]-1){
        indexl++;}
    else{
        indexl=0;
        [self changepattern:0 change:1];
    }
    
    //lotery
    if(lottery_catched==1){
        if (lottery_count<15) {
            lottery_count++;
            
            if (imidiate_bad_coin==0) {
              
                if(lottery_count==14){
                    if (imidiate_good_coin_miss==0) {
                        lottery_goodcoins_count=lottery_goodcoins_count*1;
                        lottery_goodcoins_count=lottery_goodcoins_count*2;
                        score=score+lottery_goodcoins_count;
                        NSLog(@"2x points");
                    }
                    else{
                        NSLog(@"not earned 2x points");
                    }
                }
            }
            else{
            /*  NSLog(@"game finished");
                self.paused=YES;
                swipe_locked=0;
              
                [self callendscreen];*/
            }
            
            int rnd = rand()%2;
            if (rnd==0){
                [self changeskin:@"imageresource/quickGame/quick_goodCoin1" flag:1];
                banana = 0;
            }else {
                [self changeskin:@"imageresource/quickGame/quick_goodBanana" flag:3];
            }
            
            if(lotteryTimer==nil){
            
                lotteryTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(lotteryAction) userInfo:nil repeats:YES];
            }
            
        }
        else{
            
            [lotteryTimer invalidate];
            lotteryTimer = nil;
            
            lottery_count=0;
            lottery_catched=0;
            imidiate_bad_coin=0;
            imidiate_good_coin_miss=0;
            lottery_goodcoins_count=0;
            
            NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:skinlist];
            NSNumber *select=[dit objectForKey:@"falingobject"];
            if([select intValue]==0){
                [self changeskin:@"imageresource/quickGame/quick_goodCoin1" flag:1];
                banana=0;
            }else{
                [self changeskin:@"imageresource/quickGame/quick_goodBanana" flag:3];
            }
        }
    }
    
    
    
    if(coin_miss.currentTime>9){
        //[coin_miss pause];
        [self doVolumeFade];
        [backmusic play];
    }
    
    if(lifes==0){
        
        if(lotteryTimer!=nil)
        {
            [lotteryTimer invalidate];
            lotteryTimer = nil;
        }
        
        lottery_count=0;
        lottery_catched=0;
        imidiate_bad_coin=0;
        imidiate_good_coin_miss=0;
        lottery_goodcoins_count=0;
        
        NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:skinlist];
        NSNumber *select=[dit objectForKey:@"falingobject"];
        if([select intValue]==0){
            [self changeskin:@"imageresource/quickGame/quick_goodCoin1" flag:1];
            banana=0;
        }else{
            [self changeskin:@"imageresource/quickGame/quick_goodBanana" flag:3];
        }
        
        self.paused=YES;
        swipe_locked=0;
        NSLog(@"lifes%d",lifes);
        [self callendscreen];
        [coin_miss pause];
        loseCount++;
        //lifes=3;

    }
    
    [self achievement];
    
}

-(void)lotteryAction{

    if(monkey==0){
        warriorhit=[SKAction animateWithTextures:warrior_hit timePerFrame:0.03];
    }
    else{
        warriorhit=[SKAction animateWithTextures:monkey_hit_middle timePerFrame:0.03];
    }
    
    if(player_pos==0) [player runAction:warriorhit];
    [self setplayertexture];
    
}

-(void)doVolumeFade {
    if (coin_miss.volume > 0.1) {
        coin_miss.volume = coin_miss.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    }
    else{
        [coin_miss pause];
    }
}

-(void)callendscreen{
    if([shared sharedInstance].screen_capturing) [self stopScreenRecording];
    
     if(high_score <score){
        high_score=score;
        [self updateachievement:40];
    }
    else if(high_score == score){
        [self updateachievement:43];
    }
    else{
        [self updateachievement:42];
    }
   NSString *list = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    list = [list stringByAppendingPathComponent:@"highscore.plist"];
    NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:list];
   NSNumber *temp= [dit objectForKey:@"coins"];
   long t=(long)[temp longLongValue];
    t=t+count_good_coin;
    
    [dit setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
    [dit writeToFile: list atomically:YES];

    [backmusic stop];

    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
    [coin_miss pause];
    [self removetimer];
    [self updateheartsvalue];
    [self achievement];
    [self reportscore];
    [shared sharedInstance].score=count_good_coin;//score;
    SKView * skView = (SKView *)self.view;
    
    SKScene * scene;
    
    scene = [endsecreen scene] ;
    
    // Present the scene.
    [skView presentScene:scene];
}

-(void)badcoin:(int) g{
    bring1=[SKSpriteNode spriteNodeWithImageNamed:badtexture];
    bring2=[SKSpriteNode spriteNodeWithImageNamed:badtexture];
    //b_coin_anim=[SKAction animateWithTextures:bad_coin timePerFrame:0.033];
    //bad coin 1
    bring1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bring2.size.height / 2];
    bring1.physicsBody.dynamic=YES;
    bring1.name=@"bring1";
    bring1.physicsBody.friction=0.0f;
    bring1.zPosition=2;
    bring1.physicsBody.categoryBitMask = blockCategory|bottombody;
    bring1.physicsBody.collisionBitMask = playerCategory;
    bring1.physicsBody.contactTestBitMask = playerCategory;
    if(banana!=1){
    [bring1 runAction:[SKAction repeatActionForever:b_coin_anim]];
    }
    [bring1 runAction:drop_action];
    
    //bad coin 2
    bring2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bring2.size.height / 2];
    bring2.physicsBody.dynamic=YES;
    bring2.name=@"bring2";
    bring2.physicsBody.friction=0.0f;
    bring2.zPosition=2;
    bring2.physicsBody.categoryBitMask = blockCategory|bottombody;
    bring2.physicsBody.collisionBitMask = playerCategory;
    bring2.physicsBody.contactTestBitMask = playerCategory;
    if(banana!=1){
    [bring2 runAction:[SKAction repeatActionForever:b_coin_anim]];
    }
    [bring2 runAction:drop_action];
    
     if(g==1){
        
        int b_occur=arc4random_uniform(3);
        if(b_occur==0){
            //no black coin
         }
        else if(b_occur==1){
            int which_one=arc4random_uniform(2);
            //one black coin but which one
            if(which_one==1){
                bring1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+bring1.size.width);//2ndplace
                [self addChild:bring1];
             }
            else{
                    bring2.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring1.size.width));//3rdplace
                    [self addChild:bring2];
            }
            
        }
        else{
               //both black coin
                bring1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+bring1.size.width);//2nplace
                [self addChild:bring1];
                bring2.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring1.size.width));//3rdplace
                [self addChild:bring2];
        }
    }
    else if(g==2){
        
        int b_occur=arc4random_uniform(3);
        if(b_occur==0){
            //no black coin
        }
        else if(b_occur==1){
            int which_one=arc4random_uniform(2);
            //one black coin but which one
            if(which_one==1){
                    bring1.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring2.size.width));//1stplace
                    [self addChild:bring1];
            }
            else{
                    bring2.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring2.size.width));//3rdplace
                    [self addChild:bring2];
            }
            
        }
        else{
                bring1.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring2.size.width));//1stplace
                [self addChild:bring1];
                bring2.position = CGPointMake(CGRectGetMidX(self.frame)+(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring2.size.width));//3rdplace
                [self addChild:bring2];
        }
        
    }
    else{
        
        int b_occur=arc4random_uniform(3);
        if(b_occur==0){
            //no black coin
        }
        else if(b_occur==1){
            int which_one=arc4random_uniform(2);
            //one black coin but which one
            if(which_one==1){
                bring1.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring2.size.width));//1stplace
                [self addChild:bring1];
            }
            else{
                bring2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+bring2.size.width);//2ndplace
                [self addChild:bring2];
            }
            
        }
        
        
        else{
                bring1.position = CGPointMake(CGRectGetMidX(self.frame)-(self.frame.size.width/3), (CGRectGetMaxY(self.frame)+bring1.size.width));//1stplace
                [self addChild:bring1];
                bring2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+bring2.size.width);//2ndplace
                [self addChild:bring2];
        }
    }
  
}

-(void)badcoin_anim{
    //midle warrior hit
    if(player_pos==0){
        if(lottery_catched==1) return;
        if(monkey==0){
        warriorhit=[SKAction animateWithTextures:warrior_hit timePerFrame:0.03];
        }
        else{
         warriorhit=[SKAction animateWithTextures:monkey_hit_middle timePerFrame:0.03];
        }
        
        [player runAction:warriorhit completion:^{
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setplayertexture) userInfo:nil repeats:NO];
        
            
        }];
        
    }
    //right_warrior_hit
    else if(player_pos==1){
        if(monkey==0){
        warriorhit=[SKAction animateWithTextures:warrior_hit_right timePerFrame:0.03];
        }
        else{
         warriorhit=[SKAction animateWithTextures:monkey_hit_right timePerFrame:0.03];
        }
        
        [player runAction:warriorhit completion:^{
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setplayertexture) userInfo:nil repeats:NO];
        }];
    }
    //left warrior hit
    else{
         if(monkey==0){
        warriorhit=[SKAction animateWithTextures:warrior_hit_left timePerFrame:0.03];
         }
         else{
           warriorhit=[SKAction animateWithTextures:monkey_hit_left timePerFrame:0.03];
         }
      
        [player runAction:warriorhit completion:^{
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setplayertexture) userInfo:nil repeats:NO];
            
        }];
    }
   
    
}

-(void)setplayertexture{
    NSLog(@"player pos %d",player_pos);
    if(player_pos==0){
        [player setTexture:[SKTexture textureWithImageNamed:mtexture]];
        
    }
    else if (player_pos==1){
      [player setTexture:[SKTexture textureWithImageNamed:rtexture]];
    }
    else{
        [player setTexture:[SKTexture textureWithImageNamed:ltexture]];
    }
    
}

-(void)decrementheart{
    catch_7_coins = 0;
    if(heart2_life>0){
        heart2_life--;
        [self changeheart:heart2 life:heart2_life];
        
    }
    else if(heart1_life>0){
        heart1_life--;
        [self changeheart:heart1 life:heart1_life];
    }
    else{
        if(lifes!=0){
        lifes--;
        }
        [self changeheart:hearts life:lifes];
    }
    
    
}

-(void)updateheartsvalue{
    [self connection];
     NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:hlist];
    
    
    [tdict setObject:[NSNumber numberWithInt:heart1_life]forKey:@"heart1life"];
    [tdict writeToFile:hlist atomically:YES];
    
    [tdict setObject:[NSNumber numberWithInt:heart2_life]forKey:@"heart2life"];
    [tdict writeToFile:hlist atomically:YES];

    
    
}

-(void)connection{
    
    hlist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    hlist= [hlist stringByAppendingPathComponent:@"highscore.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:hlist]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:hlist error:nil];
    }
}

-(void)extraheartvalue{
    [heart1 setTexture:[SKTexture textureWithImageNamed:[shared sharedInstance].heart1tex]];
    [heart2 setTexture:[SKTexture textureWithImageNamed:[shared sharedInstance].heart2tex]];;
    heart1_life=[shared sharedInstance].heart1life;
    heart2_life=[shared sharedInstance].heart2life;
}

-(void)coinmissmusic{
    SKAction *soundAction = [SKAction playSoundFileNamed:@"gameMusic/miss.mp3" waitForCompletion:NO];
    [self runAction:soundAction];
}

-(void)pauseTimer:(NSTimer *)timer {

    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0] ;
    
    previousFireDate = [timer fireDate];
    
    [timer setFireDate:[NSDate distantFuture]];
    
}

-(void)resumeTimer:(NSTimer *)timer {
    
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
}

#pragma mark Did began contact
-(void)didBeginContact:(SKPhysicsContact *)contact{SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    SKNode *my,*bottom;
    
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        SKNode *one, *two;
        one = contact.bodyA.node;
        two=contact.bodyB.node;
        
        
        if([two.name isEqual:@"ring"] && [one.name isEqual:@"bottom"]){
            [self coinmissmusic];
            if(lottery_catched==1){
                imidiate_good_coin_miss++;
            }
             if(good_coin_100<100){
                good_coin_100=0;
            }
            
           good_coin_miss++;
            [self combo:-1 second:2];
            if(g_combo>7 || a_combo>7 || p_combo>7 ){
                miss_count++;
            }
            [self decrementheart];
        }
        
        if([two.name isEqual:@"ring1"] && [one.name isEqual:@"bottom"]){
            [self coinmissmusic];
            if(lottery_catched==1){
                imidiate_good_coin_miss++;
            }
            if(good_coin_100<100){
                good_coin_100=0;
            }
            good_coin_miss++;
            [self combo:-1 second:3];
            if(g_combo>7 || a_combo>7 || p_combo>7 ){
                miss_count++;
            }
            [self decrementheart];
            
        }
        if([two.name isEqual:@"ring2"] && [one.name isEqual:@"bottom"]){
            [self coinmissmusic];
            if(lottery_catched==1){
                imidiate_good_coin_miss++;
            }
            if(good_coin_100<100){
                good_coin_100=0;
            }
            good_coin_miss++;
            [self combo:-1 second:1];
            if(g_combo>7 || a_combo>7 || p_combo>7 ){
                miss_count++;
            }
            [self decrementheart];
         
        }
        
        if([one.name isEqualToString:@"bottom"] && [two.name isEqualToString:@"lottery"]){
            [self coinmissmusic];
        }
        if([one.name isEqualToString:@"bottom"] && [two.name isEqualToString:@"bring1"]){
           // [self coinmissmusic];
            if(two_bad_coins!=0){
               two_bad_coins--;
            }
        }
        if([one.name isEqualToString:@"bottom"] && [two.name isEqualToString:@"bring2"]){
            //[self coinmissmusic];
            if(two_bad_coins!=0){
               two_bad_coins--;
            }
        }
        
        if(coin_miss.currentTime==10){
            [coin_miss pause];
        }
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        bottom=contact.bodyA.node;
        my=contact.bodyB.node;
        //NSLog(@"1%@",my.name);
        //NSLog(@"2%@",bottom.name);
     
        if([my.name isEqualToString:@"bring1"]&& [bottom.name isEqualToString:@"player"]){
            [self changepattern:1 change:0];
            [self coinmissmusic];
            [self badcoin_anim];
            my.physicsBody=NO;
            SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x, player.position.y)  duration:0.09];
            [basket setTimingMode:SKActionTimingEaseInEaseOut];
            [my runAction:basket];
            [my runAction:basket completion:^{
                
                [my removeFromParent];
            }];
            if (lottery_catched==1) {
                imidiate_bad_coin=1;
            }
            
            [self decrementheart];
            if(score>0){
                score=score-1;}
           
            
            count_bad_coin++;
            if(two_bad_coins<2){
                two_bad_coins++;}
            if(good_coin_100<100){
                good_coin_100=0;
            }
            catch_black++;
            [self combo:player_pos second:0];
            if(g_combo>7 || a_combo>7 || p_combo>7 ){
                negative_count++;
            }
           
        }
        
        if([my.name isEqualToString:@"bring2"]&& [bottom.name isEqualToString:@"player"]){
            [self changepattern:1 change:0];
            [self coinmissmusic];
            [self badcoin_anim];
            my.physicsBody=NO;
            SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x, player.position.y)  duration:0.09];
            [basket setTimingMode:SKActionTimingEaseInEaseOut];
            [my runAction:basket];
            [my runAction:basket completion:^{
  
                [my removeFromParent];
            }];
            if (lottery_catched==1) {
                imidiate_bad_coin=1;
            }
            if(score>0){
                score=score-1;}
            count_bad_coin++;
            [self decrementheart];
            
            if(two_bad_coins<2){
                two_bad_coins++;}
            if(good_coin_100<100){
                good_coin_100=0;
            }
            
            catch_black++;
            [self combo:player_pos second:0];
            if(g_combo>7 || a_combo>7 || p_combo>7 ){
                negative_count++;
            }
           
        }
        
        if([my.name isEqual:@"ring"]  && [bottom.name isEqual:@"player"]){
            my.physicsBody=NO;
            SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x, player.position.y)  duration:0.03];
            [my runAction:basket];
            [my runAction:basket completion:^{
                
                [my removeFromParent];
            }];
           
            [self coincatchmusic];
              [coinm prepareToPlay];
            score=score+1;
           
            p_combo++;
            catch_7_coins++;
            good_coin_100++;
            count_good_coin++;
            if(lottery_catched==1){
                lottery_goodcoins_count++;
            }
            
            if((count_good_coin % 10 == 0) && count_good_coin > 0)
                [self changetime:0.6 gravity:gravity dropspeed:drop_speed*1.1];
            
        }
        if([my.name isEqual:@"ring1"] && [bottom.name isEqual:@"player"] ){
            my.physicsBody=NO;
            SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x-50, player.position.y)  duration:0.09];
            [basket setTimingMode:SKActionTimingEaseInEaseOut];
            [my runAction:basket];
            [my runAction:basket completion:^{
                
                [my removeFromParent];
            }];
            
            [self coincatchmusic];
             [coinm prepareToPlay];
            score=score+1;
            good_coin_100++;
            if(lottery_catched==1){
                lottery_goodcoins_count++;
            }
            count_good_coin++;
            g_combo++;
            catch_7_coins++;
            
            if((count_good_coin % 10 == 0) && count_good_coin > 0)
                [self changetime:0.6 gravity:gravity dropspeed:drop_speed*1.1];
            
            
        }
        if([my.name isEqual:@"ring2"]&& [bottom.name isEqual:@"player"]){
            my.physicsBody=NO;
            SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x+50, player.position.y)  duration:0.03];
            [basket setTimingMode:SKActionTimingEaseInEaseOut];
            [my runAction:basket];
            [my runAction:basket completion:^{
                
                [my removeFromParent];
                
                
            }];
            
            [self coincatchmusic];
            [coinm prepareToPlay];
            
            score= score+1;
            a_combo++;
            catch_7_coins++;
            count_good_coin++;
            good_coin_100++;
            if(lottery_catched==1){
                lottery_goodcoins_count++;
            }
            
            if((count_good_coin % 10 == 0) && count_good_coin > 0)
                [self changetime:0.6 gravity:gravity dropspeed:drop_speed*1.1];
            
        }
  
    }
    
    if([my.name isEqualToString:@"lottery"] && [bottom.name isEqualToString:@"player"]){
        my.physicsBody=NO;
        SKAction *basket = [SKAction moveTo:CGPointMake(player.position.x, player.position.y)  duration:0.01];
        [basket setTimingMode:SKActionTimingEaseInEaseOut];
        [my runAction:basket];
        
        [backmusic stop];
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/Dubbed-Gears-Stream" ofType:@"mp3"]];
        coin_miss = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [coin_miss prepareToPlay];
        
        [coin_miss play];
        
        [self badcoin_anim];
//      [self changetime:0.6 gravity:gravity dropspeed:drop_speed*1.1];
        lottery_catched=1;
        lottery_check=1;
    }
    
    if(score>high_score){
        streak++;
        if(streak==1){
        [self achievementmusic];
        }
    }
    NSString *num = [NSString stringWithFormat:@"%li",count_good_coin];
    livescore.text=num;
    
    NSString* myNewString = [NSString stringWithFormat:@"drop_speed ===== %f", drop_speed];
    NSLog(myNewString);

    if(catch_7_coins>100) {
        catch_7_coins = 0;
        [self achievementmusic];   //  achievement-1
    }
}

-(void)coincatchmusic{
    
    if(banana==1){
    urlcoinm= [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/collectbanana2" ofType:@"mp3"]];
        coinm=[[AVAudioPlayer alloc]initWithContentsOfURL:urlcoinm error:nil];
    
    }else{
    urlcoinm= [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/coin" ofType:@"mp3"]];
      coinm=[[AVAudioPlayer alloc]initWithContentsOfURL:urlcoinm error:nil];
    }
    [coinm prepareToPlay];
    [coinm setNumberOfLoops:0];
    coinm.volume=0.25;
    [coinm play];
  
}

-(void)changeheart:(SKSpriteNode *) heart life:(int)life{
    SKTexture *temp;
    if(life==2){
        temp=[SKTexture textureWithImageNamed:@"heart_life_2"];
        [heart setTexture:temp];
        
    }
    else if(life==1){
        temp=[SKTexture textureWithImageNamed:@"heart_life_3"];
        [heart setTexture:temp];
    }
    else if (life==0){
        [heart removeFromParent];
    }
}

-(void)update {
    //remove any nodes named "yourNode" that make it off screen
    [self enumerateChildNodesWithName:@"ring" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"ring1" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"ring2" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"lottery" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"bring2" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"bring1" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if (node.position.x < 0){
            [node removeFromParent];
        }
    }];
    
    
    
}

#pragma mark TouchBegan
-(void)capture_proc {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version < 9.0f) return;
    
    if([shared sharedInstance].screen_capturing == NO) {
        [self startScreenRecording];
        [capture setTexture:[SKTexture textureWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_replay"]]];
    } else {
        [self stopScreenRecording];
        [capture setTexture:[SKTexture textureWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_record"]]];
    }
}

-(void)startScreenRecording {
    ViewController* viewController = (ViewController*)self.view.window.rootViewController;
    [viewController startScreenRecording];
}

-(void)stopScreenRecording {
    ViewController* viewController = (ViewController*)self.view.window.rootViewController;
    [viewController stopScreenRecording];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(ads_occur) return;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/SFX-4Match" ofType:@"mp3"]];
    buttonpressed = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    CGPoint  currentLocation = [[touches anyObject] locationInNode:self];
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:currentLocation];
    
    if([touchedNode.name isEqual:@"pause"]&& paused_pressed==0){
       [self makepause];    //////////////   Modified in 2015.9.17
    }
    if([touchedNode.name isEqual:@"capture"]) {
        [self capture_proc];
    }
    if([touchedNode.name isEqual:@"presume"]){
        
            [self invalidateadds];
            self.paused = NO;
            swipe_locked=1;
            paused_pressed=0;
            [buttonpressed play];
            [backmusic play];
            [self resumeTimer:timercount];
            [self removenode];
    }
    
    if([touchedNode.name isEqualToString:@"preplay"]){
            [self invalidateadds];
            paused_pressed=0;
            achievements *nextScene = [[achievements alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorwayWithDuration:0.3];
            [self.view presentScene:nextScene transition:doors];
            [buttonpressed play];
            [backmusic play];
            
    }
    
    
    if([touchedNode.name isEqualToString:@"phome"] || [touchedNode.name isEqualToString:@"ehome"]){
        if([shared sharedInstance].screen_capturing) [self stopScreenRecording];
            [buttonpressed play];
            [coin_miss stop];
            paused_pressed=0;
        
            for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
                [self.view removeGestureRecognizer:recognizer];
                [self removetimer];
                [self invalidateadds];
            }
        
            SKView * skView = (SKView *)self.view;
            SKScene * scene;
            scene = [LHSceneSubclass scene] ;
        
            // Present the scene.
            [skView presentScene:scene];
    }
    

 /*   if([touchedNode.name isEqualToString:@"eretry"]){
        [self invalidateadds];
        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition doorwayWithDuration:0.3];
        [self.view presentScene:nextScene transition:doors];
        [buttonpressed play];
    }*/
    
}

-(void)invalidateadds{
    
    if([adstimer isValid]){
        [adstimer invalidate];
        adstimer=nil;
    }
}

-(void)adds {
    if (loseCount<2) return;
    
    NSLog(@"adds");
    if (paused_pressed == 1) {
        [Chartboost showInterstitial:CBLocationPause];
    }
    ads_occur = YES;
    adstimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(inputValue) userInfo:nil repeats:NO];
}

-(void)inputValue{

    ads_occur = NO;
}

-(void)removeend{
    [endscreen removeAllChildren];
    [endscreen removeFromParent];
    [e_facebook removeFromParent];
    [e_twitter removeFromParent];
    [score_onend removeFromParent];
    [highest_score removeFromParent];
}

-(void)removenode{
    [node removeAllChildren];
    [node removeFromParent];
    [pausenode removeAllChildren];
    [pausenode removeFromParent];
    
}

#pragma mark TouchEnded
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 }

-(void)checkAchievement{
    
    [self connection];
    
    // Load the Property List.
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:hlist
                                 ];
    NSNumber *a =[dict objectForKey:@"0"];
    
    high_score=[a longValue];
    NSLog(@"%@",dict);
    NSLog(@"high%li",high_score);
    
}

-(void)achievementmusic{
    SKAction *achievementmusic = [SKAction playSoundFileNamed:@"gameMusic/Streak.mp3" waitForCompletion:YES];
    //play once
    [self runAction:achievementmusic];
    
}

-(void)updateachievement:(int) a{
    
    if(a==40){
        [dict setObject:[NSNumber numberWithLong:score] forKey:@"40"];
        
        
        NSNumber *a=[dict objectForKey:@"42"];
        int b=[a intValue];
        b++;
        [dict setObject:[NSNumber numberWithInt:b] forKey:@"42"];
        [dict writeToFile: destPath atomically:YES];
        
    }
    else if(a==42){
        [dict setObject:[NSNumber numberWithLong:0] forKey:@"42"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"43"];
        [dict writeToFile: destPath atomically:YES];
        
    }
    else if(a==43){
        NSNumber *a=[dict objectForKey:@"43"];
        int b=[a intValue];
        b++;
        [dict setObject:[NSNumber numberWithInt:b] forKey:@"43"];
        
    }
    else{
        [self achievementmusic];
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
        NSString *num = [NSString stringWithFormat:@"%d",a];
        [dict setObject:[NSNumber numberWithInt:1] forKey:num];
        [dict writeToFile:destPath atomically:YES];
    }
    NSLog(@"%@",dict);
    
}

-(void)connectionwithachievement{
    
    destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"achievement.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"achievement " ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    // Load the Property List.
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
}

-(void)achievement{
    [self connectionwithachievement];
  
    NSNumber *a =[dict objectForKey:@"1"];
    int temp=[a intValue];
    
    //1st achivement
    if(temp==0){
        if(count_good_coin >=100){
            [self updateachievement:1];
            [self achievementmusic];
        }
    }
    a =[dict objectForKey:@"2"];
    temp=[a intValue];
    NSLog(@"countgoodcoin%li",count_good_coin);
    if(temp==0){
        //2nd
        if(count_good_coin==50){
            
            [self updateachievement:2];
            [self achievementmusic];

        }
    }
    a =[dict objectForKey:@"3"];
    temp=[a intValue];
    if(temp==0){
        //3rd
        if(count_good_coin>=100 && gamemode==1){
            [self updateachievement:3];
            [self achievementmusic];

        }
    }
    a =[dict objectForKey:@"4"];
    temp=[a intValue];
    if(temp==0){
        //4th
        if(count_bad_coin==0 && timecount==180){
            [self updateachievement:4];
            [self achievementmusic];
        }
    }
    //5th on shop scene
    //6th
    a =[dict objectForKey:@"6"];
    temp=[a intValue];
    if(temp==0){
        int check=0;
        for(int n=1;n<40;n++){
            if([dict objectForKey:[NSNumber numberWithInt:n]]==0){
                check=1;
            }
        }
        if(check==0){
            [self updateachievement:6];
            [self achievementmusic];
        }
    }
    
    //7th
    
    a =[dict objectForKey:@"7"];
    temp=[a intValue];
    
    if(temp==0){
        long temp1;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(temp1<score && lifes==3){
            [self updateachievement:7];
            [self achievementmusic];
        }
    }
    //8th
    
    a =[dict objectForKey:@"8"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(temp1<score && two_bad_coins==2){
            [self updateachievement:8];
             [self achievementmusic];
        }
        
    }
    // 40 score 41 number of games 42 consectutive 43 high score
    
    //9th
    a =[dict objectForKey:@"9"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        int temp2;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        temp2=(int)[dict objectForKey:[NSNumber numberWithInt:41]];
        if(temp1<score && temp2>=6){
            [self updateachievement:9];
             [self achievementmusic];
        }
        
    }
    
    //10
    a =[dict objectForKey:@"10"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        int temp2;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:41]];
        temp2=(int)[dict objectForKey:[NSNumber numberWithInt:42]];
        if(temp1<score && temp2>=2){
            [self updateachievement:10];
             [self achievementmusic];
        }
        
    }
    
    //11
    a =[dict objectForKey:@"11"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        int temp2;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:41]];
        temp2=(int)[dict objectForKey:[NSNumber numberWithInt:42]];
        
        if(temp1<score && temp2>=3){
            [self updateachievement:11];
             [self achievementmusic];
        }
        
    }
    //12
    a =[dict objectForKey:@"12"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        int temp2;
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        temp2=(int)[dict objectForKey:[NSNumber numberWithInt:42]];
        
        if(temp1<score && temp2>=5){
            [self updateachievement:12];
             [self achievementmusic];
        }
        
    }
    //17
    a =[dict objectForKey:@"17"];
    temp=[a intValue];
    if(temp==0){
        if(good_coin_100==100){
            [self updateachievement:17];
             [self achievementmusic];
        }
        
    }
    
    //18
    a =[dict objectForKey:@"18"];
    temp=[a intValue];
    if(temp==0){
        long temp1;
        
        temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(lottery_check==1 && temp1<score){
            [self updateachievement:18];
             [self achievementmusic];
        }
        
    }
    
    //19
    a =[dict objectForKey:@"19"];
    temp=[a intValue];
    if(temp==0){
        if(lottery_check==1){
            [self updateachievement:19];
             [self achievementmusic];
        }
        
    }
    
    //20
    a =[dict objectForKey:@"20"];
    temp=[a intValue];
    if(temp==0){
        int temp2=(int)[dict objectForKey:[NSNumber numberWithInt:42]];
        if(temp2>=5){
            [self updateachievement:20];
             [self achievementmusic];
        }
        
    }
    //21
    a =[dict objectForKey:@"21"];
    temp=[a intValue];
    if(temp==0){
        long temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(good_coin_miss==0 && temp1<score && count_bad_coin==0 ){
            [self updateachievement:21];
             [self achievementmusic];
        }
        
    }
    
    //22
    a =[dict objectForKey:@"22"];
    temp=[a intValue];
    if(temp==0){
        long temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(lifes==1 && temp1<score ){
            [self updateachievement:22];
             [self achievementmusic];
        }
        
    }
    
    //23
    a =[dict objectForKey:@"23"];
    temp=[a intValue];
    if(temp==0){
        
        if(count_bad_coin==1000){
            [self updateachievement:23];
             [self achievementmusic];
        }
        
    }
    
    
    //24
    a =[dict objectForKey:@"24"];
    temp=[a intValue];
    if(temp==0){
        
        if(count_bad_coin==5000){
            [self updateachievement:24];
             [self achievementmusic];
        }
        
    }
    
    
    //25
    a =[dict objectForKey:@"25"];
    temp=[a intValue];
    if(temp==0){
        
        if(count_bad_coin==10000){
            [self updateachievement:25];
             [self achievementmusic];
        }
        
    }
    
    
    //26
    a =[dict objectForKey:@"26"];
    temp=[a intValue];
    if(temp==0){
        
        if(count_bad_coin==15000){
            [self updateachievement:26];
             [self achievementmusic];
        }
        
    }
    
    
    //27
    a =[dict objectForKey:@"27"];
    temp=[a intValue];
    if(temp==0){
        long temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        if(temp1==score){
            [self updateachievement:27];
             [self achievementmusic];
        }
        
    }
    
    //28
    a =[dict objectForKey:@"28"];
    temp=[a intValue];
    if(temp==0){
        long temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        int temp2=(int)[dict objectForKey:[NSNumber numberWithInt:43]];
        if(temp1==score){
            if(temp2==0){
                temp2++;
                //update plist
                [self updateachievement:43];
                 [self achievementmusic];
            }
            if(temp2==1){
                [self updateachievement:28];
                 [self achievementmusic];
            }
            
        }
        
    }
    
    
    //29
    a =[dict objectForKey:@"29"];
    temp=[a intValue];
    if(temp==0){
        if(swipe>=100){
            [self updateachievement:29];
             [self achievementmusic];
        }
    }
    
    //30
    temp=(int)[dict objectForKey:[NSNumber numberWithInt:30]];
    if(temp==0){
        int temp1=(int)[dict objectForKey:[NSNumber numberWithInt:41]];
        if(temp1>50){
            [self updateachievement:30];
             [self achievementmusic];
        }
    }
    
    
    //31
    a =[dict objectForKey:@"31"];
    temp=[a intValue];
    if(temp==0){
        long temp1=(long)[dict objectForKey:[NSNumber numberWithInt:40]];
        int temp2=(int)[dict objectForKey:[NSNumber numberWithInt:41]];
        temp--;
        if(temp1==score && temp2>10  ){
            [self updateachievement:31];
             [self achievementmusic];
        }
    }
    
    //32
    a =[dict objectForKey:@"32"];
    temp=[a intValue];
    if(temp==0){
        
        
        if(score>=1337){
            [self updateachievement:32];
             [self achievementmusic];
        }
    }
    
    //38
    a=[dict objectForKey:@"38"];
    temp=[a intValue];
    if(temp==0){
        if(timercount<30 && lifes==0){
           [self updateachievement:38];
             [self achievementmusic];
        }
    }
}

-(void)removetimer{
    timecount=0;
    if([timercount isValid]){
    [timercount invalidate];
    timercount=nil;
        NSLog(@"remove timer");
    }
}

-(void)willMoveFromView:(SKView *)view{
    timecount=0;
      self.physicsWorld.gravity = CGVectorMake(0.0f,-0.0f);
   // [_speedOfcoins invalidate];
    //_speedOfcoins=nil;
//    [timercount invalidate];
//    timercount=nil;
    
    //[backmusic stop];
    
}

@end
