//
//  Round2.h
//  Sloth Block
//
//  Created by Ryan Temple on 2/8/14.
//  Copyright (c) 2014 Ryan Temple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Round2 : SKScene{
    BOOL isSelected;
    SKLabelNode *scoreLabel;
    SKLabelNode *livesLabel;
    
    CGPoint startPoint;
    SKAction *slothJumpAnimation;
    BOOL isDamaged;
}

-(id)initWithSize:(CGSize)size andScore:(int)score andLives:(int)lives andHighScore:(int)highScore;

@end
