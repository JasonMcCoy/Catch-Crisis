//
//  LHSceneSubclass.h
//  SpriteKitAPI-DEVELOPMENT
//

//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LevelHelper2API.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "JADSKScrollingNode.h"
#import <Chartboost/Chartboost.h>
#import <MessageUI/MessageUI.h>
#import "MoveSliderDelegate.h"
#import "LStoreManagerIOS.h"

@interface LHSceneSubclass : LHScene <UITableViewDataSource, UITableViewDelegate, ChartboostDelegate, MFMailComposeViewControllerDelegate,GKGameCenterControllerDelegate,MoveSliderDelegate, LPurchaseDelegateIOS>

+(id)scene;
@property (retain, nonatomic) IBOutlet UITableView *tableView,*temptableView;
@property (strong, nonatomic) NSMutableArray *challege_name;
@property (strong, nonatomic) NSMutableArray *challege;
@property (strong, nonatomic) NSMutableArray *bools;
@property (nonatomic,strong) JADSKScrollingNode* scrollingNode;
@property ( retain,strong) JADSKScrollingNode* anscrollingNode;
@property (nonatomic,strong) NSMutableArray *nodesitems;
@property (strong,nonatomic) NSMutableArray *pointsarray;
@property (retain,strong) NSMutableArray  *check;
-(void)getScrollbutton;
-(void)alertRewardVideo;
-(void)resumeMusic;
-(void)showcoins;

@end
