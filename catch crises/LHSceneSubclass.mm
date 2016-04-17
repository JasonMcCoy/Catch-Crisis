//
//  LHSceneSubclass.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//
#import "LHSceneSubclass.h"
#import "changescene.h"
#import "achievements.h"
#import "AVFoundation/AVFoundation.h"
#import "endsecreen.h"
#import "pause_game.h"
#import "endsecreen.h"
#import "custom cellTableViewCell.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "shared.h"
#import "JADSKScrollingNode.h"
#import "Flurry.h"
#import "MBProgressHUD.h"
#import <sys/utsname.h>
#import "ALIncentivizedInterstitialAd.h"
#import "AppDelegate.h"
#import "LeaderBoardCell.h"

#define _MONKEY_PRODUCT_ID       "com.critis.monkey"
#define _BANANA_PRODUCT_ID      "com.critis.banana"

@implementation LHSceneSubclass

static const CGFloat kScrollingNodeWidth = 360;
static const CGFloat kScrollingNodeHeight = 250;
SKAction *soundAction;
AVAudioPlayer *bplay,*buttonpressed;
#define YOUR_APP_STORE_ID 1059354759 //Change this one to your ID
SKSpriteNode *listof_items,*node1,*rectNode,*temp,*left,*playericon,*abutton,* scrollbutton,*heart1,*heart2,*quicklifebox,*arrow,*text,*two;
CGPoint  currentlc,twodefault,thriddefault,rightdefault,leftdefault,mypos,shopcurrent,shopmoveloc,textpos,arrowpos;;
SKNode *my,*third,*right,*mydef,*currentnode,*globale;
SKView *twoview;
int flag_i=0,locked=0,outerlock=0,animatelock=0,u=0;
int screen_identifier=0,firstmove=0,secondmove=0,achtext=2;
CGPoint currentLocation,instantlocation;
UISwipeGestureRecognizer *swipeup, *siwpedown,*swiperight,*swipeleft;
NSTimeInterval startTime;
NSString *highscorelist,*selection,*arrowstring=@"",*textstring=@"";
long actualPlayerLevel=1,coin=0;
int table_for=0;
int table=0,fmove=-1,add=0,shop=0,checkid=0, preindex=0,heartnum=0,heartli=0,myindex=0,backindex=0,bactiveindex=0;
NSDate *pauseStart, *previousFireDate;
int old=0,shopbuttonscroll=0;
float maxshopButtonpos=0.0,minshopButtonpos=0.0,dragvalue=-325;
bool customswipe=YES,mybool=YES;
bool checkScroll = YES;
NSMutableArray *gmarray;

//////////  Added in 2015.9.24  /////////////////////////////////

long initCoins = 0;
bool drag_on = NO;
bool swipe_enable = YES;
bool init_3d = YES;
NSTimer* videoTimer;
CGPoint text_up, arrow_up, text_down, arrow_down, text_left, arrow_left, text_right, arrow_right;

/////////////////////////////////////////////////////////////////
+(id)scene
{
    [shared sharedInstance].mainScene=[[self alloc] initWithContentOfFile:@"final/my.lhplist"];
    return [shared sharedInstance].mainScene;
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile
{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        [self maketable];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _pointsarray=[[NSMutableArray alloc]init];
        _check=[[NSMutableArray alloc]init];
        
        for(int r=0;r<5;r++){
            
            [_check addObject:[NSNumber numberWithInt:0]];
            [_pointsarray addObject:[NSNumber numberWithLong:0]];
        }
        
        [self checkinitialize];
        _nodesitems=[[NSMutableArray alloc]init];
        globale=[[SKSpriteNode alloc]init];
        //[self scroolnode];
        third=[self childNodeWithName:@"shop_background"];
        //   NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage.png"];
        //third=[SKSpriteNode spriteNodeWithImageNamed:imagePath];
        arrowstring=@"";
        textstring=@"";
        arrow=(SKSpriteNode*)[self childNodeWithName:arrowstring];
        text=(SKSpriteNode*)[self childNodeWithName:textstring];
        my=[self childNodeWithName:@"menu_background"];
        two=(SKSpriteNode *)[self childNodeWithName:@"achievements_background"];
        left=(SKSpriteNode *)[self childNodeWithName:@"quick_backgroundOriginal1"];
        right=[self childNodeWithName:@"quick_backgroundOriginal"];
        playericon=(SKSpriteNode *)[self childNodeWithName:@"quick_warrior2"];
        twodefault=two.position;
        thriddefault=third.position;
        leftdefault=left.position;
        rightdefault=right.position;
        mypos=my.position;
        [self changeskin];
        [self firstonmenuscreen:0];
        
        text_up = [[self childNodeWithName:@"menu_button2"] position];
        arrow_up = [[self childNodeWithName:@"menu_achievements"] position];
        text_down = [[self childNodeWithName:@"menu_button4"] position];
        arrow_down = [[self childNodeWithName:@"menu_shop"] position];
        text_left = [[self childNodeWithName:@"menu_button1"] position];
        arrow_left = [[self childNodeWithName:@"menu_quickPlay"] position];
        text_right = [[self childNodeWithName:@"menu_button3"] position];
        arrow_right = [[self childNodeWithName:@"menu_storyMode"] position];
    }
    
    return self;
}

-(void)rewardedvideo {
    
    NSLog(@"rewarded video");
    [shared sharedInstance].rewardVideoAlerted = YES;
//    [Chartboost showRewardedVideo:CBLocationMainMenu];
    if([ALIncentivizedInterstitialAd isReadyForDisplay]){
//        [ALIncentivizedInterstitialAd showAndNotify: (AppDelegate*)[UIApplication sharedApplication].delegate];
        [self performSelector:@selector(showALvideoAfterDelay) withObject:nil afterDelay:1.0];
    }
    else{
        NSLog(@"No rewarded ad is currently available");
        // No rewarded ad is currently available.  Perform failover logic...
    }
}

-(void)showALvideoAfterDelay{

    NSLog(@"Showing rewarded ad");
    [bplay pause];
//    [ALIncentivizedInterstitialAd show];
    
    // Show call if using a reward delegate.
    [ALIncentivizedInterstitialAd showAndNotify: (AppDelegate*)[UIApplication sharedApplication].delegate];
}

-(void)playMusic {
    
    if(currentnode==left) return;
    NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
    NSNumber *temp1 = [dit objectForKey:@"review"];
    int flg_review = [temp1 intValue];
    
    if ([Chartboost isAnyViewVisible]) {
        if (bplay.playing) [bplay stop];
        if (flg_review!=1) {
            
            NSNumber *temp= [dit objectForKey:@"coins"];
            long t=(long)[temp longLongValue];
            t=t+738;
            [dit setObject:[NSNumber numberWithInt:1] forKey:@"review"];
            [dit setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
            [dit writeToFile: highscorelist atomically:YES];
            [self showcoins];
            
        }
    }else {
        if((!bplay.playing) && (flg_review==1)){
            [bplay play];
            [videoTimer invalidate];
            videoTimer = nil;
        }
    }
}

-(void)movetoachievement
{
    [self showAchievements];
//            table=1;
//    [self dragaction:1 firstnode:two srcondnode:my move:0 defaultpos:mypos];
//            screen_identifier=2;
//            currentnode=two;
//            [_tableView reloadData];
//    textstring=[NSString stringWithFormat:@"menu_achievements"];
//    arrowstring=[NSString stringWithFormat:@"menu_button2"];
}

-(void)movetostorymode
{
    [self dragaction:1 firstnode:right srcondnode:my move:1 defaultpos:mypos];
    screen_identifier=4;
    
    textstring=[NSString stringWithFormat:@"menu_storyMode"];
    arrowstring=[NSString stringWithFormat:@"menu_button3"];
}

-(void)movetogameplay {
    SKAction *moveright=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
    [left runAction:moveright];
    float temp=CGRectGetMaxX(self.frame);
    SKAction *o=[SKAction moveToX:temp+(temp/2)+1 duration:0.5];
    
    drag_on = YES;
    [my runAction:o completion:^{
        my.position=mypos;
        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition fadeWithDuration:0.01];
        [self.view presentScene:nextScene transition:doors];
        drag_on = NO;
    }
     ];
    screen_identifier=3;
    
    textstring=[NSString stringWithFormat:@"menu_quickPlay"];
    arrowstring=[NSString stringWithFormat:@"menu_button1"];
}

-(void)movetoshop {
    [self dragaction:0 firstnode:third srcondnode:my move:0 defaultpos:mypos];
    screen_identifier=1;
    
    textstring=[NSString stringWithFormat:@"menu_shop"];
    arrowstring=[NSString stringWithFormat:@"menu_button4"];
    
    if([shared sharedInstance].flag == 1) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Get a Free Monkey Costume!"
                                                          message:@"Monkey Costume Unlocked!"
                                                         delegate:self
                                                cancelButtonTitle:@"Got it Thanks!"                                                otherButtonTitles:nil];
        [message show];   //Modified in 2015.9.19
        
    }
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/menu-music-loop-sample" ofType:@"mp3"]];
    bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bplay setNumberOfLoops:-1];
    [bplay prepareToPlay];
    [bplay play];
}

-(void)checkinitialize {
    for(int r=0;r<5;r++) {
        [_check replaceObjectAtIndex:r withObject:[NSNumber numberWithInt:0]];
    }
}

