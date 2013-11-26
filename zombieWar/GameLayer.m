//
//  GameLayer.m
//  COCOS-2DTest
//
//  Created by Andrew Ma on 11/14/13.
//  Copyright Andrew Ma 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "Monster.h"
#pragma mark - HelloWorldLayer

// GameLayer implementation
@implementation GameLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    GameLayer *layer = [GameLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    NSString *filepath;
    
    @try {
        // always call "super" init
        // Apple recommends to re-assign "self" with the "super's" return value
        level = 0;
        filepath = [[NSBundle mainBundle] pathForResource:@"levelinfo" ofType:@"plist"];
        if( (self=[super initWithColor:ccc4(255,255,255,255)]) ) {
            gamestate = NO_STATE;
            levelDict = [[NSDictionary alloc] initWithContentsOfFile:filepath];
            [[SimpleAudioEngine sharedEngine] preloadEffect:@"Zombie_In_Pain.wav"];
            [[SimpleAudioEngine sharedEngine] preloadEffect:@"Bomb_Exploding.wav"];
            [self startGame];
        }
    } @catch (NSException *e){
        NSLog(@"catch an exception %@", e);
    }
    
    return self;
}

-(void) startGame
{
    CGSize winsize;
    NSArray *levelInfo = [levelDict valueForKey:@"levelinfo"];
    NSDictionary *infoDict = levelInfo[level];
    NSNumber *num_of_monster = [infoDict valueForKey:@"num_of_monster"];
    
    
    if (gamestate != GAMEPLAY) {
        @try {
            [self cleanupLabelScreen];
            [self cleanupGameData];
            _stopMonster = NO;
            monsterCount = [num_of_monster intValue];
            
            [[CCDirector sharedDirector] setDisplayStats:NO];
            winsize = [CCDirector sharedDirector].winSize;
            
            background = [CCSprite spriteWithFile:@"background.png"];
            background.position = ccp(winsize.width/2, winsize.height/2);
            [self addChild:background];

            _player = [[Player alloc] init];
            _player.position = ccp(_player.contentSize.width/2, winsize.height/2);
            
            _monsters = [[NSMutableArray alloc] init];
            _projectiles = [[NSMutableArray alloc] init];
            _nextProjectile = nil;
            
            [self setColor:ccc3(255,255,255)];
            [self addChild:_player];
            [self setTouchEnabled:YES];
            [self schedule:@selector(gameLogic:) interval:1.0];
            [self schedule:@selector(update:)];
        } @catch (NSException *e) {
            NSLog(@"catch an exception %@", e);
        } @finally {
            /* No need to do anything */
        }
#if 0
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:2.0f];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"hell.wav"];
#endif
    }
}

-(void) cleanupLabelScreen
{
    [self removeChild:_label cleanup:YES];
    [self removeChild:_menu cleanup:YES];
}

-(void) cleanupGameData
{
    [_monsters removeAllObjects];
    [_projectiles removeAllObjects];
    
    _monsters = nil;
    _projectiles = nil;
    _nextProjectile = nil;
    _player = nil;
}

-(void) cleanupGameScreen
{
    CCSprite *monster;
    CCSprite *projectile;
    
    _stopMonster = YES;
    // Cleanup monster
    for (monster in _monsters) {
        [self removeChild:monster cleanup:YES];
    }
    [_monsters removeAllObjects];

    [self removeChild:_player cleanup:YES];
    
    for (projectile in _projectiles) {
        [self removeChild:projectile cleanup:YES];
    }
    [_projectiles removeAllObjects];
    
    [self removeChild:background cleanup:YES];
}

-(void) endGameScreen
{
    CGSize size;
    CCMenuItem *itemRestart;
    NSString *endGameString;
    
    if (gamestate == GAMEPLAY) {
        [self cleanupGameScreen];
        // Change background color
        [self setColor:ccc3(0,0,0)];
        
        // create and initialize a Label
        endGameString = [NSString stringWithFormat:@"Congradulation you have completed this game"];
        _label = [CCLabelTTF labelWithString:endGameString fontName:@"Marker Felt" fontSize:24];
        _label.color = ccc3(255,0,0);
        
        // ask director for the window size
        size = [[CCDirector sharedDirector] winSize];
        
        // position the label on the center of the screen
        _label.position =  ccp( size.width /2 , size.height/2 + 20 );
        // add the label as a child to this Layer
        [self addChild: _label];
        
        // Restart Menu Item using blocks
        itemRestart = [CCMenuItemFont itemWithString:@"Restart" block:^(id sender) {
            /* Reset level back to zero */
            level = 0;
            [self startGame];
        }];
        
        
        _menu = [CCMenu menuWithItems:itemRestart, nil];
        [_menu alignItemsHorizontallyWithPadding:20];
        [_menu setPosition:ccp( size.width/2, size.height/2 - 30)];
        
        // Add the menu to the layer
        [self addChild:_menu];
        
        // Change background color
        [self setColor:ccc3(0,0,0)];
        gamestate = LEVELUP;
    }

}

