//
//  pause.m
//  catch crises
//
//  Created by The Engineer on 18/04/2015.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "pause.h"

@implementation pause

+(id)scene
{
    
    return [[achievement alloc] initWithContentOfFile:@"publishresource/pause.lhplist"];
    
    
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        
    }
    
    return self;
}

@end