#pragma mark Did move to view
-(void)didMoveToView:(SKView *)view
{
    
    [[LStoreManagerIOS sharedInstance] setDelegate:self];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/Brahmsters-Inc.-Stream" ofType:@"mp3"]];
    bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bplay setNumberOfLoops:-1];
    [bplay prepareToPlay];
    [bplay play];
    
    my.position=mypos;
    two.position=twodefault;
    third.position=thriddefault;
    right.position=rightdefault;
    left.position=leftdefault;
    screen_identifier=0;
    firstmove=-1;
    flag_i=1,locked=0,outerlock=0,animatelock=0;
    currentlc={0.0,0.0};
    currentLocation={0.0,0.0};
    
    _challege=[[NSMutableArray alloc]init];
    _challege_name=[[NSMutableArray alloc]init];
    _bools=[[NSMutableArray alloc]init];
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questsPList" ofType:@"plist"]];
    
    
    NSArray *arrayValues=[[NSArray alloc] initWithArray:[dictRoot valueForKey:@"QuestsArray"]];
    //NSLog(@"%@",arrayValues);
    NSInteger value=0;
    
    while([arrayValues count]!= value){
        NSArray *items=[[NSArray alloc] initWithArray:[arrayValues objectAtIndex:value]];
        [_challege_name addObject:[items objectAtIndex:0]];
        [_challege addObject:[items objectAtIndex:1]];
        value++;
    }
    
    highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:highscorelist]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:highscorelist error:nil];
    }
    
    NSDictionary *dictpoints =[[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
    
    NSLog(@"%@",dictpoints);
    
    for(int y=0;y<5;y++){
        NSString *key1 = [NSString stringWithFormat:@"%d",y];
        NSNumber *number =[dictpoints objectForKey:key1];
        long temp=[number longValue];
        [_pointsarray replaceObjectAtIndex:y withObject:[NSNumber numberWithLong:temp]];
    }
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"achievement.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"achievement " ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    // Load the Property List.
    NSMutableDictionary  *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    NSNumber *a;
    for(int i=1;i<40;i++){
        NSString *num = [NSString stringWithFormat:@"%d",i];
        
        a=[dict objectForKey:num];
        int temp=[a intValue];
        [_bools addObject:[NSNumber numberWithInt:temp ]];
    }
    
//    if ([shared sharedInstance].isForAchivements && _tableView != nil) {
//        [self maketable];
//        [two.scene.view addSubview:_tableView];
//        [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:2];
//    }
//    else {
    if ([shared sharedInstance].isForAchivements) {
        [_tableView removeFromSuperview];
        [self maketable];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self performSelector:@selector(addTableViewAsSubView) withObject:nil afterDelay:1];
    }
//    }
    
    // [self allplayerstopscore];
    
     [self showLeaderboardAndAchievements:YES];
    
    heart1=(SKSpriteNode *)[self childNodeWithName:@"quick_heartLock"];
    [heart1 setTexture:[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_heartLock"]];
    
    heart2=(SKSpriteNode *)[self childNodeWithName:@"quick_heartLock1"];
    [heart2 setTexture:[SKTexture textureWithImageNamed:@"imageresource/quickGame/quick_heartLock"]];
    quicklifebox=(SKSpriteNode *)[self childNodeWithName:@"quick_lifeBox"];
    
    [self showcoins];
    [self changeskin];
    
    if([shared sharedInstance].flag == 1) {
        NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
        [tdict setObject:[NSNumber numberWithInt:1] forKey:@"costumeSelect"];
        [tdict writeToFile:highscorelist atomically:YES];
    } else {
        NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
        NSNumber *costume = [tdict objectForKey:@"costumeSelect"];
        NSNumber *monkey = [tdict objectForKey:@"monkey"];
        
        if([monkey intValue] == 0 && [costume intValue] == 1) {
            [tdict setObject:[NSNumber numberWithInt:0] forKey:@"costumeSelect"];
            [tdict writeToFile:highscorelist atomically:YES];
        }
    }
    
    [self shopcf];
    
    SKSpriteNode *bt=(SKSpriteNode *)[self childNodeWithName:@"achievements_QuestB"];
    SKTexture *playerTexture= [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_questW"];
    [bt setTexture: playerTexture];
    achtext=3;
    NSLog(@"move to view");
    [self demobinary];
    [self showLeaderboardAndAchievements:YES];
    [self getScrollbutton];
    [self makebutton];
    SKSpriteNode *max=(SKSpriteNode *)[self childNodeWithName:@"max"];
    maxshopButtonpos=CGRectGetMinY(max.frame);
    SKSpriteNode *min=(SKSpriteNode *)[self childNodeWithName:@"min"];
    minshopButtonpos=CGRectGetMaxY(min.frame);
    
    
    [self extrahearts];
    [self getcoins];
    
    if(initCoins==0){
        initCoins = coin;
    } else {
        if (initCoins<5000 && coin>5000) {
            [self alertreview];
        }
    }
    
    [shared sharedInstance].screen_capturing = NO;
    
    
    [self initGameScreen];
    
    
    if([shared sharedInstance].flag==1)
    {
        [self movetoshop];
        [shared sharedInstance].flag = 2;
    }
    else if([shared sharedInstance].flag == 3)
    {
        [self movetogameplay];
        [shared sharedInstance].flag = 100;
    }
    else if([shared sharedInstance].flag == 4)
    {
        [self movetoachievement];
        [shared sharedInstance].flag = 100;
    }
    else if([shared sharedInstance].flag == 5)
    {
        [self movetoshop];
        [shared sharedInstance].flag = 100;
    }
    else if([shared sharedInstance].flag == 6)
    {
        [self movetostorymode];
        [shared sharedInstance].flag = 100;
    }
    //[_tableView reloadData];
}


-(void)addTableViewAsSubView {
//    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageresource/quickGame/quick_goodCoin1"]];
//    _tableView.frame = CGRectMake(40.6667, 165.286, 237.037, 315.556);
//    [two.scene.view addSubview:img];
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(40.6667, 165.286, 237.037, 315.556)];
    [_tableView removeFromSuperview];
    [two.scene.view  addSubview:_tableView];
    [two.scene.view bringSubviewToFront:_tableView];
    [_tableView reloadData];
}

-(void)initGameScreen {
    
    SKSpriteNode *lifebox=(SKSpriteNode *)[self childNodeWithName:@"quick_lifeBox"];
    SKSpriteNode *pause_gam=(SKSpriteNode *)[self childNodeWithName:@"quick_pause"];
    SKSpriteNode *scorebox=(SKSpriteNode *)[self childNodeWithName:@"quick_scoreBox"];
    
    SKSpriteNode *hearts=(SKSpriteNode *)[self childNodeWithName:@"quick_heart"];
    SKSpriteNode *hearts1=(SKSpriteNode *)[self childNodeWithName:@"quick_heartLock"];
    SKSpriteNode *hearts2=(SKSpriteNode *)[self childNodeWithName:@"quick_heartLock1"];
    SKSpriteNode *zero=(SKSpriteNode *)[self childNodeWithName:@"zero"];
    
    SKSpriteNode *capture = [SKSpriteNode spriteNodeWithImageNamed:[self textureAtlasNamed:@"imageresource/quickGame/quick_record"]];
    capture.name = @"capture";
    [left addChild:capture];
    
    
    if(self.frame.size.height==1334){//iphone6
        
        scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+50, CGRectGetMaxY(self.frame)/2+5-scorebox.frame.size.width/1.5);
        lifebox.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        hearts.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-43, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        hearts1.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+hearts1.size.width-36, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5-1);
        hearts2.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+hearts1.size.width*2-29, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5-3);
        
        zero.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+15, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.3+25);
        
        capture.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        
    }
    else if(self.frame.size.height==1104){ //iphone6+
        
        scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+50, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        lifebox.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-pause_gam.size.width-20, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        hearts.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-40, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        hearts1.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width-35, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        hearts2.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width*2-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        
        zero.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5+10);
        
        capture.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-capture.size.width-pause_gam.size.width-20, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.7);
        
        
    }
    else if (self.frame.size.height==1136){ //iphone5
        
        scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        lifebox.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        hearts.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-10, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+5);
        hearts1.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width-5, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        hearts2.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart2.size.width*2+1, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        
        zero.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        
        capture.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        
    }
    else if (self.frame.size.height==960){ //iphone4
        
        scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        lifebox.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
        hearts.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-10, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+5);
        hearts1.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width-5, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        hearts2.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width*2+2, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+3);
        zero.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+5);
        
        capture.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width+10);
    }
    else{//iphone6
        scorebox.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+50, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        lifebox.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        pause_gam.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        hearts.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width-45, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        hearts1.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width-35, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        hearts2.position=CGPointMake(-CGRectGetMaxX(self.frame)/2+scorebox.size.width+heart1.size.width*2-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
        zero.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width+15, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.3+25);
        capture.position=CGPointMake(CGRectGetMaxX(self.frame)/2-scorebox.size.width-capture.size.width-pause_gam.size.width-30, CGRectGetMaxY(self.frame)/2-scorebox.frame.size.width/1.5);
    }
    
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
}

-(NSString*)deviceName {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(void)maketable {
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(40.6667, 165.286, 237.037, 315.556)];
    if (_tableView == nil) {
    if(self.frame.size.height==1334){//iphone6
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15)-5,CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.4)];
//        _tableView.frame = CGRectMake(44.6667, 186.286, 280.037, 315.556);
        
    }
    else if(self.frame.size.height==1104){ //iphone6+
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/13)+10,CGRectGetMaxY(self.frame)/5, self.frame.size.width/2-13, self.frame.size.height/2.62)];
    }
    else if (self.frame.size.height==1136){ //iphone5
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15-2),CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.6)];
    }
    
    else if (self.frame.size.height==960){ //iphone4
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15),CGRectGetMaxY(self.frame)/7, self.frame.size.width/2.8, self.frame.size.height/3.2)];
    }
    else{
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15)-5,CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.4)];
        
    }
        _temptableView=[[UITableView alloc]init];
    }
    else {
        if(self.frame.size.height==1334){//iphone6
            _tableView.frame = CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15)-5,CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.4);
            
        }
        else if(self.frame.size.height==1104){ //iphone6+
            _tableView.frame = CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/13)+10,CGRectGetMaxY(self.frame)/5, self.frame.size.width/2-13, self.frame.size.height/2.62);
        }
        else if (self.frame.size.height==1136){ //iphone5
            _tableView.frame = CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15-2),CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.6);
        }
        
        else if (self.frame.size.height==960){ //iphone4
            _tableView.frame = CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15),CGRectGetMaxY(self.frame)/7, self.frame.size.width/2.8, self.frame.size.height/3.2);
        }
        else{
            _tableView.frame = CGRectMake(CGRectGetMinX(self.frame)+(self.frame.size.width/15)-5,CGRectGetMaxY(self.frame)/7+3, self.frame.size.width/2.7, self.frame.size.height/3.4);
    }
    }
    
    _temptableView.frame=_tableView.frame;
}

-(void)takeScreenShot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *gameOverScreenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(gameOverScreenImage, nil, nil, nil); //if you need to save
    
    //[arrow setTexture:[SKTexture textureWithImage:viewImage]];
    
}

-(void)arrowpostion:(int)end {
    
    if (end==0) {
        if (![textstring isEqualToString:@""]) {
            text=(SKSpriteNode*)[self childNodeWithName:textstring];
            arrow=(SKSpriteNode*)[self childNodeWithName:arrowstring];
            textpos=[text position];
            arrowpos=[arrow position];
            text.position=arrowpos;
            arrow.position=textpos;
            
            mybool = NO;
   
        }
    }else {
        
        ((SKSpriteNode*)[self childNodeWithName:@"menu_button2"]).position = text_up;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_achievements"]).position = arrow_up;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_button4"]).position = text_down;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_shop"]).position = arrow_down;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_button1"]).position = text_left;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_quickPlay"]).position = arrow_left;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_button3"]).position = text_right;
        ((SKSpriteNode*)[self childNodeWithName:@"menu_storyMode"]).position = arrow_right;
        arrowstring = @"";
        textstring = @"";
        mybool = YES;
        
    }
    
}

-(void)removescrollnode {
    [_scrollingNode disableScrollingOnView:third.scene.view];
    [_scrollingNode removeFromParent];
    
    //[rectNode removeFromParent];
    //[node1 removeFromParent];
    
    
}

-(void)showcoins {
    SKSpriteNode *showcoins=(SKSpriteNode *)[third childNodeWithName:@"coinnode"];
    [self getcoins];
    SKLabelNode *slabel=[[SKLabelNode alloc]init];
    [slabel setFontName:@"PoetsenOne-Regular"];
    slabel.zPosition=1;
    // slabel.position=CGPointMake(CGRectGetMidX(showcoins.frame), CGRectGetMinY(showcoins.frame));
    
    slabel.position=CGPointMake(0,-showcoins.frame.size.height/4);  /////////////  Added in 2015.9.19
    
    NSString *man = [NSString stringWithFormat:@"%li",coin];
    [slabel setText:man];
    [slabel setFontColor:[UIColor brownColor]];
    [showcoins removeAllChildren];
    [showcoins addChild:slabel];
    
}

-(void)demobinary {
    [self connection];
    //NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"monkey"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"banana"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"heart1"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"heart2"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:8] forKey:@"heart1life"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:8] forKey:@"heart2life"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"backq"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"backi"];
    //[tdict writeToFile:highscorelist atomically:YES];
    //[tdict setObject:[NSNumber numberWithInt:1] forKey:@"backd"];
    //[tdict writeToFile:highscorelist atomically:YES];
    
}

-(void)resumeMusic{

    [bplay play];
}

-(NSString *)screename {
    NSString *name;
    if(screen_identifier==0){
        name=[NSString stringWithFormat:@"mainmenu"];
    }
    else if (screen_identifier==1){
        name=[NSString stringWithFormat:@"shop"];
//        [self showcoins];
        
    }
    else if (screen_identifier==2){
        name=[NSString stringWithFormat:@"achievement"];
        
    }
    else if (screen_identifier==3){
        name=[NSString stringWithFormat:@"game play"];
        
    }
    else{
        name=[NSString stringWithFormat:@"coming soon"];
    }
    
    return name;
    
    
}

-(void)scroolnode:(int)count {
    _scrollingNode = [[JADSKScrollingNode alloc] init];
    _scrollingNode = [[JADSKScrollingNode alloc] initWithSize:(CGSize){100.0,100.0}];
    _scrollingNode.sliderDelegate = self;
    SKNode *list =[self childNodeWithName:@"shop_banner"];
    
    if (self.frame.size.height==960){
        rectNode = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:(CGSize){kScrollingNodeWidth,kScrollingNodeHeight*0.8f}];
        rectNode.position = CGPointMake(CGRectGetMidX(list.frame)-list.frame.size.height/40, CGRectGetMidY(list.frame)-list.frame.size.height/3.8+30);
    }else{
        rectNode = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:(CGSize){kScrollingNodeWidth,kScrollingNodeHeight}];
        rectNode.position = CGPointMake(CGRectGetMidX(list.frame)-list.frame.size.height/40, CGRectGetMidY(list.frame)-list.frame.size.height/3.8);
    }
    
    rectNode.zPosition=0;
    rectNode.name=@"rect";
    
    SKSpriteNode *maskNode = [rectNode copy];
    //maskNode.name=@"backg";
    
    SKCropNode* cropNode = [SKCropNode node];
    cropNode.maskNode = maskNode;
    cropNode.zPosition=0;
    [cropNode addChild:rectNode];
    
    
    // _scrollingNode.position = CGPointMake(kScrollingNodeXPosition, kScrollingNodeYPosition);
    
    
    [list removeAllChildren];
    [rectNode addChild:_scrollingNode];
    [list addChild:cropNode];
    
    SKLabelNode *topLabelNode = [[SKLabelNode alloc] init];
    topLabelNode.text = @"Top";
    topLabelNode.position = CGPointMake(0, 550);
    
    SKLabelNode *bottomLabelNode = [[SKLabelNode alloc] init];
    bottomLabelNode.text = @"Bottom";
    bottomLabelNode.position = CGPointMake(0, 0);
    
    if (self.frame.size.height==960){
        int a=110;
        if(count>3) a=150;
        for(int m=0;m<count;m++){
            node1=[_nodesitems objectAtIndex:m];
            node1.size = CGSizeMake(330, 90);
            [node1 setScale:0.9];
            if(count>3) [node1 setScale:0.9];
            node1.position=CGPointMake(0, a);
            [_scrollingNode addChild:node1];
            a+=90;
        }
        
    }else{
        int a=80;
        for(int m=0;m<count;m++){
            node1=[_nodesitems objectAtIndex:m];
            node1.size = CGSizeMake(330, 90);
            node1.position=CGPointMake(0, a);
            [_scrollingNode addChild:node1];
            a+=100;
        }
    }
    
    [_scrollingNode addChild:topLabelNode];
    [_scrollingNode addChild:bottomLabelNode];
    
    
}

