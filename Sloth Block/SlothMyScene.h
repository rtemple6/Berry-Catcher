//
//  SlothMyScene.h
//  Sloth Block
//

//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioServices.h>

@interface SlothMyScene : SKScene{
    
    CGPoint startPoint;
    SKAction *slothJumpAnimation;
    BOOL isDamaged;
    BOOL lifeLost;

    SKLabelNode *scoreLabel;
    SKLabelNode *amountOfLives;
    SKLabelNode *instructions;
    
    int timer;
    int counter;
    
    SKAction *sceneUnPaused;
    SKAction *scenePaused;
    
    SKSpriteNode *berry;
   
}

@end
