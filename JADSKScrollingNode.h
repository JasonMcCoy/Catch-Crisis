//
//  JADSKScrollingNode.h
//  FirstLetters
//
//  Created by Jennifer Dobson on 7/25/14.
//  Copyright (c) 2014 Jennifer Dobson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MoveSliderDelegate.h"

//@interface JADSKScrollingNode : SKCropNode <UIGestureRecognizerDelegate>
@interface JADSKScrollingNode : SKNode <UIGestureRecognizerDelegate>


@property (nonatomic) CGSize size;
@property (weak) id<MoveSliderDelegate> sliderDelegate;


-(id)initWithSize:(CGSize)size;
-(void)scrollToTop;
-(void)scrollToBottom;
-(void)enableScrollingOnView:(UIView*)view;
-(void)disableScrollingOnView:(UIView*)view;
-(void)scrolltoMiddle;
-(void)scrolltoCustom:(float)value;

@end