-(SKSpriteNode *)makenode:(NSString *)node itemlabel:(NSString *)itemlabel coinlabel:(NSString*)coinlabel name:(NSString *)name heading:(NSString *)heading check:(NSString *)checkname {
    SKSpriteNode *text=(SKSpriteNode *)[self childNodeWithName:@"shop_costumeText"];
    [text setTexture:[SKTexture textureWithImageNamed:heading]];
    
    SKSpriteNode *back=[[SKSpriteNode alloc]initWithImageNamed:@"imageresource/shop/shop_itemBg"];
    back.zPosition=8;
    NSString *result=[name stringByAppendingString:@"b"];
    back.name=result;
    
    SKLabelNode *shopitemlabel=[[SKLabelNode alloc ]init];
    [shopitemlabel setFontName:@"PoetsenOne-Regular"];
    [shopitemlabel setFontSize:23.0];
    shopitemlabel.name=name;
    shopitemlabel.zPosition=0;
    shopitemlabel.position=CGPointMake(CGRectGetMidX(back.frame)+40, CGRectGetMidY(back.frame));
    [shopitemlabel setFontColor:[UIColor brownColor]];
    [shopitemlabel setText:itemlabel];
    
    [back addChild:shopitemlabel];
    SKSpriteNode *item=[[SKSpriteNode alloc]initWithImageNamed:node];
    item.name=name;
    item.position=CGPointMake(CGRectGetMinX(back.frame)+back.frame.size.width/4.3, CGRectGetMidY(back.frame));
    [back addChild:item];
    SKSpriteNode *check=[[SKSpriteNode alloc]initWithImageNamed:@"imageresource/shop/shop_checkSlot"];
    check.position=CGPointMake(CGRectGetMinX(back.frame)+check.frame.size.width/3, CGRectGetMidY(back.frame));
    check.name=checkname;
    [back addChild:check];
    
    SKLabelNode *coinsnum=[[SKLabelNode alloc]init];
    coinsnum.name=name;
    [coinsnum setFontName:@"PoetsenOne-Regular"];
    coinsnum.zPosition=0;
    [coinsnum setFontSize:20.0];
    coinsnum.position=CGPointMake(CGRectGetMidX(back.frame)+60, CGRectGetMinY(back.frame)+10);
    [coinsnum setFontColor:[UIColor brownColor]];
    [coinsnum setText:coinlabel];
    [back addChild:coinsnum];
    
    return back;
}

#pragma mark TableView Data Source and Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    LeaderBoardCell *leaderboardCell;
    NSString *levels;
    custom_cellTableViewCell *mycell;
    NSNumber *image;
    NSString *descriptions;
    
    LeaderboardData* leaderBoardData;
    
    if(table_for==0){
        levels= [_challege_name objectAtIndex:indexPath.row];
        descriptions= [_challege objectAtIndex:indexPath.row];
        image=[_bools objectAtIndex:indexPath.row];
    }
    else if(table_for==1){
        leaderBoardData = (LeaderboardData*)[[shared sharedInstance].gamecenter objectAtIndex:indexPath.row];
    }
    else {
        NSString *num = [NSString stringWithFormat:@"%li",[[_pointsarray objectAtIndex:indexPath.row] longValue]];
        levels=num;
    }
    if(table_for == 0) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Identifier"];
        }
    }else if (table_for == 1){
        leaderboardCell=[_tableView dequeueReusableCellWithIdentifier:@"LeaderBoardCell"];
        if(!leaderboardCell){
            [_tableView registerNib:[UINib nibWithNibName:@"LeaderBoardCell" bundle:nil] forCellReuseIdentifier:@"LeaderBoardCell"];
            leaderboardCell=[_tableView dequeueReusableCellWithIdentifier:@"LeaderBoardCell"];
        }

    } else {
        mycell=[_tableView dequeueReusableCellWithIdentifier:@"mycell"];
        if(!mycell){
            [_tableView registerNib:[UINib nibWithNibName:@"custom cell" bundle:nil] forCellReuseIdentifier:@"mycell"];
            mycell=[_tableView dequeueReusableCellWithIdentifier:@"mycell"];
        }
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    //leaderboard
    if(table_for==1) {
        /*[mycell.name setFont:[UIFont boldSystemFontOfSize:15]];
         
         NSString* playerName = leaderBoardData.playerName;
         NSString* numString;
         if(indexPath.row + 1 >= 10) {
         numString = [NSString stringWithFormat:@"%li    ", (long)indexPath.row+1];
         } else {
         numString = [NSString stringWithFormat:@"%li     ", (long)indexPath.row+1];
         }
         
         NSString* score = leaderBoardData.score;
         
         playerName = [numString stringByAppendingString:playerName];
         [mycell.name setText:playerName];
         [mycell.points setText:score];*/
        
        [leaderboardCell.IBlblIndex setText:[NSString stringWithFormat:@"%li      ", (long)indexPath.row + 1]];
        [leaderboardCell.IBlblUserName setText:leaderBoardData.playerName];
        [leaderboardCell.IBlblPoints setText:leaderBoardData.score];
        
        
        
//        NSString* stringNumber;
//        
//        if(indexPath.row + 1 >= 10) {
//            stringNumber = [NSString stringWithFormat:@"%li      ", (long)indexPath.row + 1];
//        } else {
//            stringNumber = [NSString stringWithFormat:@"%li     ", (long)indexPath.row + 1];
//        }
//        
//        NSMutableString *displayStr = [NSMutableString stringWithString:stringNumber];
//        NSInteger len = leaderBoardData.playerName.length;
//        if(len > 20) {
//            [displayStr appendString:[leaderBoardData.playerName substringToIndex:20]];
//            len = 20;
//        } else {
//            [displayStr appendString:leaderBoardData.playerName];
//        }
//        
//        int blankCount = 24 - (int)len;
//        for(int i = 0; i < blankCount; i++) {
//            [displayStr appendString:@" "];
//        }
//        [displayStr appendString:leaderBoardData.score];
//        
//        [cell.textLabel setText:displayStr];
//        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
////        [cell.textLabel sizeToFit];
////        [cell.textLabel setMinimumScaleFactor:0.6];
//        [cell.detailTextLabel setText:@""];
//        cell.imageView.image = nil;
    }
    //achievements
    else if(table_for==0) {
        [cell.textLabel setText:levels];
        [cell.detailTextLabel setText:descriptions];
        if([image isEqualToNumber:[NSNumber numberWithInt:0]]){
            cell.imageView.frame = CGRectMake( 10, 10, 50, 50 );
            cell.imageView.image = [UIImage imageNamed:@"imageresource/achevement/achievements_button.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"imageresource/achevement/achievements_checkmark.png"];
        }
    }
    //top5 scores
    else{
        [mycell.name setFont:[UIFont boldSystemFontOfSize:15]];
        NSString* playerName =[shared sharedInstance].playername;
        NSString* numString = [NSString stringWithFormat:@"%li", (long)indexPath.row+1];
        playerName = [playerName stringByAppendingString:numString];
        [mycell.name setText:playerName];
        [mycell.points setText:levels];
        mycell.myimage.image=[UIImage imageNamed:@"imageresource/achevement/achievements_button.png"];
    }
    
    if(table_for == 0){
        return cell;
    }else if(table_for == 1){
        return leaderboardCell;
    }else{
        return mycell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(table_for==0)
    {
        
        NSString *title = [_challege_name objectAtIndex:indexPath.row];
        NSString *descriptions= [_challege objectAtIndex:indexPath.row];
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:descriptions
                                  delegate:self
                                  cancelButtonTitle:@"Got it, thank you!"
                                  otherButtonTitles:nil];
        
        [alertView show];
        
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    
    if(table_for==0){
        count=[_challege_name count];}
    else if(table_for==1){
        count=[[shared sharedInstance].gamecenter count];
        if(count > 15) count = 15;
    }
    else{
        count=[_pointsarray count];
    }
    NSLog(@"%ld", (long)count);
    return count;
}

- (void)showAchievements{
    NSLog(@"table view123");
    table=1;
    screen_identifier=2;
    currentnode=two;
    [_tableView removeFromSuperview];
    [two.scene.view  addSubview:_tableView];
    [_tableView setFrame:CGRectMake(CGRectGetMidX(_temptableView.frame)/4, -1.2*CGRectGetMidY(_temptableView.frame)-(currentLocation.y-currentlc.y)/2,_temptableView.frame.size.width ,_temptableView.frame.size.height)];
    [self dragaction:1 firstnode:two srcondnode:my move:0 defaultpos:mypos];
    
    //////////////////////////   Add in 2015.9.16 /////////////////////////////////////////////////////////////
    
    [UIView animateWithDuration:0.65 animations:^{
        [_tableView setFrame:_temptableView.frame];
    } completion:^(BOOL finished) {
        _tableView.frame=_temptableView.frame;
    }];
}

- (void)showShop{
    [self dragaction:0 firstnode:third srcondnode:my move:0 defaultpos:mypos];
    screen_identifier=1;
    currentnode = third;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/menu-music-loop-sample" ofType:@"mp3"]];
    bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [bplay setNumberOfLoops:-1];
    [bplay prepareToPlay];
    [bplay play];
}

- (void)showQuickPlay{
    SKAction *moveright=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
    [left runAction:moveright];
    float temp=CGRectGetMaxX(self.frame);
    SKAction *o=[SKAction moveToX:temp+(temp/2)+1 duration:0.5];
    
    drag_on = YES;
    [my runAction:o completion:^{
        my.position=mypos;
        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition fadeWithDuration:0.5];
        [self.view presentScene:nextScene transition:doors];
        drag_on = NO;
    }
     ];
    screen_identifier=3;
}

- (void)showStoryMode{
    [self dragaction:1 firstnode:right srcondnode:my move:1 defaultpos:mypos];
    screen_identifier=4;
}

- (void)handleButtonsClick:(NSString *)name{
    if ([name isEqualToString:@"menu_button2"] || [name isEqualToString:@"menu_achievements"]) {
        textstring=[NSString stringWithFormat:@"menu_achievements"];
        arrowstring=[NSString stringWithFormat:@"menu_button2"];
        [self showAchievements];
    }else if ([name isEqualToString:@"menu_button4"] || [name isEqualToString:@"menu_shop"]){
        textstring=[NSString stringWithFormat:@"menu_shop"];
        arrowstring=[NSString stringWithFormat:@"menu_button4"];
        [self showShop];
    }else if ([name isEqualToString:@"menu_button1"] || [name isEqualToString:@"menu_quickPlay"]){
        textstring=[NSString stringWithFormat:@"menu_quickPlay"];
        arrowstring=[NSString stringWithFormat:@"menu_button1"];
        [self showQuickPlay];
    }else if ([name isEqualToString:@"menu_button3"] || [name isEqualToString:@"menu_storyMode"]){
        textstring=[NSString stringWithFormat:@"menu_storyMode"];
        arrowstring=[NSString stringWithFormat:@"menu_button3"];
        [self showStoryMode];
    }else{
    
    }
    if(mybool){
        [self arrowpostion:0];
        mybool=NO;
    }
}


#pragma mark Touchbegin Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (drag_on) {
        swipe_enable = NO;
        
    }else {
        swipe_enable = YES;
    }
    
    if(customswipe==NO){
        currentLocation={0,0};
        currentlc={0,0};
        customswipe=YES;
    }
    
    UITouch *touch = [touches anyObject];
    
    currentlc = [[touches anyObject] locationInNode:self];
    startTime = touch.timestamp;
    shopcurrent = [[touches anyObject] locationInNode:self];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/SFX-4Match" ofType:@"mp3"]];
    buttonpressed = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    //currentlc = [[touches anyObject] locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:currentlc];
    NSLog(@"%@",touchedNode.name);
    [self handleButtonsClick:touchedNode.name];
    
    if([touchedNode.name isEqualToString:@"shop_scrollButton1"]){
        shopbuttonscroll=1;
    }
    if([touchedNode.name isEqual:@"achievements_topB"]){
        
        SKTexture *playerTexture= [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_topW"];
        [touchedNode setTexture: playerTexture];
        table_for=2;
        [_tableView reloadInputViews];
        [_tableView reloadData];
        [buttonpressed play];
        if(achtext!=1){
            [self changetbuttonTexture];
        }
        achtext=1;
        return;
        
    }
    
    if([touchedNode.name isEqual:@"achievements_leaderB"]){
        
        SKTexture *playerTexture= [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_leaderW"];
        [touchedNode setTexture: playerTexture];
        table_for=1;
        add++;
        [_tableView reloadData];
        [buttonpressed play];
        if(achtext!=2){
            [self changetbuttonTexture];
        }
        achtext=2;
        
        return;
    }
    if([touchedNode.name isEqual:@"achievements_QuestB"]){
        
        SKTexture *playerTexture= [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_questW"];
        [touchedNode setTexture: playerTexture];
        table_for=0;
        [_tableView reloadData];
        
        [buttonpressed play];
        if(achtext!=3){
            [self changetbuttonTexture];
        }
        achtext=3;
        
        return;
    }
    
    if([touchedNode.name isEqual:@"shop_fallingObjects"]){
        [scrollbutton setPosition:CGPointMake(scrollbutton.position.x, maxshopButtonpos)];
        checkid=0;
        [self reintalize];
        shop=1;
        globale=[self makenode:@"imageresource/shop/shop_itemBanana2" itemlabel:@"Banana" coinlabel:@"$ 0.99" name:@"banana" heading:@"imageresource/shop/shop_fallingObjectText" check:@"checkf"];
        [_nodesitems addObject:globale];
        globale=[self makenode:@"quick_goodCoin1" itemlabel:@"Coin" coinlabel:@"FREE" name:@"coins" heading:@"imageresource/shop/shop_fallingObjectText" check:@"checke"];
        [_nodesitems addObject:globale];
        [_scrollingNode disableScrollingOnView:self.view];
        [self removescrollnode];
        [self scroolnode:2];
        
        [_scrollingNode disableScrollingOnView:third.scene.view];
        [_scrollingNode scrolltoMiddle];
        [self checkinitialize];
        
        ////////////////////   Modified in 2015.9.25  ////////////////////////////////////
        
        NSNumber *temp = [tdict objectForKey:@"falingobject"];
        if ([temp intValue]==0) {
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:1] childNodeWithName:@"checke"];
            [self check:n string:@"coins" index:[temp intValue] check:@"checke"];
        } else {
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:0] childNodeWithName:@"checkf"];
            [self check:n string:@"banana" index:[temp intValue] check:@"checkf"];
        }
    }
    if([touchedNode.name isEqual:@"shop_costume" ]){
        [scrollbutton setPosition:CGPointMake(scrollbutton.position.x, maxshopButtonpos)];
        checkid=0;
        [self shopcf];
        shop=0;
    }
    
    if([touchedNode.name isEqual:@"shop_misc" ]){
        [scrollbutton setPosition:CGPointMake(scrollbutton.position.x, maxshopButtonpos)];
        checkid=0;
        [self reintalize];
        NSArray *heartslabel=[[NSArray alloc]initWithObjects:@"1/3 Hearts",@"2/3 Hearts",@"3/3 Hearts",@"Whole Hearts", nil];
        NSArray *coinslabel=[[NSArray alloc]initWithObjects:@"250 Coins/Bananas",@"500 Coins/Bananas",@"750 Coins/Bananas",@"1000 Coins/Bananas", nil];
        shop=2;
        [self removescrollnode];
        int y=0;
        for(int n=1;n<5;n++){
            NSMutableString* aString = [NSMutableString stringWithFormat:@"imageresource/shop/shop_itemHeart%d",n];
            NSMutableString* a = [NSMutableString stringWithFormat:@"hearts%d",n];
            NSMutableString* r =[NSMutableString stringWithFormat:@"check%d",n];
            globale=[self makenode:aString itemlabel:heartslabel[y] coinlabel:coinslabel[y] name:a heading:@"imageresource/shop/shop_miscText" check:r];
            [_nodesitems addObject:globale];
            y++;
        }
        
        [self scroolnode:4];
        
        [_scrollingNode enableScrollingOnView:third.scene.view];
        [_scrollingNode scrollToTop];
        [self checkinitialize];
    }
    if([touchedNode.name isEqual:@"shop_background2" ]){
        [scrollbutton setPosition:CGPointMake(scrollbutton.position.x, maxshopButtonpos)];
        checkid=0;
        shop=3;
        
        [self reintalize];
        NSArray *heartslabel=[[NSArray alloc]initWithObjects:@"Glaciers",@"Desert",@"Christmas",@"Spring", nil];
        NSArray *coinslabel=[[NSArray alloc]initWithObjects:@"1000 Coins/Bananas",@"500 Coins/Bananas",@"2000 Coins/Bananas",@"FREE", nil];
        [self removescrollnode];
        int y=0;
        for(int n=1;n<5;n++){
            NSMutableString* aString = [NSMutableString stringWithFormat:@"background/quick_background%d",n];
            NSMutableString* a = [NSMutableString stringWithFormat:@"back%d",n];
            NSMutableString *r=[NSMutableString stringWithFormat:@"checkb%d",n];
            globale=[self makenode:aString itemlabel:heartslabel[y] coinlabel:coinslabel[y] name:a heading:@"imageresource/shop/shop_backgroundText" check:r];
            [_nodesitems addObject:globale];
            y++;
        }
        
        [self scroolnode:4];
        
        [_scrollingNode enableScrollingOnView:third.scene.view];
        [_scrollingNode scrollToTop];
        [self checkinitialize];
        
        ////////////////////   Modified in 2015.9.25  ////////////////////////////////////
        
        NSNumber *temp = [tdict objectForKey:@"backactive"];
        if ([temp intValue]==0) {
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:3] childNodeWithName:@"checkb4"];
            [self check:n string:@"back4" index:[temp intValue] check:@"checkb4"];
        }
        else if([temp intValue]==1){
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:2] childNodeWithName:@"checkb3"];
            [self check:n string:@"back3" index:[temp intValue] check:@"checkb3"];
        }
        else if([temp intValue]==2){
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:1] childNodeWithName:@"checkb2"];
            [self check:n string:@"back2" index:[temp intValue] check:@"checkb2"];
        }
        else{
            SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:0] childNodeWithName:@"checkb1"];
            [self check:n string:@"back1" index:[temp intValue] check:@"checkb1"];
        }
    }
    
    if([touchedNode.name isEqual:@"shop_purchase"]){
        [self buythings];
    }
    
    if([touchedNode.name isEqual:@"shop_restore"]) {
        [self restore];
    }
    /////////////////////////////////  Added in 2015.9.17  //////////////////////////////////////////
    
    CGPoint new_currentlc = CGPoint{currentlc.x - third.frame.size.width/2, currentlc.y - third.frame.size.height/2};
    if(CGRectContainsPoint(rectNode.frame, new_currentlc)){
        
        if(shop>=2)checkScroll=NO;
    }
    //costumes
    if([touchedNode.name isEqualToString:@"warrior"] || [touchedNode.name isEqualToString:@"warriorb"] || [touchedNode.name isEqualToString:@"checkd"]){
        
        [self check:touchedNode string:@"warrior" index:0 check:@"checkd"];
    }
    
    if([touchedNode.name isEqualToString:@"monkey"] || [touchedNode.name isEqualToString:@"monkeyb"] || [touchedNode.name isEqualToString:@"checkc"]){
        
        [self check:touchedNode string:@"monkey" index:1 check:@"checkc"];
    }
    //fallingobjects
    
    if([touchedNode.name isEqualToString:@"coins"] || [touchedNode.name isEqualToString:@"coinsb"] || [touchedNode.name isEqualToString:@"checke"]){
        
        [self check:touchedNode string:@"coins" index:0 check:@"checke"];
    }
    if([touchedNode.name isEqualToString:@"banana"] || [touchedNode.name isEqualToString:@"bananab"] || [touchedNode.name isEqualToString:@"check4"]){
        
        [self check:touchedNode string:@"banana" index:1 check:@"checkf"];
    }
    
    
    //hearts
    if([touchedNode.name isEqualToString:@"hearts4"] || [touchedNode.name isEqualToString:@"hearts4b"] || [touchedNode.name isEqualToString:@"check4"]){
        
        [self check:touchedNode string:@"hearts4" index:0 check:@"check4"];
    }
    
    if([touchedNode.name isEqualToString:@"hearts3"] || [touchedNode.name isEqualToString:@"hearts3b"] || [touchedNode.name isEqualToString:@"check3"]){
        
        [self check:touchedNode string:@"hearts3" index:1 check:@"check3"];
    }
    
    if([touchedNode.name isEqualToString:@"hearts2"] || [touchedNode.name isEqualToString:@"hearts2b"] || [touchedNode.name isEqualToString:@"check2"]){
        
        [self check:touchedNode string:@"hearts2" index:2 check:@"check2"];
    }
    if([touchedNode.name isEqualToString:@"hearts1"] || [touchedNode.name isEqualToString:@"hearts1b"] || [touchedNode.name isEqualToString:@"check1"]){
        
        [self check:touchedNode string:@"hearts1" index:3 check:@"check1"];
    }
    
    
    //backgrounds
    if([touchedNode.name isEqualToString:@"back4"] || [touchedNode.name isEqualToString:@"back4b"] || [touchedNode.name isEqualToString:@"checkb4"]){
        
        [self check:touchedNode string:@"back4" index:0 check:@"checkb4"];
    }
    
    if([touchedNode.name isEqualToString:@"back3"] || [touchedNode.name isEqualToString:@"back3b"] || [touchedNode.name isEqualToString:@"checkb3"]){
        
        [self check:touchedNode string:@"back3" index:1 check:@"checkb3"];
    }
    
    if([touchedNode.name isEqualToString:@"back2"] || [touchedNode.name isEqualToString:@"back2b"] || [touchedNode.name isEqualToString:@"checkb2"]){
        
        [self check:touchedNode string:@"back2" index:2 check:@"checkb2"];
    }
    if([touchedNode.name isEqualToString:@"back1"] || [touchedNode.name isEqualToString:@"back1b"] || [touchedNode.name isEqualToString:@"checkb1"]){
        
        [self check:touchedNode string:@"back1" index:3 check:@"checkb1"];
    }
    
    
    
}