-(void) levelupScreen
{
    CGSize size;
    CCMenuItem *itemContinue;
    NSString *levelString;

    if (gamestate == GAMEPLAY) {
        [self cleanupGameScreen];
        // Change background color
        [self setColor:ccc3(0,0,0)];
        
        // create and initialize a Label
        level++;
        levelString = [NSString stringWithFormat:@"Level up to %d", (level + 1)];
        _label = [CCLabelTTF labelWithString:levelString fontName:@"Marker Felt" fontSize:64];
        _label.color = ccc3(255,0,0);
        
        // ask director for the window size
        size = [[CCDirector sharedDirector] winSize];
        
        // position the label on the center of the screen
        _label.position =  ccp( size.width /2 , size.height/2 + 20 );
        // add the label as a child to this Layer
        [self addChild: _label];
        
        // Restart Menu Item using blocks
        itemContinue = [CCMenuItemFont itemWithString:@"Continue" block:^(id sender) {
            [self startGame];
        }];
        
        
        _menu = [CCMenu menuWithItems:itemContinue, nil];
        [_menu alignItemsHorizontallyWithPadding:20];
        [_menu setPosition:ccp( size.width/2, size.height/2 - 30)];
        
        // Add the menu to the layer
        [self addChild:_menu];
        
        // Change background color
        [self setColor:ccc3(0,0,0)];
        gamestate = LEVELUP;
    }
}

-(void) showGameover
{
    CGSize size;
    CCMenuItem *itemRestart;
    
    if (gamestate == GAMEPLAY) {
        [self cleanupGameScreen];
        // create and initialize a Label
        _label = [CCLabelTTF labelWithString:@"Game Over !!!" fontName:@"Marker Felt" fontSize:64];
        _label.color = ccc3(255,0,0);
        
        // ask director for the window size
        size = [[CCDirector sharedDirector] winSize];
        
        // position the label on the center of the screen
        _label.position =  ccp( size.width /2 , size.height/2 + 20 );
        // add the label as a child to this Layer
        [self addChild: _label];
        
        // Default font size will be 28 points.
        [CCMenuItemFont setFontSize:28];
        
        // Restart Menu Item using blocks
        itemRestart = [CCMenuItemFont itemWithString:@"Restart" block:^(id sender) {
            level = 1;
            [self startGame];
        }];
        
        
        _menu = [CCMenu menuWithItems:itemRestart, nil];
        [_menu alignItemsHorizontallyWithPadding:20];
        [_menu setPosition:ccp( size.width/2, size.height/2 - 20)];
        
        // Add the menu to the layer
        [self addChild:_menu];
        
        // Change background color
        [self setColor:ccc3(0,0,0)];
        gamestate = GAMEOVER;
    }
}

-(void) gamePlayHandle:(NSSet *)touches
{
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    CGPoint realDest;
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _nextProjectile = [CCSprite spriteWithFile:@"projectile2.png"];
    _nextProjectile.position = ccp(20, winSize.height/2);
    _nextProjectile.tag = 2;
    [_projectiles addObject:_nextProjectile];
    
    // Determine offset of location to projectile
    // Point arithmetic the location of the projectile.
    CGPoint offset = ccpSub(location, _nextProjectile.position);
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + _nextProjectile.position.y;
#if 0
    realDest = ccp(realX, realY);
#else
    realDest = location;
#endif
    
    // Determine the length of how far you're shooting
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    
    // Now determine the rotation angle
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    float rotateDegreesPerSecond = 180 / 0.5; // Would take 0.5 seconds to rotate 180 degrees, or half a circle
    float degreesDiff = _player.rotation - cocosAngle;
    float rotateDuration = fabs(degreesDiff / rotateDegreesPerSecond);
    
    [_player runAction:
     [CCSequence actions:
      [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
      [CCCallBlock actionWithBlock:^{
         // OK to add now - rotation is finished!
         [self addChild:_nextProjectile];
         [_projectiles addObject:_nextProjectile];
         
         // Release
         _nextProjectile = nil;
     }],
      nil]];
    
    // Move projectile to actual endpoint
    [_nextProjectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [[SimpleAudioEngine sharedEngine] playEffect:@"Bomb_Exploding.wav"];
         [node removeFromParentAndCleanup:YES];
     }],
      nil]];
    
    _nextProjectile.tag = 2;
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (gamestate == GAMEPLAY) {
        if (_nextProjectile == nil && _player != nil) {
            [self gamePlayHandle:touches];
        } else {
            NSLog(@"_nextProjectile is not nil");
        }
    }
}

