//
//  Player.m
//  Coco2D-Turret
//
//  Created by Andrew Ma on 11/21/13.
//  Copyright (c) 2013 Andrew Ma. All rights reserved.
//

#import "Player.h"

@implementation Player
- (Player *) init
{
    self = [Player spriteWithFile:@"tank.png"];
    self.maxHit = 5;
    
    return self;
}
@end