-(void)changetbuttonTexture {
    SKTexture *buttonTexture;
    if(achtext==1 ){
        abutton=(SKSpriteNode *)[two childNodeWithName:@"achievements_topB"];
        buttonTexture = [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_topB"];
    }
    else if (achtext==2 ){
        abutton=(SKSpriteNode *)[two childNodeWithName:@"achievements_leaderB"];
        
        buttonTexture = [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_leaderB"];
    }
    else if(achtext==3){
        abutton=(SKSpriteNode *)[two childNodeWithName:@"achievements_QuestB"];
        buttonTexture = [SKTexture textureWithImageNamed:@"imageresource/achevement/achievements_QuestB"];
    }
    else{
        
    }
    
    [abutton setTexture:buttonTexture];
}

-(void)check:(SKSpriteNode *)node string:(NSString*)name index:(int)index check:(NSString *)checkname {
    
    if(index<0 || index>3) index = 0;
    SKSpriteNode *n;
    
    if([node.name isEqualToString:name] || [node.name isEqualToString:checkname]){
        
        SKNode *my=[node parent];
        n=(SKSpriteNode *)[my childNodeWithName:checkname];
    }
    else
    {
        n=(SKSpriteNode *)[node childNodeWithName:checkname];
    }
    
    //if([[_check objectAtIndex:index] isEqualToNumber:[NSNumber numberWithInt:0]]){
    [n setTexture:[SKTexture textureWithImageNamed:@"imageresource/shop/shop_checkMark"]];
    [_check replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:1]];
    //}
    //else {
    //    [n setTexture:[SKTexture textureWithImageNamed:@"imageresource/shop/shop_checkSlot"]];
    //    [_check replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:0]];
    //}
    
    if(screen_identifier==1){
        if(checkid!=0 && temp!=nil){
            if([temp.name isEqual:n.name]){
            }
            else{
                [temp setTexture:[SKTexture textureWithImageNamed:@"imageresource/shop/shop_checkSlot"]];
                [_check replaceObjectAtIndex:preindex withObject:[NSNumber numberWithInt:0]];
                temp=nil;
            }
        }}
    
    
    checkid++;
    
    temp=n ;
    preindex=index;
    if(shop < 2) {
        [self activate:index];
    } else if(shop==3){
        [self activateback:index];
    }
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

-(void)changeskin {
    
    NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
    int mo=0;
    NSNumber *num=[dit objectForKey:@"backactive"];
    NSString *temp,*temp2;
    if([num intValue]==0){
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_backgroundOriginal"];
        
    }
    
    else if ([num intValue]==1){
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_background"];
    }
    else if ([num intValue]==2){
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_backgroundDessert"];
    }
    else if ([num intValue]==3){
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_backgroundIce"];
    }
    else{
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_backgroundOriginal"];
    }
    [left setTexture:[SKTexture textureWithImageNamed:temp]];
    [shared sharedInstance].backtexture=temp;
    
    num=[dit valueForKey:@"costumeSelect"];
    
    if([num intValue]==0){
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_warrior2"];
        temp2=[self textureAtlasNamed:@"imageresource/quickGame/quick_lifeBox"];
        mo=0;
    }
    else{
        
        temp=[self textureAtlasNamed:@"imageresource/quickGame/quick_monkey2"];
        temp2=[self textureAtlasNamed:@"imageresource/quickGame/quick_lifeBoxMonkey"];
        mo=1;
    }
    [playericon setTexture:[ SKTexture textureWithImageNamed:temp]];
    [shared sharedInstance].lifeboxtext=temp2;
    [quicklifebox setTexture:[SKTexture textureWithImageNamed:temp2]];
    [shared sharedInstance].monkey=mo;
    
}

-(void)activateback:(int)index {
    
    NSNumber *check;
    NSArray *listback=[[NSArray alloc]initWithObjects:@"backactive",@"backq",@"backd",@"backi",nil];
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *active=[tdict objectForKey:@"backactive"];
    NSLog(@"index%d",index);
    NSLog(@"%dactive",[active intValue]);
    int myaindex=0;
    if(index!=0){
        
        check=[tdict objectForKey:[listback objectAtIndex:index]];
        
        
        if([check intValue]==1){
            myaindex=index;
        }
        else{
            myaindex=0;
        }
        
        NSLog(@"myaindex%d",myaindex);
        
    }else{
        
        myaindex=0;
    }
    
    [tdict setObject:[NSNumber numberWithInt:myaindex] forKey:@"backactive"];
    [tdict writeToFile:highscorelist atomically:YES];
    
    /*  if([check intValue]==1 || myaindex==index){
     
     if(myaindex == [active intValue]){
     
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@" "
     message:@"Already Purchased!"
     delegate:self
     cancelButtonTitle:@"Okay, got it!"
     otherButtonTitles:nil];
     
     [alertView show];
     
     }
     
     else{
     
     
     bactiveindex=index;
     
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@" "
     message:@"Do you want to Purchase!"
     delegate:self
     cancelButtonTitle:@"Cancel"
     otherButtonTitles:@"Purchase", nil];
     alertView.tag=101;
     
     //  [alertView show];
     
     
     }
     }
     
     */
    
    NSLog(@"backactive index%d",bactiveindex);
    
}

-(void)connection {
    highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:highscorelist]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:highscorelist error:nil];
    }
}

