//
//  GameLayer.h
//  Coco2D-Turret
//
//  Created by Andrew Ma on 11/16/13.
//  Copyright Andrew Ma 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Monster.h"
#import "Player.h"

typedef enum {GAMEPLAY=0, GAMEOVER, LEVELUP, NO_STATE} STATE_T;
// GameLayer
@interface GameLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    NSMutableArray * _monsters;
    NSMutableArray * _projectiles;
    CCSprite *_nextProjectile;
    Player *_player;
    CCMenu *_menu;
    CCLabelTTF *_label;
    
    BOOL _stopMonster;
    int level;
    int monsterCount;
    STATE_T gamestate;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