#if 0
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    // in case you have something to dealloc, do it in this method
    // in this particular example nothing needs to be released.
    // cocos2d will automatically release all the children (Label)
    
    // don't forget to call "super dealloc"
    [super dealloc];
}
#endif

-(void)gameLogic:(ccTime)delta {
    if (_stopMonster == NO) {
        if (monsterCount > 0) {
            [self addMonster];
            monsterCount--;
        }
    }
}

-(void)update:(ccTime)delta {
    NSMutableArray *projectilesToDelete;
    NSMutableArray *monstersToDelete;

    
    projectilesToDelete = [[NSMutableArray alloc] init];
    monstersToDelete = [[NSMutableArray alloc] init];
    
    if ([_monsters count] == 0 && monsterCount == 0) {
        if (level < MAXLEVEL) {
            [self levelupScreen];
        } else {
            [self endGameScreen];
        }
    } else {
        for (CCSprite *projectile in _projectiles) {
            /* Check if any monster intersect with any projectile */
            for (CCSprite *monster in _monsters) {
                if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                    [monstersToDelete addObject:monster];
                }
            }
            
            /* Run through all need to delete monster in the delete list */
            for (CCSprite *monster in monstersToDelete) {
                [_monsters removeObject:monster];
                [self removeChild:monster cleanup:YES];
            }
            
            if (monstersToDelete.count > 0) {
                [projectilesToDelete addObject:projectile];
                [[SimpleAudioEngine sharedEngine]playEffect:@"Zombie_In_Pain.wav"];
            }
            [monstersToDelete removeAllObjects];
            //NSLog(@"monstersToDelete removeAllObjects");
        }

        for (CCSprite *projectile in projectilesToDelete) {
            [_projectiles removeObject:projectile];
            [self removeChild:projectile cleanup:YES];
        }
    }
    
}

-(void) addMonster
{
    Monster *monster;
    CGSize winsize;
    int minY;
    int maxY;
    int rangeY;
    int actualY;
    int minDuration = 2.0;
    int maxDuration;
    int rangeDuration;
    int actualDuration;
    CCMoveTo *actionMove;
    CCCallBlockN *actionMoveDone;
    NSArray *levelInfo = [levelDict valueForKey:@"levelinfo"];
    NSDictionary *infoDict = levelInfo[level];
    NSNumber *speed = [infoDict valueForKey:@"speed"];
    
    @try {
        maxDuration = [speed intValue];
        monster = [[Monster alloc] init];
        winsize = [CCDirector sharedDirector].winSize;
        minY = monster.contentSize.height + 20;
        maxY = winsize.height;
        rangeY = maxY - minY;
        actualY = (arc4random() % rangeY);
        rangeDuration = maxDuration - minDuration;
        
        monster.position = ccp(winsize.width - monster.contentSize.width / 2, actualY);
        monster.tag = 1;
        [_monsters addObject:monster];
        
        [self addChild:monster];
        gamestate = GAMEPLAY;
        
        actualDuration = (arc4random() % rangeDuration) + minDuration;
        actionMove = [CCMoveTo actionWithDuration:actualDuration
                                         position:ccp(monster.contentSize.width, actualY)];
        
        actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            _projectiles = nil;
            [self showGameover];
            [node removeFromParentAndCleanup:YES];
        }];
        [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    } @catch (NSException *e) {
        NSLog(@"catch an exception %@", e);
    } @finally {
        /* No need to do anything */
    }
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}
@end