-(void)firstonmenuscreen:(int)identifier {
    static bool firstVisited = true;
    
    [self connection];
    NSMutableDictionary *first=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSArray *message1=[[NSArray alloc]initWithObjects:@"My name is Jason McCoy and thank you for your interest in my game. Please swipe Up, Down, Left, Right to access the menus on the screen!", @"Swipe up to navigate to the Home Screen", @"Swipe Down to navigate to the Home Screen.", @"Swipe Left to navigate to the Home Screen", nil];
    NSArray *title=[[NSArray alloc]initWithObjects:@"Have Fun!",@"For your information", @"For your information", @"Coming Soon!", nil];
    NSString *key;
    int index=0;
    if(identifier==0){
        key=[NSString stringWithFormat:@"first"];
        index=0;
    }
    else if (identifier==1){
        key=[NSString stringWithFormat:@"shop"];
        index=1;
    }
    else if(identifier==2){
        key=[NSString stringWithFormat:@"achievement"];
        index=2;
        
    }
    else if(identifier==4){
        key=[NSString stringWithFormat:@"right"];
        index=3;
    }
    else{
        //nothing
        index=-1;
    }
    NSNumber *f=[first objectForKey:key];
    if(index!=-1) {
        if([f intValue] == 0) {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[title objectAtIndex:index]
                                                              message:[message1 objectAtIndex:index]
                                                             delegate:self
                                                    cancelButtonTitle:@"Got it Thanks!"
                                                    otherButtonTitles:nil];
            if(index==0) {
                message.tag=103;
                
                init_3d = NO;
            }
            
            [message show];
            if(key!=nil){
                [first setObject:[NSNumber numberWithInt:1]forKey:key];
                [first writeToFile:highscorelist atomically:YES];
            }
            
        } else {
            if(firstVisited == true) {
                if([[first objectForKey:@"review"] intValue] == 0) {
//                    [self alertRewardVideo];
                }
            }
        }
    }
    if(firstVisited == true) firstVisited = false;
}

-(void)alertRewardVideo {
    UIAlertView *my= [[UIAlertView alloc]
                      initWithTitle:@"Oh Yeah! Almost forgot!"
                      message:@"To start off,I’ll give you 738 Catch Coins in exchange for you watching my sponsor’s HD mobile app trailer for 30 seconds.This is so I can make a little cash to help improve your experience. Whaddaya Say?"
                      delegate:self
                      cancelButtonTitle:@"Sure, why not"
                      otherButtonTitles:@"No, I can't",nil];
    my.tag=104;
    [my show];
    
}

-(void)activate:(int)index{
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *temp,*select;
    NSString *key;
    NSString *selectobject;
    
    if(shop==0) {
        key=[[NSString alloc]initWithFormat:@"monkey"];
        temp=[tdict objectForKey:key];
        selectobject=[[NSString alloc]initWithFormat:@"costumeSelect"];
        select=[tdict objectForKey:selectobject];
        
        if (index==0) {
            [tdict setObject:[NSNumber numberWithInt:index] forKey:selectobject];
            [tdict writeToFile:highscorelist atomically:YES];
            [shared sharedInstance].monkey=0;
        } else if(index==1){
            if ([temp intValue]==1) {
                [tdict setObject:[NSNumber numberWithInt:index] forKey:selectobject];
                [tdict writeToFile:highscorelist atomically:YES];
                [shared sharedInstance].monkey=1;
            }
        }
    }
    else if(shop==1){
        
        key=[[NSString alloc]initWithFormat:@"banana"];
        temp=[tdict objectForKey:key];
        selectobject=[[NSString alloc]initWithFormat:@"falingobject"];
        select=[tdict objectForKey:selectobject];
        
        if (index==0) {
            [tdict setObject:[NSNumber numberWithInt:index] forKey:selectobject];
            [tdict writeToFile:highscorelist atomically:YES];
        }else if(index==1){
            
            if ([temp intValue]==1) {
                [tdict setObject:[NSNumber numberWithInt:index] forKey:selectobject];
                [tdict writeToFile:highscorelist atomically:YES];
            }
        }
    }
}

#pragma mark alert delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self connection];
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    
    if(alertView.tag==99){
        
        if(buttonIndex==0)
        {
            
            
            NSLog(@"sure why not!");
            static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
            static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, YOUR_APP_STORE_ID]]];
        }
        else{
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please describe your problem or question." delegate:self cancelButtonTitle:@"Send" otherButtonTitles:@"Cancel",nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0] becomeFirstResponder];
            alert.tag = 98;
            [alert show];
        }
    }
    
    if(alertView.tag==98){
        
        if(buttonIndex==0){
            if ([MFMailComposeViewController canSendMail]) {
                
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                [picker setSubject:@"Alert Me"];
                NSArray *toRecipients = [NSArray arrayWithObjects:@"Jason@CatchCrisis.com", nil];
                [picker setToRecipients:toRecipients];
                NSString *emailBody = [[alertView textFieldAtIndex:0] text];
                [picker setMessageBody:emailBody isHTML:NO];
                [self.view.window.rootViewController presentViewController:picker animated:YES completion:nil];
                
            } else {
                
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mail Alert!"
                                                                  message:@"Your mobile is not able to send email  please configure email first"
                                                                 delegate:self
                                                        cancelButtonTitle:@"ok"                                                otherButtonTitles:nil];
                
                [message show];
            }
        }
    }
    
    if(alertView.tag==100){
        if (buttonIndex == 0)
        {
            NSLog(@"cancel");
        }
        else
        {
            [tdict setObject:[NSNumber numberWithInt:myindex] forKey:selection];
            [tdict writeToFile:highscorelist atomically:YES];
            
            
        }
    }
    
    if(alertView.tag==101){
        if (buttonIndex == 0)
        {
            NSLog(@"cancel");
        }
        else
        {
            [tdict setObject:[NSNumber numberWithInt:bactiveindex] forKey:@"backactive"];
            [tdict writeToFile:highscorelist atomically:YES];
        }
        
    }
    
    if(alertView.tag==103){
        if(buttonIndex==0) {
//            [self alertRewardVideo];
        }
    }
    
    if(alertView.tag==104){
        if (buttonIndex==1) {
            NSLog(@"cancel");
            // [self alertreview];
        }
        else{
            [self rewardedvideo];
            videoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playMusic) userInfo:nil repeats:YES];
        }
    }
    
    if(alertView.tag==105){
        if(buttonIndex==0){
            [self reviewmailpopUp];
            NSLog(@"mail");
        }
        else{
            NSLog(@"sure why not!");
            static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
            static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, YOUR_APP_STORE_ID]]];
        }
    }
    
    [self changeskin];
    
}

-(void)reintalize {
    _nodesitems=nil;
    _nodesitems=[[NSMutableArray alloc]init];
}

-(void)shopcf {
    [self reintalize];
    globale=[self makenode:@"imageresource/shop/shop_itemMonkey" itemlabel:@"Monkey" coinlabel:@"$ 0.99" name:@"monkey" heading:@"imageresource/shop/shop_costumeText" check:@"checkc"];
    [_nodesitems addObject:globale];
    globale=[self makenode:@"quick_warrior2" itemlabel:@"Warrior" coinlabel:@"FREE" name:@"warrior" heading:@"imageresource/shop/shop_costumeText" check:@"checkd"];
    [_nodesitems addObject:globale];
    
    [self removescrollnode];
    [self scroolnode:2];
    [_scrollingNode disableScrollingOnView:third.scene.view];
    [_scrollingNode scrolltoMiddle];
    
    shop = 0;
    /////////////////////   Modified in 2015.9.25  ////////////////////////////////////
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *temp = [tdict objectForKey:@"costumeSelect"];
    if ([temp intValue]==0) {
        SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:1] childNodeWithName:@"checkd"];
        [self check:n string:@"warrior" index:[temp intValue] check:@"checkd"];
    }
    else{
        SKSpriteNode *n = (SKSpriteNode *)[[_nodesitems objectAtIndex:0] childNodeWithName:@"checkc"];
        [self check:n string:@"monkey" index:[temp intValue] check:@"checkc"];
    }
    
}

-(void)getcoins {
    highscorelist= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    highscorelist = [highscorelist stringByAppendingPathComponent:@"highscore.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    
    
    
    NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
    NSNumber *a =[dit objectForKey:@"coins"];
    
    coin=[a longLongValue];
    
    
    //NSLog(@"coinffffff%lu",[a longLongValue]);
    
}

-(void)buythings {
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    
    if(shop == 0) {
        [self buycp];
    }
    
    else if(shop==1){
        [self buycp];
    }
    
    else if(shop==2){
        [self buyhearts];
    }
    
    else if(shop==3){
        [self buybackground];
    }
    
    ////////////////   Added in 2015.9.19  ///////////////////////////////////////////////////////////////////
    
    SKAction *soundAction = [SKAction playSoundFileNamed:@"gameMusic/SFX-4Match.mp3" waitForCompletion:NO];
    [self runAction:soundAction];
    
}

-(void)buybackground {
    int index=0,sum=0;
    
    NSString *title,*explain, *key;
    
    NSArray *co=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:2000],[NSNumber numberWithInt:500],[NSNumber numberWithInt:1000],nil];
    for (int y=0; y<5; y++) {
        sum=sum+[[_check objectAtIndex:y] intValue];
        if([[_check objectAtIndex:y] intValue]==1){
            index=y;
        }
    }
    
    if(index==1)
        key = @"backq";
    else if (index==2)
        key = @"backd";
    else if (index==3)
        key = @"backi";
    else
        return;
    
    if(sum>0){
        
        NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithContentsOfFile:highscorelist];
        NSNumber *a =[dit objectForKey:key];
        if([a intValue]==1){
            
            title=[[NSString alloc]initWithFormat:@" "];
            explain=[[NSString alloc]initWithFormat:@"Already Purchased!"];
            
        }else if([self coincheck:[[co objectAtIndex:index]longValue]]){
            
            //ice
            if(index==3){
                
                title=[[NSString alloc]initWithFormat:@" "];
                explain=[[NSString alloc]initWithFormat:@"Glaciers Background Purchased!"];
            }
            //desert
            else if(index==2){
                
                title=[[NSString alloc]initWithFormat:@" "];
                explain=[[NSString alloc]initWithFormat:@"Desert Background Purchased!"];
            }
            //Quick
            else if(index==1){
                
                title=[[NSString alloc]initWithFormat:@""];
                explain=[[NSString alloc]initWithFormat:@"Christmas Background Purchased!"];
                
            }else {
                
                return;
            }
            
            [dit setObject:[NSNumber numberWithInt:index]forKey:@"backactive"];
            [dit writeToFile:highscorelist atomically:YES];
            
            [self updatelist:key add:0 heartnum:0];
            [self detuctcoin:[[co objectAtIndex:index] longValue]];
            
        }
        else{
            title=[[NSString alloc]initWithFormat:@""];
            explain=[[NSString alloc]initWithFormat:@"Not enough coins, sorry!"];
        }
    }
    else{
        title=[[NSString alloc]initWithFormat:@"ALert!"];
        explain=[[NSString alloc]initWithFormat:@"Kindly select any item inorder to purchase"];
    }
    
    UIAlertView *alertView;
    if([explain isEqual:@"Not enough coins, sorry!"]){
        
        alertView = [[UIAlertView alloc]
                     initWithTitle:nil
                     message:explain
                     delegate:self
                     cancelButtonTitle:@"Okay, I'll keep playing."
                     otherButtonTitles:nil];
        
    }else{
        
        alertView = [[UIAlertView alloc]
                     initWithTitle:title
                     message:explain
                     delegate:self
                     cancelButtonTitle:@"Okay, got it"
                     otherButtonTitles:nil];
    }
    
    [alertView show];
    
    
    
}

-(void)detuctcoin:(long)m_coin {
    
    NSString *list = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    list = [list stringByAppendingPathComponent:@"highscore.plist"];
    NSMutableDictionary *tdict = [[NSMutableDictionary alloc] initWithContentsOfFile:list];
    
    NSNumber *temp= [tdict objectForKey:@"coins"];
    long t=(long)[temp longLongValue];
    t=t-m_coin;
    
    [tdict setObject:[NSNumber numberWithLong:t] forKey:@"coins"];
    [tdict writeToFile:highscorelist atomically:YES];
    
    [self showcoins];
    
    
}

-(BOOL)coincheck:(long)coincheck {
    BOOL man;
    if(coincheck<=coin){
        man=YES;
    }
    else{
        man=NO;
    }
    return man;
}

