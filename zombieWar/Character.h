//
//  Character.h
//  Coco2D-Turret
//
//  Created by Andrew Ma on 11/21/13.
//  Copyright (c) 2013 Andrew Ma. All rights reserved.
//

#import "CCSprite.h"

@interface Character : CCSprite
{
    int maxHit_;
}

@property (nonatomic) int maxHit;
@end
