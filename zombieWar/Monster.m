//
//  Monster.m
//  Coco2D-Turret
//
//  Created by Andrew Ma on 11/21/13.
//  Copyright (c) 2013 Andrew Ma. All rights reserved.
//

#import "Monster.h"

@implementation Monster

- (Monster *) init
{
    self = [Monster spriteWithFile:@"zombie_pixel.png"];
    self.maxHit = 5;
    
    return self;
}

@end