-(void)buyhearts {
    
    int sum=0,index=0;
    NSString *title,*explain;
    
    NSArray *co=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:1000],[NSNumber numberWithInt:750],[NSNumber numberWithInt:500],[NSNumber numberWithInt:250],nil];
    for (int y=0; y<5; y++) {
        sum=sum+[[_check objectAtIndex:y] intValue];
        if([[_check objectAtIndex:y] intValue]==1){
            index=y;
        }
    }
    
    if(sum>0){
        if([self coincheck:[[co objectAtIndex:index] longValue]]){
            if(index==0){
                int temp1=[self buywholeheart];
                if(temp1==1){
                    
                    explain=[[NSString alloc]initWithFormat:@"Heart One purchased!"];
                    title=[[NSString alloc]initWithFormat:@"Heart"];
                    [self updatelist:@"heart1" add:0 heartnum:0];
                    [self detuctcoin:[[co objectAtIndex:index] longValue]];
                    
                }
                
                //update heart 1
                
                else if (temp1==2){
                    
                    explain=[[NSString alloc]initWithFormat:@"Heart two purchased!"];
                    title=[[NSString alloc]initWithFormat:@" "];
                    [self updatelist:@"heart2" add:0 heartnum:0];
                    [self detuctcoin:[[co objectAtIndex:index] longValue]];
                    //update heart 2
                }
                else{
                    explain=[[NSString alloc]initWithFormat:@"Already purchased both hearts!"];
                    title=[[NSString alloc]initWithFormat:@"Alert!"];
                }
            }
            else if(index>0){
                int temp=[self checkhearts];
                if(temp==1){
                    explain=[[NSString alloc]initWithFormat:@"Buy whole heart first"];
                    title=[[NSString alloc]initWithFormat:@" "];
                }
                
                else if(temp==2){
                    explain=[[NSString alloc]initWithFormat:@"Buy whole heart two"];
                    title=[[NSString alloc]initWithFormat:@" "];
                }
                
                else{
                    //already buy whole heart
                    //3/3heart
                    if(index==1){
                        if(heartli==0){
                            explain=[[NSString alloc]initWithFormat:@"item purchased!"];
                            title=[[NSString alloc]initWithFormat:@" "];
                            
                            [self updatelist:@"heart1life" add:1 heartnum:heartnum];
                            [self detuctcoin:[[co objectAtIndex:index] longValue]];
                            
                        }
                        else{
                            explain=[[NSString alloc]initWithFormat:@"you need other hearts"];
                            title=[[NSString alloc]initWithFormat:@"Alert "];
                        }
                        
                    }
                    //2/3 heart
                    else if(index==2){
                        if(heartli==1 ){
                            NSLog(@"item purchased");
                            explain=[[NSString alloc]initWithFormat:@"item purchased!"];
                            title=[[NSString alloc]initWithFormat:@" "];
                            [self updatelist:@"heart1life" add:3 heartnum:heartnum];
                            [self detuctcoin:[[co objectAtIndex:index] longValue]];
                            
                        }
                        else{
                            explain=[[NSString alloc]initWithFormat:@"you need other hearts"];
                            title=[[NSString alloc]initWithFormat:@"Alert "];
                        }
                        
                    }
                    // 1/3heart
                    else if(index==3){
                        if(heartli==4){
                            NSLog(@"item purchased");
                            explain=[[NSString alloc]initWithFormat:@"item purchased!"];
                            title=[[NSString alloc]initWithFormat:@" "];
                            [self updatelist:@"heart1life" add:4 heartnum:heartnum];
                            [self detuctcoin:[[co objectAtIndex:index] longValue]];
                            
                        }
                        else{
                            explain=[[NSString alloc]initWithFormat:@"you need other hearts"];
                            title=[[NSString alloc]initWithFormat:@"Alert "];
                        }
                        
                    }
                    
                }
                
            }
            
        }
        else{
            
            explain=[[NSString alloc]initWithFormat:@"Not enough coins, sorry!"];
            title=[[NSString alloc]initWithFormat:@""];
            
        }
        
    }
    
    else{
        title=[NSString stringWithFormat: @"ALert!"];
        explain=[NSString stringWithFormat:@"select any object inorder to buy"];
    }
    
    
    UIAlertView *alertView;
    if([explain isEqual:@"Not enough coins, sorry!"]){
        
        alertView = [[UIAlertView alloc]
                     initWithTitle:nil
                     message:explain
                     delegate:self
                     cancelButtonTitle:@"Okay, I'll keep playing."
                     otherButtonTitles:nil];
        
    }else{
        
        alertView = [[UIAlertView alloc]
                     initWithTitle:title
                     message:explain
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil];
    }
    
    
    [alertView show];
    
}

-(void)heartwithindex:(int)index {
    
    //3/3heart
    if(index==1){
        if(heartli==0){
            NSLog(@"item purchased");
        }
        else{
            NSLog(@"You need other hearts");
            
            
        }
        
    }
    //2/3 heart
    else if(index==2){
        if(heartli==1 ){
            NSLog(@"item purchased");
        }
        else{
            NSLog(@"you need other hearts");
            
        }
        
    }
    // 1/3heart
    else if(index==3){
        if(heartli==4){
            NSLog(@"item purchased");
        }
        else{
            NSLog(@"you need other heart");
        }
        
    }
}

-(int)buywholeheart {
    int flag=0;
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *hearts=[tdict objectForKey:@"heart1"];
    NSNumber *heart2=[tdict objectForKey:@"heart2"];
    
    if([hearts intValue]==0){
        flag=1;
    }
    else if([heart2 intValue]==0){
        flag=2;
    }
    else{
        flag=0;
    }
    
    return flag;
    
}

-(int)checkhearts {
    int flag=0;
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *hearts=[tdict objectForKey:@"heart1"];
    NSNumber *heart2=[tdict objectForKey:@"heart2"];
    NSNumber *heartlife=[tdict objectForKey:@"heart1life"];
    NSNumber *heartlife2=[tdict objectForKey:@"heart2life"];
    NSLog(@"heartlife%d",[heartlife intValue]);
    if([hearts intValue]!=0){
        if ([heartlife intValue]<5) {
            heartli=[heartlife intValue];
            heartnum=1;
            flag=3;
        }
        else{
            if([heart2 intValue]!=0){
                if([heartlife2 intValue]<5){
                    
                    heartli=[heartlife2 intValue];
                    heartnum=2;
                    flag=3;
                }
            }
            else {
                heartnum=0;
                flag=2;
            }
        }
        
    }
    else {
        heartnum=0;
        flag=1;
    }
    
    
    
    return flag;
}

-(void)updatelist:(NSString *)key add:(int)add heartnum:(int)heartnum {
    [self connection];
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    int temp;
    NSNumber *a;
    if([key isEqualToString:@"heart1life"]){
        if(heartnum==1){
            a=[tdict objectForKey:@"heart1life"];
        }
        else{
            a=[tdict objectForKey:@"heart2life"];
            key=[NSString stringWithFormat:@"heart2life"];
        }
        
        temp=[a intValue];
        temp=temp+add;
        
        [tdict setObject:[NSNumber numberWithInt:temp]forKey:key];
        [tdict writeToFile:highscorelist atomically:YES];
    }
    else{
        [tdict setObject:[NSNumber numberWithInt:1] forKey:key];
        [tdict writeToFile:highscorelist atomically:YES];
    }
}

-(void)alertreview {
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Do you love Catch Crisis?"
                                                      message:@"Please take the time out of your day to review it! I’m really listening"
                                                     delegate:self
                                            cancelButtonTitle:@"Sure, why not!"
                                            otherButtonTitles:@"No thanks.",nil];
    
    message.tag=99;
    [message show];
    
    
}

-(void)delayTime {
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
}

-(void)buycp {
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSString *title,*explain;
    BOOL alert = NO;
    
    if([[_check objectAtIndex:0] isEqualToNumber:[NSNumber numberWithInt:1]]){
        NSLog(@"alert dont have to buy this you already have it");
        
        explain=[[NSString alloc]initWithFormat:@"Already Purchased!"];
        title=[[NSString alloc]initWithFormat:@"Alert"];
        alert = YES;
        return;
    } else {
        if(shop == 0) {
            NSNumber *isBought=[tdict objectForKey:@"monkey"];
            if([isBought intValue] == 1) {
                explain=[[NSString alloc]initWithFormat:@"Already Purchased!"];
                title=[[NSString alloc]initWithFormat:@"Alert"];
                alert = YES;
            } else {
                [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
                [NSTimer scheduledTimerWithTimeInterval:3
                                                 target:self
                                               selector:@selector(delayTime)
                                               userInfo:nil
                                                repeats:NO];
                [[LStoreManagerIOS sharedInstance] buyProduct:@_MONKEY_PRODUCT_ID];
                
            }
        } else if(shop == 1) {
            NSNumber *isBought=[tdict objectForKey:@"banana"];
            if([isBought intValue] == 1) {
                explain=[[NSString alloc]initWithFormat:@"Already Purchased!"];
                title=[[NSString alloc]initWithFormat:@"Alert"];
                alert = YES;
            } else {
                [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
                [NSTimer scheduledTimerWithTimeInterval:3
                                                 target:self
                                               selector:@selector(delayTime)
                                               userInfo:nil
                                                repeats:NO];
                [[LStoreManagerIOS sharedInstance] buyProduct:@_BANANA_PRODUCT_ID];
            }
        }
    }
    
    if(alert == YES) {
        UIAlertView* alertView;
        alertView = [[UIAlertView alloc]
                     initWithTitle:title
                     message:explain
                     delegate:self
                     cancelButtonTitle:@"Okay, got it."
                     otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)restore {
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(delayTime)
                                   userInfo:nil
                                    repeats:NO];
    
    [[LStoreManagerIOS sharedInstance] restore];
}

-(void)purchaseFailed:(NSString *)productId message:(NSString *)errMsg {
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
}

-(void)purchaseSuccessed:(NSString *)productId {
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *isBought1=[tdict objectForKey:@"monkey"];
    NSNumber *isBought2=[tdict objectForKey:@"banana"];
    if([isBought1 intValue]+[isBought2 intValue] == 0) {
        [self alertreview];
    }
    
    if([productId isEqual: @_MONKEY_PRODUCT_ID]) {
        [tdict setObject:[NSNumber numberWithInt:1] forKey:@"monkey"];
        [tdict writeToFile:highscorelist atomically:YES];
    } else {
        [tdict setObject:[NSNumber numberWithInt:1] forKey:@"banana"];
        [tdict writeToFile:highscorelist atomically:YES];
    }
    
}

-(void)restoreFailed:(NSString *)errMsg {
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
}

-(void)restoreSuccessed:(NSArray *)productIdList {
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
    
    if (productIdList.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Failed"
                                  message:@"Restore no purchase"
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString* explain;
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    for (NSString* productId in productIdList) {
        if ([productId isEqualToString:@_MONKEY_PRODUCT_ID]) {
            [tdict setObject:[NSNumber numberWithInt:1] forKey:@"monkey"];
            [tdict writeToFile:highscorelist atomically:YES];
            explain = @"Monkey: Your purchase restored.";
        } else if([productId isEqualToString:@_BANANA_PRODUCT_ID]) {
            [tdict setObject:[NSNumber numberWithInt:1] forKey:@"banana"];
            [tdict writeToFile:highscorelist atomically:YES];
            explain = @"Banana: Your purchase restored.";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Success"
                                  message:explain
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)reviewmailpopUp {
    NSLog(@"pop up");
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *version = @"1.0";
    NSString *build = @"100";
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer.mailComposeDelegate =self;
        [mailComposer setToRecipients:[NSArray arrayWithObjects: @"support@catchcrisis.com",nil]];
        [mailComposer setSubject:[NSString stringWithFormat: @"MailMe V%@ (build %@) Support",version,build]];
        NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version:%@\n\n",model,iOSVersion];
        supportText = [supportText stringByAppendingString: @"Please describe your problem or question."];
        [mailComposer setMessageBody:supportText isHTML:NO];
        
        //[mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [self.view.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
        
    }
    else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mail Alert!"
                                                          message:@"Your mobile is not able to send email  please configure email first"
                                                         delegate:self
                                                cancelButtonTitle:@"ok"                                                otherButtonTitles:nil];
        
        [message show];
    }
    
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    int f=0;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            f=1;
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(f==1){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mail"
                                                          message:@"Your message sent successfully"
                                                         delegate:self
                                                cancelButtonTitle:@"ok"                                                otherButtonTitles:nil];
        
        [message show];
    }
}

-(void)dragaction:(int)p_n firstnode:(SKNode*)first srcondnode:(SKNode *) second move:(int)x_y defaultpos:(CGPoint)defultpos {
    
    drag_on = YES;
    if(screen_identifier==0){
        //[_tableView removeFromSuperview];
    }
    SKAction *afirst;
    SKAction *asecond;
    float temp,temp2;
    if(x_y==0){
        if (p_n==0) {
            temp=CGRectGetMaxY(self.frame);
            temp2=temp+(temp/2)+1;
        }
        else{
            temp=CGRectGetMidY(self.frame);
            temp2=-temp;
            
        }
        
        
        afirst=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
        [first runAction:afirst];
        
        asecond=[SKAction moveToY:temp2 duration:0.5];
        [second runAction:asecond completion:^{
            //          second.position=defultpos;
            if(table==1){
                _tableView.frame=_temptableView.frame;
                //              [two.scene.view  addSubview:_tableView];
                table=0;
            }
            drag_on = NO;
        }];
        
    }
    else{
        if(p_n==0){
            temp=CGRectGetMaxX(self.frame);
            temp2=temp+(temp/2)+1;
        }
        else{
            temp=CGRectGetMidX(self.frame);
            temp2=-temp;
        }
        
        afirst=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
        [first runAction:afirst];
        
        asecond=[SKAction moveToX:temp2 duration:0.5];
        
        [second runAction:asecond completion:^{
            second.position=defultpos;
            [self.view setUserInteractionEnabled:YES];
            
            drag_on = NO;
            
        }
         ];
    }
}

#pragma mark TouchEnded
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!swipe_enable) return;
    
    [self arrowpostion:1];
    
    locked=0;
    outerlock=0;
    shopbuttonscroll=0;
    shopcurrent={0,0};
    shopmoveloc={0,0};
    
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Determine distance from the starting point
    CGFloat dx = location.x - currentlc.x;
    CGFloat dy = location.y - currentlc.y;
    CGFloat magnitude = sqrt(dx*dx+dy*dy);
    
    // Determine time difference from start of the gesture
    CGFloat dt = touch.timestamp - startTime;
    
    // Determine gesture speed in points/sec
    
    CGFloat speed = magnitude/ dt;
    
    if (speed >=300) {
        
        if(screen_identifier==0){
            //       [_tableView removeFromSuperview];
        }
        
        
        // Calculate normalized direction of the swipe
        dx = dx / magnitude;
        dy = dy / magnitude;
        NSLog(@"Swipe detected with speed = %g and direction (%g, %g) %d",speed, dx, dy,fmove);
        
        if(fmove==0 && screen_identifier!=4){
            right.position=rightdefault;
            left.position=leftdefault;
            
            if(currentlc.y>currentLocation.y){
                
                if(dy<0.00000 ){
                    //[self repeatanim:2];
                    //screen_identifier=1;
                    if(screen_identifier==0) {
                        [self dragaction:0 firstnode:third srcondnode:my move:0 defaultpos:mypos];
                        screen_identifier=1;
                        currentnode = third;
                        
                        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/menu-music-loop-sample" ofType:@"mp3"]];
                        bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                        [bplay setNumberOfLoops:-1];
                        [bplay prepareToPlay];
                        [bplay play];
                        
                        
                    } else if(screen_identifier==2){
                        
                        
                        //////////////////////////   Add in 2015.9.16 /////////////////////////////////////////////////////////////
                        
                        [self dragaction:0 firstnode:my srcondnode:two move:0 defaultpos:twodefault];
                        screen_identifier=0;
                        currentnode=my;
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            _tableView.center = CGPoint{_tableView.center.x, -_tableView.frame.size.height};
                        } completion:^(BOOL finished) {
                            //[_tableView removeFromSuperview];
                        }];
                        
                        
                    }
                    
                }
            }
            
            if(currentlc.y<currentLocation.y){
                
                if(dy>0){
                    if(screen_identifier==0)
                    {
                        NSLog(@"table view123");
                        table=1;
                        screen_identifier=2;
                        currentnode=two;
                        [self dragaction:1 firstnode:two srcondnode:my move:0 defaultpos:mypos];
                        [_tableView removeFromSuperview];
                        [two.scene.view  addSubview:_tableView];
                        [_tableView setFrame:CGRectMake(CGRectGetMidX(_temptableView.frame)/4, -1.2*CGRectGetMidY(_temptableView.frame)-(currentLocation.y-currentlc.y)/2,_temptableView.frame.size.width ,_temptableView.frame.size.height)];
                        
                        //////////////////////////   Add in 2015.9.16 /////////////////////////////////////////////////////////////
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            [_tableView setFrame:_temptableView.frame];
                        } completion:^(BOOL finished) {
                            _tableView.frame=_temptableView.frame;
                        }];
                        
                        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
                        
                    }
                    
                    if(screen_identifier==1){
                        
                        [self dragaction:1 firstnode:my srcondnode:third move:0 defaultpos:thriddefault];
                        screen_identifier=0;
                        currentnode=my;
                        //    [_tableView removeFromSuperview];
                        
                        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/Brahmsters-Inc.-Stream" ofType:@"mp3"]];
                        bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                        [bplay setNumberOfLoops:-1];
                        [bplay prepareToPlay];
                        [bplay play];
                    }
                    
                }}
        }
        
        else if (fmove==1){
            if(dx>0){
                
                
                if(screen_identifier==0){
                    [self dragaction:1 firstnode:right srcondnode:my move:1 defaultpos:mypos];
                    screen_identifier=4;}
                
                
            }
            else{
                
                if(screen_identifier==0){
                    
                    screen_identifier=3;
                    SKAction *moveright=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
                    [left runAction:moveright];
                    float temp=CGRectGetMaxX(self.frame);
                    SKAction *o=[SKAction moveToX:temp+(temp/2)+1 duration:0.5];
                    drag_on = YES;
                    
                    table_for=0;
                    [_tableView reloadData];
                    
                    
                    [my runAction:o completion:^{
                        my.position=mypos;
                        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
                        SKTransition *doors = [SKTransition fadeWithDuration:0.01];
                        [self.view presentScene:nextScene transition:doors];
                        drag_on = NO;
                    }];
                    
                    
                }
                
                if(screen_identifier==4){
                    
                    screen_identifier=0;
                    currentnode = my;
                    [self dragaction:0 firstnode:my srcondnode:right move:1 defaultpos:rightdefault];
                }
            }
        }
        else{
            
            //                twodefault=two.position;
            //                thriddefault=third.position;
            //                leftdefault=left.position;
            //                rightdefault=right.position;
            //                mypos=my.position;
            
        }
        
    }
    else{
        if(customswipe){
            
            if(currentlc.y-currentLocation.y>=self.frame.size.height/2.5 && firstmove==0){
                
                if(screen_identifier==0){
                    screen_identifier=1;
                    currentnode=third;
                    [self dragaction:0 firstnode:third srcondnode:my move:0 defaultpos:mypos];
                    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/menu-music-loop-sample" ofType:@"mp3"]];
                    bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                    [bplay setNumberOfLoops:-1];
                    [bplay prepareToPlay];
                    [bplay play];
                    
                    
                }
                else if(screen_identifier==2){
                    
                    [self animatescreen];
                    
                }else{
                    
                }
                
            }
            else if(currentLocation.y-currentlc.y>=self.frame.size.height/2.5 && firstmove==0){
                
                if(screen_identifier==0){
                    
                    table=1;
                    screen_identifier=2;
                    currentnode=two;
                    [self dragaction:1 firstnode:two srcondnode:my move:0 defaultpos:mypos];
                    
                    //////////////////////////   Add in 2015.9.16 /////////////////////////////////////////////////////////////
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        [_tableView setFrame:_temptableView.frame];
                    } completion:^(BOOL finished) {
                        _tableView.frame=_temptableView.frame;
                    }];
                    
                    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
                    
                } else{
                    if(screen_identifier==1){
                        [self animatescreen];
                    }
                }
                
            }
            else if(currentlc.x-currentLocation.x>=self.frame.size.width/2.5 && firstmove==1){
                
                if(screen_identifier==0){
                    screen_identifier=3;
                    SKAction *moveright=[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)) duration:0.5];
                    [left runAction:moveright];
                    float temp=CGRectGetMaxX(self.frame);
                    SKAction *o=[SKAction moveToX:temp+(temp/2)+1 duration:0.5];
                    
                    table_for=0;
                    [_tableView reloadData];
                    
                    currentnode=left;
                    drag_on = YES;
                    [my runAction:o completion:^{
                        my.position=mypos;
                        achievements *nextScene = [[achievements alloc] initWithSize:self.size];
                        SKTransition *doors = [SKTransition fadeWithDuration:0.01];
                        [self.view presentScene:nextScene transition:doors];
                        drag_on = NO;
                    }
                     ];
                    
                }
                else{
                    //check via simulator
                    if(screen_identifier==4){
                        [self animatescreen];
                    }
                }
                
            }
            else if(currentLocation.x-currentlc.x>=self.frame.size.width/2.5 && firstmove==1){
                
                if(screen_identifier==0){
                    
                    [self dragaction:1 firstnode:right srcondnode:my move:1 defaultpos:mypos];
                    screen_identifier=4;
                }
                else{
                    if(screen_identifier==3){
                        [self animatescreen];}
                }
            }
            else{
                [self mainMenurepeat];
            }
        }
        else{
            two.position=twodefault;
            third.position=thriddefault;
            left.position=  leftdefault;
            right.position= rightdefault;
            my.position=mypos;
            
        }
    }
    
    [Flurry logEvent:[self screename]];
    NSLog(@"Log event:- %@", [self screename]);
    [self firstonmenuscreen:screen_identifier];
    
    checkScroll = YES;
    
}

-(void)mainMenurepeat
{
    if(screen_identifier==0){
        
        if(currentlc.y>currentLocation.y){
            
            [self repeatanim:1];}
        if(currentlc.y< currentLocation.y){
            [self repeatanim:0];
        }
        
        if(currentlc.x>currentLocation.x){
            [self.view setUserInteractionEnabled:NO];
            [self repeatanim:4];
        }
        if(currentlc.x<currentLocation.x){
            [self.view setUserInteractionEnabled:NO];
            [self repeatanim:7];
        }
        
    }
    
    else if(screen_identifier==1){
        [self repeatanim:2];
    }
    
    else if(screen_identifier==2){
        [self repeatanim:3];
        
    }
    else if(screen_identifier==3){
        [self repeatanim:5];
        
    }
    else if(screen_identifier==4){
        [self repeatanim:6];
        
    }
    
}

-(void)repeatanim:(int)b
{
    
    if(b==0)
    {
        
        [self dragaction:0 firstnode:my srcondnode:two move:0 defaultpos:twodefault ];
        
    }
    else if(b==1)
    {
        
        [self dragaction:1 firstnode:my srcondnode:third move:0 defaultpos:thriddefault];
        
    }
    
    else if(b==2)
    {
        
        [self dragaction:0 firstnode:third srcondnode:my move:0 defaultpos:mypos];
        
    }
    
    else if(b==3)
    {
        table=1;
        [self dragaction:1 firstnode:two srcondnode:my move:0 defaultpos:mypos];
        //_tableView.frame=_temptableView.frame;
        
        [UIView animateWithDuration:0.5 animations:^{
            [_tableView setFrame:_temptableView.frame];
        } completion:^(BOOL finished) {
            _tableView.frame=_temptableView.frame;
        }];
        
    }
    else if(b==4){
        
        
        [self dragaction:1 firstnode:my srcondnode:left move:1 defaultpos:leftdefault];
        
    }
    
    else if(b==5){
        
        [self dragaction:0 firstnode:left srcondnode:my move:1 defaultpos:mypos];
    }
    
    else if(b==6){
        
        [self dragaction:1 firstnode:right srcondnode:my move:1 defaultpos:mypos];
    }
    
    
    else if(b==7){
        [self dragaction:0 firstnode:my srcondnode:right move:1 defaultpos:rightdefault];
        
    }
    
}

-(void)animatescreen {
    if(screen_identifier==1 ){
        
        [self dragaction:1 firstnode:my srcondnode:third move:0 defaultpos:thriddefault];
        screen_identifier=0;
        currentnode=my;
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameMusic/Brahmsters-Inc.-Stream" ofType:@"mp3"]];
        bplay = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [bplay setNumberOfLoops:-1];
        [bplay prepareToPlay];
        [bplay play];
        
    }
    
    
    else if(screen_identifier==2){
        
        [self dragaction:0 firstnode:my srcondnode:two move:0 defaultpos:twodefault];
        screen_identifier=0;
        currentnode=my;
        [UIView animateWithDuration:0.5 animations:^{
            _tableView.center = CGPoint{_tableView.center.x, -_tableView.frame.size.height};
        }];
    }
    
    else if(screen_identifier==3){
        
        [self dragaction:1 firstnode:my srcondnode:left move:1 defaultpos:leftdefault];
        screen_identifier=0;
        currentnode=my;
    }
    
    else if(screen_identifier==4){
        
        [self dragaction:0 firstnode:my srcondnode:right move:1 defaultpos:rightdefault];
        screen_identifier=0;
        currentnode=my;
    }
    
}

#pragma mark TouchMoved
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!swipe_enable) return;
    
    NSLog(@"screen identifier %d",screen_identifier);
    currentLocation =[[touches anyObject] locationInNode:self];
    UITouch *touch = [touches anyObject];
    shopmoveloc =[touch  locationInNode:self];
    CGPoint lastPosition = [touch previousLocationInNode:self];
    //NSArray *a=[[self gameWorldNode] nodesAtPoint:location];
    /* for(SKNode *node in a)
     {//right
     NSLog(@"%@ku,n",[node name]);
     
     }*/
    if(outerlock==0){
        instantlocation=[[touches anyObject]locationInNode:self];
        if(((currentlc.y>instantlocation.y) || (currentlc.y<instantlocation.y)) && ((currentlc.y-instantlocation.y>20)|| (instantlocation.y-currentlc.y>20)) ){
            NSLog(@"move vertical");
            fmove=0;
            flag_i=1;
            locked=0;
            firstmove=0;
            
        }
        else if((currentlc.x>instantlocation.x) || (currentlc.x<instantlocation.x)){
            NSLog(@"move horizontal");
            
            fmove=1;
            flag_i=2;
            locked=1;
            firstmove=1;
        }
        else{
            
            NSLog(@"move vertical");
            fmove=0;
            flag_i=1;
            locked=0;
            firstmove=0;
        }
        
        outerlock=1;
    }
    
    if(shopbuttonscroll==0) {
        if(screen_identifier==0) {
            [self extrahearts];
            if(locked==0){
                if(flag_i==1){
                    if(currentlc.y>instantlocation.y){
                        NSLog(@"down");
                        textstring=[NSString stringWithFormat:@"menu_shop"];
                        arrowstring=[NSString stringWithFormat:@"menu_button4"];
                        
                        if(currentlc.y>currentLocation.y){
                            [my setPosition:CGPointMake(CGRectGetMidX(my.frame),CGRectGetMidY(self.frame)+(currentlc.y-currentLocation.y) )];
                            //second.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-((man.frame.size.height)-(currentLocation.y-currentlc.y)));
                            
                            [third setPosition:CGPointMake(CGRectGetMidX(third.frame), (CGRectGetMidY(self.frame)-(third.frame.size.height))+(currentlc.y-currentLocation.y))];
                        }
                        else{
                            customswipe=NO;
                        }
                        
                    }
                    if(currentlc.y<instantlocation.y){
                        NSLog(@"up");
                        textstring=[NSString stringWithFormat:@"menu_achievements"];
                        arrowstring=[NSString stringWithFormat:@"menu_button2"];
                        
                        if(currentLocation.y>currentlc.y){
                            
                            [my setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-(currentLocation.y-currentlc.y) )];
                            [two setPosition:CGPointMake(CGRectGetMidX(two.frame),(CGRectGetMidY(self.frame)+(two.frame.size.height))-(currentLocation.y-currentlc.y))];
                            
                            if(currentLocation.y-currentlc.y>20){
                                [_tableView removeFromSuperview];
                                [two.scene.view  addSubview:_tableView];
                            }
                            
                            [_tableView setFrame:CGRectMake(CGRectGetMidX(_temptableView.frame)/4, -1.2*CGRectGetMidY(_temptableView.frame)-(currentlc.y-        currentLocation.y)/2,_temptableView.frame.size.width ,_temptableView.frame.size.height)];
                            
                        }
                        else{
                            customswipe=NO;
                        }
                        
                    }
                }
            }
            if(locked==1){
                if(flag_i==2){
                    // from left to right
                    if(currentlc.x<instantlocation.x){
                        NSLog(@"left");
                        textstring=[NSString stringWithFormat:@"menu_storyMode"];
                        arrowstring=[NSString stringWithFormat:@"menu_button3"];
                        
                        if(currentlc.x<currentLocation.x){
                            [my setPosition:CGPointMake(CGRectGetMidX(self.frame)-(currentLocation.x-currentlc.x),CGRectGetMidY(my.frame) )];
                            
                            [right setPosition:CGPointMake((CGRectGetMidX(self.frame)+(right.frame.size.width))-(currentLocation.x-currentlc.x),CGRectGetMidY(right.frame))];
                        }
                        
                        else{
                            customswipe=NO;
                        }
                        
                    }
                }
                
                //from right to left
                
                
                if(currentlc.x>instantlocation.x){
                    NSLog(@"right");
                    textstring=[NSString stringWithFormat:@"menu_quickPlay"];
                    arrowstring=[NSString stringWithFormat:@"menu_button1"];
                    if(currentlc.x>currentLocation.x){
                        [my setPosition:CGPointMake(CGRectGetMidX(self.frame)+(currentlc.x-currentLocation.x),CGRectGetMidY(my.frame) )];
                        
                        [left setPosition:CGPointMake((CGRectGetMidX(self.frame)-(left.frame.size.width))+(currentlc.x-currentLocation.x),CGRectGetMidY(left.frame))];
                    }
                    else{
                        customswipe=NO;
                    }
                }
            }
        }
        
        //////////////////////////////////////  Modified in 2015.9.16  ///////////////////////////////////////////////////////////////////////////
        if(screen_identifier==1){
            if(instantlocation.y>currentlc.y) {
                if((fmove==0)&&(checkScroll)) {
                    if(currentLocation.y>currentlc.y){
                        [third setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-(currentLocation.y-currentlc.y) )];
                        
                        [my setPosition:CGPointMake(CGRectGetMidX(my.frame),(CGRectGetMidY(self.frame)+(my.frame.size.height))-(currentLocation.y-currentlc.y))];
                    }
                }
            }
            /*    if(currentlc.y>instantlocation.y){
             if((fmove==0)&&(checkScroll)){
             if(currentLocation.y<currentlc.y){
             [third setPosition:CGPointMake(CGRectGetMidX(two.frame),CGRectGetMidY(self.frame)+(currentlc.y-currentLocation.y) )];
             [_tableView setFrame:CGRectMake(CGRectGetMidX(_tableView.frame)/4,CGRectGetMidY(_tableView.frame)/2-(currentlc.y-currentLocation.y)/4,_tableView.frame.size.width ,_tableView.frame.size.height)];
             
             [my setPosition:CGPointMake(CGRectGetMidX(my.frame), (CGRectGetMidY(self.frame)-(my.frame.size.height))+(currentlc.y-currentLocation.y))];
             }
             }
             }*/
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if(screen_identifier==2){
            if(fmove==0){
                if(currentlc.y>instantlocation.y){
                    
                    if(currentLocation.y<currentlc.y){
                        [two setPosition:CGPointMake(CGRectGetMidX(two.frame),CGRectGetMidY(self.frame)+(currentlc.y-currentLocation.y) )];
                        //second.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-((man.frame.size.height)-(currentLocation.y-currentlc.y)));
                        [_tableView setFrame:CGRectMake(CGRectGetMidX(_tableView.frame)/4,CGRectGetMidY(_tableView.frame)/2-(currentlc.y-currentLocation.y)/4,_tableView.frame.size.width ,_tableView.frame.size.height)];
                        
                        [my setPosition:CGPointMake(CGRectGetMidX(my.frame), (CGRectGetMidY(self.frame)-(my.frame.size.height))+(currentlc.y-currentLocation.y))];
                    }
                }
            }
        }
        
        if(screen_identifier==3){
            if(fmove==1){
                if(instantlocation.x>currentlc.x) {
                    [left setPosition:CGPointMake(CGRectGetMidX(self.frame)-(currentLocation.x-currentlc.x),CGRectGetMidY(my.frame) )];
                    [my setPosition:CGPointMake((CGRectGetMidX(self.frame)+(my.frame.size.width))-(currentLocation.x-currentlc.x),CGRectGetMidY(my.frame))];
                }
            }
        }
        
        if(screen_identifier==4){
            if(fmove==1){
                if(currentlc.x>instantlocation.x){
                    if(currentLocation.x<currentlc.x){
                        [right setPosition:CGPointMake(CGRectGetMidX(self.frame)+(currentlc.x-currentLocation.x),CGRectGetMidY(right.frame) )];
                        
                        [my setPosition:CGPointMake((CGRectGetMidX(self.frame)-(my.frame.size.width))+(currentlc.x-currentLocation.x),CGRectGetMidY(my.frame))];
                    }
                }
            }
        }
    }
    
    if(shopbuttonscroll==1){
        if(shop==2 || shop==3){
            if(shopcurrent.y>shopmoveloc.y){
                if(scrollbutton.position.y>minshopButtonpos){
                    [scrollbutton setPosition:CGPointMake(scrollbutton.position.x,scrollbutton.position.y+(shopmoveloc.y - lastPosition.y))];
                    dragvalue+=2;
                    [_scrollingNode scrolltoCustom:dragvalue];
                }
            }
            
            if(shopcurrent.y<shopmoveloc.y){
                if(scrollbutton.position.y<maxshopButtonpos){
                    [scrollbutton setPosition:CGPointMake(scrollbutton.position.x,scrollbutton.position.y+(shopmoveloc.y-lastPosition.y))];
                    dragvalue-=2.2;
                    [_scrollingNode scrolltoCustom:dragvalue];
                }
            }
            
            if(dragvalue<-325){
                dragvalue=-325;
            }
            if(dragvalue>-135){
                dragvalue=-135;
            }
            //          NSLog(@"button%g",scrollbutton.position.y);
            if(scrollbutton.position.y>98){
                [_scrollingNode scrolltoCustom:-325];
                dragvalue=-325;
            }
            if(scrollbutton.position.y<-90){
                [_scrollingNode scrolltoCustom:-121];
                dragvalue=-135;
            }
        }
    }
    if(mybool){
        [self arrowpostion:0];
        mybool=NO;
    }
}


-(void)willMoveFromView:(SKView *)view {
    my.position=mypos;
    two.position=twodefault;
    third.position=thriddefault;
    right.position=rightdefault;
    left.position=leftdefault;
    screen_identifier=0;
    firstmove=0;
    flag_i=1,locked=0,outerlock=0,animatelock=0;
    currentlc={0.0,0.0};
    currentLocation={0.0,0.0};
    [bplay stop];
    [_scrollingNode disableScrollingOnView:view];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard {
    gmarray=[[NSMutableArray alloc]init];
    [[shared sharedInstance].gamecenter removeAllObjects];
    
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
                old = 0;
                for (GKScore *s in scores) {
                    LeaderboardData* data = [LeaderboardData alloc];
                    data.playerName = s.player.alias;
                    data.score = s.formattedValue;
                    
                    [gmarray insertObject:data atIndex:old];
                    // NSLog(@"ab%@",my);
                    old++;
                }
                //NSLog(@"%@12323",gmarray);
                [[shared sharedInstance].gamecenter addObjectsFromArray:gmarray];
                //NSLog(@"%@gamecenter",[shared sharedInstance].gamecenter);
            }
        }];
    }
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)makebutton {
    scrollbutton=(SKSpriteNode *)[self childNodeWithName:@"shop_scrollButton1"];
}

-(void)getScrollbutton {
    //scrollbutton.position=CGPointMake(scrollbutton.position.x,[shared sharedInstance].shopbutton+200);
}

-(void)moveSliderWithValue:(int)value {
    NSLog(@"in method");
    NSLog(@"delegateValue %d",value);
    
    if(shop==2 || shop==3) {
        int posY = scrollbutton.position.y - value * 2;
        
        if(posY<minshopButtonpos){
            posY=minshopButtonpos;
        }
        if(posY>maxshopButtonpos){
            posY=maxshopButtonpos;
        }
        
        [scrollbutton setPosition:CGPointMake(scrollbutton.position.x, posY)];
    }
}

-(void)extrahearts {
    [self connection];
    NSMutableDictionary *tdict=[[NSMutableDictionary alloc]initWithContentsOfFile:highscorelist];
    NSNumber *hearts=[tdict objectForKey:@"heart1"];
    NSNumber *hlife=[tdict objectForKey:@"heart1life"];
    NSNumber *falling=[tdict objectForKey:@"falingobject"];
    
    if([hearts intValue]==1){
        [self getlife:[hlife intValue] var:0];
        
        hearts=[tdict objectForKey:@"heart2"];
        
        if([hearts intValue]==1){
            hlife=[tdict objectForKey:@"heart2life"];
            [self getlife:[hlife intValue] var:1];
        } else {
            [shared sharedInstance].heart2life=0;
            [shared sharedInstance].heart2tex=@"imageresource/quickGame/quick_heartLock";
        }
    } else {
        [shared sharedInstance].heart1life=0;
        [shared sharedInstance].heart1tex=@"imageresource/quickGame/quick_heartLock";
        [shared sharedInstance].heart2life=0;
        [shared sharedInstance].heart2tex=@"imageresource/quickGame/quick_heartLock";
    }
    
    SKSpriteNode *node=(SKSpriteNode *)[self childNodeWithName:@"quick_scoreBox"];
    if ([falling intValue]==1) {
        [node setTexture:[SKTexture textureWithImageNamed:[self textureAtlasNamed:@"quick_scoreBoxmonkey"]]];
    }
}

-(void)getlife:(int)heartlife var:(int)var {
    NSLog(@"heartlife %d",heartlife);
    int temp=0;
    NSString *texture;
    if(heartlife>=0) {
        if(heartlife==1){
            temp=1;
            texture=[NSString stringWithFormat:@"heart_life_3"];
        }
        else if (heartlife==4){
            temp=2;
            texture=[NSString stringWithFormat:@"heart_life_2"];
        }
        else if (heartlife==8){
            temp=3;
            texture=[NSString stringWithFormat:@"imageresource/quickGame/quick_heart"];
        }
        else {
            temp=0;
            texture=[NSString stringWithFormat:@"emptyheart"];
        }
    }
    
    if(var==0){
        [shared sharedInstance].heart1life=temp;
        [shared sharedInstance].heart1tex=texture;
        [heart1 setTexture:[SKTexture textureWithImageNamed:[shared sharedInstance].heart1tex]];
    }
    else{
        [shared sharedInstance].heart2life=temp;
        [shared sharedInstance].heart2tex=texture;
        [heart2 setTexture:[SKTexture textureWithImageNamed:[shared sharedInstance].heart2tex]];
    }
}

#pragma mark Chartboost Delegate Methods
-(BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);
    
    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}

-(void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
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
    NSLog(@"%lu", (unsigned long)error);
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

-(void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
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

-(void)didCacheInterstitial:(NSString *)location {
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

-(void)didFailToLoadMoreApps:(CBLoadError)error {
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

-(void)didDismissInterstitial:(NSString *)location {
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

-(void)didDismissMoreApps:(NSString *)location {
    NSLog(@"dismissed more apps page at location %@", location);
}

/*
 * didDisplayInterstitial
 *
 * Called after an interstitial has been displayed on the screen.
 */

-(void)didDisplayInterstitial:(CBLocation)location {
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
-(void)didCacheInPlay:(CBLocation)location {
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
-(void)didFailToLoadInPlay:(CBLocation)location withError:(CBLoadError)error {
    
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
